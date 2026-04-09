import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/database/database.dart';
import '../../features/review/review_type.dart';

final reviewRepositoryProvider =
    Provider((ref) => ReviewRepository(ref.read(databaseProvider)));

class ReviewRepository {
  final AppDatabase _db;
  ReviewRepository(this._db);

  Stream<List<DailyReview>> watchAllReviews() =>
      (_db.select(_db.dailyReviews)
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
            ]))
          .watch();

  /// Streams all review incidents logged today (midnight–midnight local time).
  /// Date filtering is applied in Dart after fetching, because Drift 2.32
  /// does not expose ordering comparison methods for DateTimeColumn.
  Stream<List<DailyReview>> watchTodayReviews() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (_db.select(_db.dailyReviews)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)
          ]))
        .watch()
        .map((rows) => rows
            .where((r) =>
                !r.date.isBefore(startOfDay) && r.date.isBefore(endOfDay))
            .toList());
  }

  /// Fetches all reviews in the last [days] days, client-side filtered.
  Future<List<DailyReview>> getRecentReviews(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final rows = await _db.select(_db.dailyReviews).get();
    return rows.where((r) => r.createdAt.isAfter(cutoff)).toList();
  }

  /// Fetches reviews in the last [days] days for a specific [type].
  Future<List<DailyReview>> getRecentByType(ReviewType type, int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final rows = await _db.select(_db.dailyReviews).get();
    return rows
        .where((r) =>
            r.reviewType == type.dbValue && r.createdAt.isAfter(cutoff))
        .toList();
  }

  Future<int> insertReview(DailyReviewsCompanion entry) =>
      _db.into(_db.dailyReviews).insert(entry);
}
