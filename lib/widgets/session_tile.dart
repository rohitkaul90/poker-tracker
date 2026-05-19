import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../utils/helpers.dart';

class SessionTile extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;

  const SessionTile({super.key, required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    final plColor = session.profitLoss >= 0 ? Colors.green : Colors.red;
    final date = DateFormat('MMM d').format(DateTime.parse(session.date));
    final dur = formatDuration(session.durationMinutes);

    return ListTile(
      onTap: onTap,
      title: Text('$date · ${session.stakes}'),
      subtitle: Text(dur),
      trailing: Text(
        formatPL(session.profitLoss),
        style: TextStyle(
          color: plColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
