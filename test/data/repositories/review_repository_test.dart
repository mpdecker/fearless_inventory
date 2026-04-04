import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/review_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('insertReview, watchAllReviews, watchTodayReviews', () async {
    final t = await openTempEncryptedDb('fi_review_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(reviewRepositoryProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    await repo.insertReview(
      DailyReviewsCompanion.insert(date: yesterday, createdAt: now),
    );
    await repo.insertReview(
      DailyReviewsCompanion.insert(date: today, createdAt: now),
    );

    final all = await repo.watchAllReviews().first;
    expect(all, hasLength(2));
    expect(all.first.date, today);

    final todayOnly = await repo.watchTodayReviews().first;
    expect(todayOnly, hasLength(1));
    expect(todayOnly.single.date, today);
  });
}
