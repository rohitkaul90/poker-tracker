import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import 'providers.dart' show authUserIdProvider;

final profileServiceProvider =
    Provider<ProfileService>((ref) => ProfileService());

final profileProvider = FutureProvider<ProfileModel?>((ref) {
  ref.watch(authUserIdProvider); // re-fetch when user changes
  return ref.read(profileServiceProvider).fetchProfile();
});
