import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final sessionsProvider = StreamProvider<List<Session>>((ref) {
  return ref.watch(databaseProvider).watchAllSessions();
});

final filterProvider = StateProvider<SessionFilter>((ref) => const SessionFilter());

final filteredSessionsProvider = StreamProvider<List<Session>>((ref) {
  final filter = ref.watch(filterProvider);
  final db = ref.watch(databaseProvider);
  if (filter.isEmpty) return db.watchAllSessions();
  return db.watchFilteredSessions(filter);
});

final distinctStakesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(databaseProvider).getDistinctStakes();
});

final distinctLocationsProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(databaseProvider).getDistinctLocations();
});
