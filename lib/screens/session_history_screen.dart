import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../providers/providers.dart';
import '../widgets/session_tile.dart';
import 'log_session_screen.dart';
import 'session_detail_screen.dart';

class SessionHistoryScreen extends ConsumerWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_sessions',
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
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('No sessions yet.'));
          }
          return _SessionList(sessions: sessions);
        },
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  final List<Session> sessions;

  const _SessionList({required this.sessions});

  Map<String, List<Session>> _groupByMonth() {
    final map = <String, List<Session>>{};
    for (final s in sessions) {
      final key = DateFormat('MMMM yyyy').format(DateTime.parse(s.date));
      map.putIfAbsent(key, () => []).add(s);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByMonth();
    final slivers = <Widget>[const SliverPadding(padding: EdgeInsets.only(top: 8))];

    for (final entry in groups.entries) {
      slivers.add(SliverPersistentHeader(
        pinned: true,
        delegate: _MonthHeaderDelegate(entry.key),
      ));
      slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => SessionTile(
            session: entry.value[i],
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => SessionDetailScreen(session: entry.value[i]),
              ),
            ),
          ),
          childCount: entry.value.length,
        ),
      ));
    }

    slivers.add(const SliverPadding(padding: EdgeInsets.only(bottom: 88)));
    return CustomScrollView(slivers: slivers);
  }
}

class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String month;

  _MonthHeaderDelegate(this.month);

  @override
  double get maxExtent => 40;
  @override
  double get minExtent => 40;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        month,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_MonthHeaderDelegate old) => old.month != month;
}
