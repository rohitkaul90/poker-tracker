import 'package:supabase_flutter/supabase_flutter.dart';

/// Executes [fn] and retries once if PostgREST rejects with PGRST303
/// ("JWT issued at future"). This happens when the device clock is slightly
/// ahead of the Supabase server clock — refreshing the session produces a
/// new token timed against the server.
Future<T> withSupabaseRetry<T>(Future<T> Function() fn) async {
  try {
    return await fn();
  } on PostgrestException catch (e) {
    if (e.code == 'PGRST303') {
      await Supabase.instance.client.auth.refreshSession();
      return fn();
    }
    rethrow;
  }
}
