import 'package:drift/drift.dart' show Value;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/providers/sobriety_provider.dart';
import 'package:fearless_inventory/features/insights/providers/insights_extended_providers.dart';
import 'package:fearless_inventory/features/review/review_type.dart';

import '../../data/repositories/repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('sobrietyMilestoneProvider', () {
    test('maps days sober to milestone labels', () {
      final container = ProviderContainer(
        overrides: [
          daysSoberProvider.overrideWithValue(45),
        ],
      );
      addTearDown(container.dispose);

      final m = container.read(sobrietyMilestoneProvider);
      expect(m, isNotNull);
      expect(m!.currentMilestoneLabel, '30 days');
      expect(m.nextMilestoneLabel, '60 days');
      expect(m.daysToNext, 15);
      expect(m.progressToNext, closeTo(0.5, 1e-9));
    });

    test('returns null when days sober is unknown', () {
      final container = ProviderContainer(
        overrides: [
          daysSoberProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(sobrietyMilestoneProvider), isNull);
    });

    test('before first milestone: current label null, next is 1 day', () {
      final container = ProviderContainer(
        overrides: [
          daysSoberProvider.overrideWithValue(0),
        ],
      );
      addTearDown(container.dispose);

      final m = container.read(sobrietyMilestoneProvider);
      expect(m, isNotNull);
      expect(m!.currentMilestoneLabel, isNull);
      expect(m.nextMilestoneLabel, '1 day');
    });
  });

  group('FutureProviders with database', () {
    test('journalInsightsProvider aggregates entries', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final (:dir, :dbFile, :db) = await openTempEncryptedDb('fi_insights_journal_');
      addTearDown(() => disposeTempDb(db: db, dir: dir, dbFile: dbFile));

      final now = DateTime.now();
      await db.into(db.journalEntries).insert(
            JournalEntriesCompanion.insert(
              title: const Value('T'),
              content: 'body',
              stepNumber: const Value(4),
              createdAt: Value(now.subtract(const Duration(days: 2))),
              updatedAt: Value(now.subtract(const Duration(days: 2))),
            ),
          );

      final container = containerWithDatabase(db);
      addTearDown(container.dispose);

      final insights = await container.read(journalInsightsProvider.future);
      expect(insights.totalEntries, 1);
      expect(insights.stepsCovered, 1);
      expect(insights.coveredSteps, {4});
      expect(insights.last7DaysCount, 1);
    });

    test('disturberBreakdownProvider counts last 30 reviews', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final (:dir, :dbFile, :db) = await openTempEncryptedDb('fi_insights_dist_');
      addTearDown(() => disposeTempDb(db: db, dir: dir, dbFile: dbFile));

      final d = DateTime.now();
      await db.into(db.dailyReviews).insert(
            DailyReviewsCompanion.insert(
              date: d,
              wasResentful: const Value(true),
              wasSelfish: const Value(false),
              wasDishonest: const Value(true),
              wasAfraid: const Value(false),
              reviewType: const Value('nightly'),
              createdAt: d,
            ),
          );

      final container = containerWithDatabase(db);
      addTearDown(container.dispose);

      final breakdown = await container.read(disturberBreakdownProvider.future);
      expect(breakdown.totalReviews, 1);
      expect(breakdown.resentful, 1);
      expect(breakdown.dishonest, 1);
      expect(breakdown.selfish, 0);
      expect(breakdown.afraid, 0);
    });

    test('step10TypeInsightsProvider splits by review type', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final (:dir, :dbFile, :db) = await openTempEncryptedDb('fi_insights_step10_');
      addTearDown(() => disposeTempDb(db: db, dir: dir, dbFile: dbFile));

      final base = DateTime.now();
      Future<void> insert(String type, bool signal) async {
        final t = base.subtract(Duration(seconds: type.hashCode % 1000));
        await db.into(db.dailyReviews).insert(
              DailyReviewsCompanion.insert(
                date: t,
                wasResentful: Value(signal),
                wasSelfish: const Value(false),
                wasDishonest: const Value(false),
                wasAfraid: const Value(false),
                reviewType: Value(type),
                createdAt: t,
              ),
            );
      }

      await insert(ReviewType.morning.dbValue, false);
      await insert(ReviewType.morning.dbValue, true);
      await insert(ReviewType.spotCheck.dbValue, false);

      final container = containerWithDatabase(db);
      addTearDown(container.dispose);

      final s = await container.read(step10TypeInsightsProvider.future);
      expect(s.morningCount, 2);
      expect(s.spotCheckCount, 1);
      expect(s.nightlyCount, 0);
      expect(s.totalCount, 3);
      expect(s.morningSignalRate, 0.5);
      expect(s.spotCheckSignalRate, 0.0);
    });

    test('sponsorCallInsightsProvider uses recent logs', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final (:dir, :dbFile, :db) = await openTempEncryptedDb('fi_insights_sponsor_');
      addTearDown(() => disposeTempDb(db: db, dir: dir, dbFile: dbFile));

      final now = DateTime.now();
      await db.into(db.sponsorCallLogs).insert(
            SponsorCallLogsCompanion.insert(
              confirmedAt: now.subtract(const Duration(days: 2)),
            ),
          );

      final container = containerWithDatabase(db);
      addTearDown(container.dispose);

      final i = await container.read(sponsorCallInsightsProvider.future);
      expect(i.callsLast4Weeks, 1);
      expect(i.callsThisWeek, 1);
      expect(i.hasCalls, isTrue);
      expect(i.lastCallAt, isNotNull);
    });
  });
}
