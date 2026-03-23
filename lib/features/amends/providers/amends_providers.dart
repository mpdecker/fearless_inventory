import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../data/repositories/amends_repository.dart';
import '../../../core/database/database.dart';

// Real-time stream of all amends
final amendsListProvider = StreamProvider<List<Amend>>((ref) {
  return ref.watch(amendsRepositoryProvider).watchAll();
});

/// Toggles an amends entry between 'pending' and 'completed'.
/// Uses the repository's toggleCompleted helper so status strings stay
/// consistent across the whole codebase ('step8' | 'pending' | 'completed').
final amendsUpdateProvider = Provider((ref) {
  final repo = ref.watch(amendsRepositoryProvider);

  return (int id, bool isCompleted) async {
    await repo.toggleCompleted(id, isCompleted);
  };
});
