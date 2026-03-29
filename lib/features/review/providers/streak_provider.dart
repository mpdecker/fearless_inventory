import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'review_providers.dart';

final streakProvider = Provider<int>((ref) {
  final reviewsAsync = ref.watch(reviewsStreamProvider);

  return reviewsAsync.maybeWhen(
    data: (reviews) {
      if (reviews.isEmpty) return 0;

      // Ensure reviews are sorted by date descending
      final sortedReviews = [...reviews]..sort((a, b) => b.date.compareTo(a.date));
      
      int streak = 0;
      DateTime checkDate = DateTime.now();

      // Normalize checkDate to midnight for accurate day-to-day comparison
      DateTime normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

      for (final review in sortedReviews) {
        final reviewDate = normalize(review.date);
        final currentCheck = normalize(checkDate);

        // If the review is from today or exactly the checkDate
        if (reviewDate == currentCheck) {
          streak++;
          checkDate = currentCheck.subtract(const Duration(days: 1));
        } else if (reviewDate.isBefore(currentCheck)) {
          // Gap found in the streak
          break;
        }
      }
      return streak;
    },
    orElse: () => 0,
  );
});