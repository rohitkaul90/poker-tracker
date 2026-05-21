import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';
import '../providers/providers.dart';
import '../utils/helpers.dart';
import 'log_session_screen.dart';

class SessionDetailScreen extends ConsumerWidget {
  final SessionModel session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plColor = session.profitLoss >= 0 ? Colors.green : Colors.red;
    final dateStr =
        DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(session.date));
    final isTournament = isTournamentType(session.gameType);
    final currency = session.currency;
    final sym = currencySymbol(currency);
    final roi = isTournament && session.buyIn > 0
        ? calcROI(session.profitLoss, session.buyIn)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LogSessionScreen(session: session),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Text(dateStr,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    gameTypeLabel(session.gameType),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatPLWithCurrency(session.profitLoss, currency),
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(
                      color: plColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (roi != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ROI: ${formatROI(roi)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: plColor,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (!isTournament)
            _Row(label: 'Stakes', value: session.stakes),

          _Row(label: 'Buy-in', value: '$sym${session.buyIn.toStringAsFixed(0)}'),

          if (isTournament) ...[
            _Row(
                label: 'Prize Won',
                value: '$sym${(session.prizeWon ?? 0).toStringAsFixed(0)}'),
            if (session.finishPosition != null)
              _Row(
                label: 'Finish',
                value: session.totalEntrants != null
                    ? '${session.finishPosition} / ${session.totalEntrants}'
                    : '${session.finishPosition}',
              ),
          ] else
            _Row(
                label: 'Cash-out',
                value: '$sym${session.cashOut.toStringAsFixed(0)}'),

          if (session.rakePaid != null)
            _Row(
                label: 'Rake / Fees',
                value: '$sym${session.rakePaid!.toStringAsFixed(0)}'),

          _Row(label: 'Currency', value: currency),
          _Row(
              label: 'Duration',
              value: formatDuration(session.durationMinutes)),
          _Row(label: 'Time',
              value: '${session.startTime} → ${session.endTime}'),

          if (session.handsPerHour != null)
            _Row(
                label: 'Hands/hr',
                value: '${session.handsPerHour}'),

          if (session.tableQuality != null && !isTournament) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      'Table',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < session.tableQuality!
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: i < session.tableQuality!
                                ? Colors.amber
                                : Theme.of(context).colorScheme.outline,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tableQualityLabel(session.tableQuality),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (session.location != null && session.location!.isNotEmpty)
            _Row(label: 'Location', value: session.location!),
          if (session.country != null && session.country!.isNotEmpty)
            _Row(label: 'Country', value: session.country!),
          if (session.notes != null && session.notes!.isNotEmpty)
            _Row(label: 'Notes', value: session.notes!),

          const SizedBox(height: 32),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Delete Session',
                style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Colors.red),
            ),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(supabaseServiceProvider).deleteSession(session.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    )),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
