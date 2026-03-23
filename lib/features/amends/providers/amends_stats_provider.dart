import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/models/amends_type.dart';
import '../../../data/repositories/amends_repository.dart';

final amendsStatsProvider = StreamProvider<Map<AmendsType, int>>((ref) {
  return ref.watch(amendsRepositoryProvider).watchAll().map((list) {
    final stats = { for (var type in AmendsType.values) type : 0 };
    for (var amend in list) {
      final type = amend.amendsType;
      if (type == null) continue;
      stats[type] = (stats[type] ?? 0) + 1;
    }
    return stats;
  });
});