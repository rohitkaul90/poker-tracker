import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';
import '../utils/helpers.dart';

class SessionTile extends StatelessWidget {
  final SessionModel session;
  final VoidCallback? onTap;

  const SessionTile({super.key, required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    final plColor = session.profitLoss >= 0 ? Colors.green : Colors.red;
    final date = DateFormat('MMM d').format(DateTime.parse(session.date));
    final dur = formatDuration(session.durationMinutes);
    final isTournament = isTournamentType(session.gameType);
    final location = session.location ?? gameTypeLabel(session.gameType);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: isTournament
            ? Theme.of(context).colorScheme.tertiaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(
          isTournament ? Icons.emoji_events_outlined : Icons.casino_outlined,
          size: 18,
          color: isTournament
              ? Theme.of(context).colorScheme.onTertiaryContainer
              : Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(isTournament ? '$date · Tournament' : '$date · ${session.stakes}'),
      subtitle: Text('$dur · $location'),
      trailing: Text(
        formatPLWithCurrency(session.profitLoss, session.currency),
        style: TextStyle(
          color: plColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
