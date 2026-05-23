import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileService {
  final _client = Supabase.instance.client;

  String? get uid => _client.auth.currentUser?.id;
  String? get email => _client.auth.currentUser?.email;
  String? get googleName =>
      _client.auth.currentUser?.userMetadata?['full_name'] as String?;
  String? get googleAvatarUrl =>
      _client.auth.currentUser?.userMetadata?['avatar_url'] as String?;

  Future<ProfileModel?> fetchProfile() async {
    final id = uid;
    if (id == null) return null;
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> upsertProfile(ProfileModel profile) async {
    final data = await _client
        .from('profiles')
        .upsert(profile.toUpsert())
        .select()
        .single();
    return ProfileModel.fromJson(data);
  }
}
