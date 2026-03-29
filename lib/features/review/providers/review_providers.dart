import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/review_repository.dart';

/// All daily reviews, most recent first.
final reviewsStreamProvider = StreamProvider<List<DailyReview>>((ref) {
  return ref.watch(reviewRepositoryProvider).watchAllReviews();
});

/// Only reviews logged today (midnight–midnight local time).
final todayReviewsProvider = StreamProvider.autoDispose<List<DailyReview>>(
  (ref) => ref.watch(reviewRepositoryProvider).watchTodayReviews(),
);
