import 'package:hooks_riverpod/hooks_riverpod.dart'; // Fixes 'StreamProvider' error
import '../../../data/repositories/review_repository.dart'; // Fixes 'reviewRepositoryProvider' error
import '../../../core/database/database.dart';

class DayReflection {
  final DateTime date;
  final int intensity;
  final bool hasNotes;
  DayReflection({required this.date, required this.intensity, required this.hasNotes});
}

final spiritualLandscapeProvider = StreamProvider<List<DayReflection>>((ref) {
  return ref.watch(reviewRepositoryProvider).watchAllReviews().map((reviews) {
    return reviews.take(14).toList().reversed.map((r) {
      int disturberCount = 0;
      if (r.wasResentful) disturberCount++;
      if (r.wasSelfish) disturberCount++;
      if (r.wasDishonest) disturberCount++;
      if (r.wasAfraid) disturberCount++;
      
      return DayReflection(
        date: r.date,
        intensity: disturberCount,
        hasNotes: r.notes?.isNotEmpty ?? false,
      );
    }).toList();
  });
});