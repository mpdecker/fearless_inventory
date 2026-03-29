import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/sponsee_repository.dart';
import '../../../data/repositories/service_commitments_repository.dart';

/// Stream of a single sponsee by id; emits null if not found.
final sponseeProvider =
    StreamProvider.autoDispose.family<Sponsee?, int>((ref, id) {
  final repo = ref.watch(sponseeRepositoryProvider);
  return repo.watchAll().map((list) {
    try {
      return list.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  });
});

/// Step progress entries for a specific sponsee.
final sponseeStepProgressProvider =
    StreamProvider.autoDispose.family<List<SponseeStepEntry>, int>(
  (ref, sponseeId) =>
      ref.watch(sponseeRepositoryProvider).watchStepProgress(sponseeId),
);

/// Check-ins for a specific sponsee.
final sponseeCheckInsProvider =
    StreamProvider.autoDispose.family<List<SponseeCheckIn>, int>(
  (ref, sponseeId) =>
      ref.watch(sponseeRepositoryProvider).watchCheckIns(sponseeId),
);

/// 12th-step calls linked to a specific sponsee.
final sponseeCallsProvider =
    StreamProvider.autoDispose.family<List<TwelfthStepCall>, int>(
  (ref, sponseeId) => ref
      .watch(serviceCommitmentsRepositoryProvider)
      .watchCallsForSponsee(sponseeId),
);
