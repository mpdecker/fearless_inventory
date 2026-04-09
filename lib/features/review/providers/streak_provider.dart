import 'package:fearless_inventory/core/database/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'review_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pure streak calculation — extracted for unit-testability.
// ─────────────────────────────────────────────────────────────────────────────

/// Counts consecutive days (ending on [refNow], or today when omitted) on
/// which at least one [DailyReview] was logged.
///
/// Multiple reviews on the same day count as a single streak day.
/// A gap of one or more days with no review resets the streak to 0.
int calculateStreak(List<DailyReview> reviews, [DateTime? refNow]) {
  if (reviews.isEmpty) return 0;

  DateTime normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  final sorted = [...reviews]..sort((a, b) => b.date.compareTo(a.date));

  int streak = 0;
  DateTime checkDate = refNow ?? DateTime.now();

  for (final review in sorted) {
    final reviewDate  = normalize(review.date);
    final currentCheck = normalize(checkDate);

    if (reviewDate == currentCheck) {
      // This day is covered — advance the window back one day.
      streak++;
      checkDate = currentCheck.subtract(const Duration(days: 1));
    } else if (reviewDate.isBefore(currentCheck)) {
      // The next review is older than the expected next day → gap → stop.
      break;
    }
    // reviewDate > currentCheck means a future-dated entry for a day we
    // already counted — just skip it.
  }
  return streak;
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod provider
// ─────────────────────────────────────────────────────────────────────────────

final streakProvider = Provider<int>((ref) {
  final reviewsAsync = ref.watch(reviewsStreamProvider);
  return reviewsAsync.maybeWhen(
    data: calculateStreak,
    orElse: () => 0,
  );
});