import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/fear_repository.dart';
import '../../../data/repositories/resentment_repository.dart';

/// Provider for the real-time stream of all Resentments
final resentmentsStreamProvider = StreamProvider<List<Resentment>>((ref) {
  // Accesses the repository to watch the database table
  return ref.watch(resentmentRepositoryProvider).watchAllResentments();
});

/// Provider for the real-time stream of all Fears
final fearsStreamProvider = StreamProvider<List<Fear>>((ref) {
  // Accesses the repository to watch the database table
  return ref.watch(fearRepositoryProvider).watchAllFears();
});