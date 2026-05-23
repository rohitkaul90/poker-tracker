import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

final profileServiceProvider =
    Provider<ProfileService>((ref) => ProfileService());

final profileProvider = FutureProvider<ProfileModel?>((ref) {
  return ref.read(profileServiceProvider).fetchProfile();
});
