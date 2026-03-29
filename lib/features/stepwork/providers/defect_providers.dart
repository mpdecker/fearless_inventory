import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/defect_repository.dart';

/// Real-time stream of all character defects (Step 6 catalog).
final defectsListProvider = StreamProvider<List<Defect>>((ref) {
  return ref.watch(defectRepositoryProvider).watchAll();
});
