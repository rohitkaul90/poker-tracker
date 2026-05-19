import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/providers.dart';
import '../utils/helpers.dart';
import '../widgets/stat_card.dart';
import '../widgets/session_tile.dart';
import 'log_session_screen.dart';
import 'session_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_dashboard',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LogSessionScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Log Session'),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) => _DashboardBody(sessions: sessions),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final List<Session> sessions;

  const _DashboardBody({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final stats = _Stats.from(sessions);
    final recent = sessions.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                Text('Total P&L', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  formatPL(stats.totalPL),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: stats.totalPL >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            StatCard(
              label: 'Hours Played',
              value: '${stats.totalHours.toStringAsFixed(1)}h',
            ),
            StatCard(
              label: 'Hourly Rate',
              value: formatPL(stats.hourlyRate),
              valueColor: stats.hourlyRate >= 0 ? Colors.green : Colors.red,
            ),
            StatCard(label: 'Sessions', value: '${stats.sessionCount}'),
            StatCard(
              label: 'Win Rate',
              value: '${stats.winRate.toStringAsFixed(0)}%',
              valueColor: stats.winRate >= 50 ? Colors.green : Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (recent.isNotEmpty) ...[
          Text('Recent Sessions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          ...recent.map(
            (s) => SessionTile(
              session: s,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SessionDetailScreen(session: s)),
              ),
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 48),
            child: Center(child: Text('No sessions yet.\nTap + to log your first session!')),
          ),
      ],
    );
  }
}

class _Stats {
  final double totalPL;
  final double totalHours;
  final double hourlyRate;
  final int sessionCount;
  final double winRate;

  _Stats({
    required this.totalPL,
    required this.totalHours,
    required this.hourlyRate,
    required this.sessionCount,
    required this.winRate,
  });

  factory _Stats.from(List<Session> sessions) {
    if (sessions.isEmpty) {
      return _Stats(
          totalPL: 0, totalHours: 0, hourlyRate: 0, sessionCount: 0, winRate: 0);
    }
    final totalPL = sessions.fold(0.0, (s, e) => s + e.profitLoss);
    final totalMinutes = sessions.fold(0, (s, e) => s + e.durationMinutes);
    final totalHours = totalMinutes / 60.0;
    final hourlyRate = totalHours > 0 ? totalPL / totalHours : 0.0;
    final wins = sessions.where((s) => s.profitLoss > 0).length;
    final winRate = wins / sessions.length * 100;
    return _Stats(
      totalPL: totalPL,
      totalHours: totalHours,
      hourlyRate: hourlyRate,
      sessionCount: sessions.length,
      winRate: winRate,
    );
  }
}
