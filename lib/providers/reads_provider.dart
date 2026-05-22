import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_read.dart';
import '../services/reads_service.dart';

final readsServiceProvider = Provider<ReadsService>((ref) => ReadsService());

final readsProvider = StreamProvider<List<PlayerRead>>((ref) {
  return ref.watch(readsServiceProvider).watchReads();
});
