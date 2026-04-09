import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/review_repository.dart';
import 'package:fearless_inventory/features/review/review_type.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReviewRepository', () {
    late ({Directory dir, File dbFile, AppDatabase db}) t;
    late ReviewRepository repo;

    setUp(() async {
      t = await openTempEncryptedDb('fi_review_repo_');
      final container = containerWithDatabase(t.db);
      addTearDown(container.dispose);
      repo = container.read(reviewRepositoryProvider);
    });

    tearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    // ── watchAllReviews / watchTodayReviews ──────────────────────────────────

    test('watchAllReviews and watchTodayReviews return correct rows', () async {
      final now   = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      await repo.insertReview(
          DailyReviewsCompanion.insert(date: today.subtract(const Duration(days: 1)), createdAt: now));
      await repo.insertReview(
          DailyReviewsCompanion.insert(date: today, createdAt: now));

      final all = await repo.watchAllReviews().first;
      expect(all, hasLength(2));
      expect(all.first.date, today); // most-recent first

      final todayOnly = await repo.watchTodayReviews().first;
      expect(todayOnly, hasLength(1));
      expect(todayOnly.single.date, today);
    });

    // ── getRecentByType ──────────────────────────────────────────────────────

    test('getRecentByType returns only rows matching the given type', () async {
      final now = DateTime.now();
      await repo.insertReview(DailyReviewsCompanion.insert(
        date: now, createdAt: now,
        reviewType: const Value('morning'),
      ));
      await repo.insertReview(DailyReviewsCompanion.insert(
        date: now, createdAt: now,
        reviewType: const Value('spot_check'),
      ));
      await repo.insertReview(DailyReviewsCompanion.insert(
        date: now, createdAt: now,
        reviewType: const Value('nightly'),
      ));

      final morning   = await repo.getRecentByType(ReviewType.morning,   30);
      final spotCheck = await repo.getRecentByType(ReviewType.spotCheck, 30);
      final nightly   = await repo.getRecentByType(ReviewType.nightly,   30);

      expect(morning,   hasLength(1));
      expect(spotCheck, hasLength(1));
      expect(nightly,   hasLength(1));
      expect(morning.single.reviewType,   'morning');
      expect(spotCheck.single.reviewType, 'spot_check');
      expect(nightly.single.reviewType,   'nightly');
    });

    test('getRecentByType excludes rows older than the cutoff', () async {
      final old = DateTime.now().subtract(const Duration(days: 8));
      await repo.insertReview(DailyReviewsCompanion.insert(
        date: old, createdAt: old,
        reviewType: const Value('morning'),
      ));

      final results = await repo.getRecentByType(ReviewType.morning, 7);
      expect(results, isEmpty);
    });

    test('getRecentByType returns empty list when no matching type exists', () async {
      final now = DateTime.now();
      await repo.insertReview(DailyReviewsCompanion.insert(
        date: now, createdAt: now,
        reviewType: const Value('nightly'),
      ));

      final morning = await repo.getRecentByType(ReviewType.morning, 30);
      expect(morning, isEmpty);
    });

    // ── getRecentReviews ──────────────────────────────────────────────────────

    test('getRecentReviews returns all types within the window', () async {
      final now = DateTime.now();
      await repo.insertReview(DailyReviewsCompanion.insert(
        date: now, createdAt: now, reviewType: const Value('morning'),
      ));
      await repo.insertReview(DailyReviewsCompanion.insert(
        date: now, createdAt: now, reviewType: const Value('nightly'),
      ));

      final recent = await repo.getRecentReviews(7);
      expect(recent, hasLength(2));
    });

    test('getRecentReviews excludes rows outside the window', () async {
      final old = DateTime.now().subtract(const Duration(days: 15));
      await repo.insertReview(DailyReviewsCompanion.insert(
        date: old, createdAt: old,
      ));

      final recent = await repo.getRecentReviews(7);
      expect(recent, isEmpty);
    });

    // ── reviewType default value ──────────────────────────────────────────────

    test('reviews inserted without explicit reviewType default to "nightly"',
        () async {
      final now = DateTime.now();
      await repo.insertReview(
          DailyReviewsCompanion.insert(date: now, createdAt: now));

      final all = await repo.watchAllReviews().first;
      expect(all.single.reviewType, 'nightly');
    });
  });
}
