import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/fear_repository.dart';
import '../../../data/repositories/harm_repository.dart';
import '../../../data/repositories/resentment_repository.dart';

final resentmentsStreamProvider = StreamProvider<List<Resentment>>((ref) {
  return ref.watch(resentmentRepositoryProvider).watchAllResentments();
});

final fearsStreamProvider = StreamProvider<List<Fear>>((ref) {
  return ref.watch(fearRepositoryProvider).watchAllFears();
});

final harmListStreamProvider = StreamProvider<List<Harm>>((ref) {
  return ref.watch(harmRepositoryProvider).watchAllHarms();
});