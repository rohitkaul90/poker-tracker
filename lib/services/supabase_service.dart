import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/session_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  String? get _uid => _client.auth.currentUser?.id;

  Stream<List<SessionModel>> watchAllSessions() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _client
        .from('sessions')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('date', ascending: false)
        .map((rows) {
          final sessions = rows.map(SessionModel.fromMap).toList();
          sessions.sort((a, b) {
            final d = b.date.compareTo(a.date);
            return d != 0 ? d : b.startTime.compareTo(a.startTime);
          });
          return sessions;
        });
  }

  Future<void> insertSession(Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await _client.from('sessions').insert({...data, 'user_id': uid});
  }

  Future<void> bulkInsertSessions(List<Map<String, dynamic>> sessions) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    if (sessions.isEmpty) return;
    final withUser = sessions.map((s) => {...s, 'user_id': uid}).toList();
    await _client.from('sessions').insert(withUser);
  }

  Future<void> updateSession(String id, Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await _client.from('sessions').update(data).eq('id', id).eq('user_id', uid);
  }

  Future<void> deleteSession(String id) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await _client.from('sessions').delete().eq('id', id).eq('user_id', uid);
  }

  Future<void> clearAllSessions() async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await _client.from('sessions').delete().eq('user_id', uid);
  }

  Future<Map<String, dynamic>?> getRakePreset(
      String location, String gameType, String stakes) async {
    final uid = _uid;
    if (uid == null) return null;
    return await _client
        .from('rake_presets')
        .select()
        .eq('user_id', uid)
        .eq('location', location)
        .eq('game_type', gameType)
        .eq('stakes', stakes)
        .maybeSingle();
  }

  Future<void> upsertRakePreset(
      String location, String gameType, String stakes, double amount) async {
    final uid = _uid;
    if (uid == null) return;
    await _client.from('rake_presets').upsert({
      'user_id': uid,
      'location': location,
      'game_type': gameType,
      'stakes': stakes,
      'rake_amount': amount,
    }, onConflict: 'user_id,location,game_type,stakes');
  }
}
