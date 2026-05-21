import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_model.dart';
import '../models/session_filter.dart';
import '../services/supabase_service.dart';

export '../models/session_filter.dart' show SessionFilter, SessionResult;

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final sessionsProvider = StreamProvider<List<SessionModel>>((ref) {
  return ref.watch(supabaseServiceProvider).watchAllSessions();
});

final filterProvider = StateProvider<SessionFilter>((ref) => const SessionFilter());

final filteredSessionsProvider = Provider<AsyncValue<List<SessionModel>>>((ref) {
  final filter = ref.watch(filterProvider);
  final sessionsAsync = ref.watch(sessionsProvider);
  if (filter.isEmpty) return sessionsAsync;
  return sessionsAsync.whenData(
    (sessions) => sessions.where(filter.matches).toList(),
  );
});

final distinctStakesProvider = Provider<AsyncValue<List<String>>>((ref) {
  return ref.watch(sessionsProvider).whenData(
    (sessions) => sessions
        .map((s) => s.stakes)
        .where((s) => s != 'N/A')
        .toSet()
        .toList()
      ..sort(),
  );
});

final distinctLocationsProvider = Provider<AsyncValue<List<String>>>((ref) {
  return ref.watch(sessionsProvider).whenData(
    (sessions) => sessions
        .map((s) => s.location)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort(),
  );
});
