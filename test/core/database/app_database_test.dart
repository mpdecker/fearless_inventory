import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/models/amends_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testKey =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

  /// Drift @DriftDatabase user tables at schema v14 (sqlite_master names).
  const expectedTables = <String>{
    'resentments',
    'fears',
    'harms',
    'daily_reviews',
    'amends',
    'defects',
    'shortcoming_logs',
    'step5_completions',
    'meditation_sessions',
    'step_twelve_events',
    'meetings',
    'attendance_logs',
    'sync_metas',
    'service_commitments',
    'twelfth_step_calls',
    'sponsees',
    'sponsee_step_progress',
    'sponsee_check_ins',
    'journal_entries',
    'literature_bookmarks',
    'sponsor_call_logs',
    'rolodex_contacts',
    'literature_annotations',
  };

  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fi_db_test_');
    dbFile = File(p.join(tempDir.path, 'test.db'));
  });

  tearDown(() async {
    try {
      if (await dbFile.exists()) await dbFile.delete();
    } catch (_) {}
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  Future<AppDatabase> openDb() async {
    return AppDatabase.forTesting(dbFile, testKey);
  }

  group('AppDatabase encryption & schema', () {
    test('wrong passphrase cannot read encrypted database pages', () async {
      final good = await openDb();
      final now = DateTime.now();
      await good.into(good.resentments).insert(ResentmentsCompanion.insert(
            person: 'X',
            cause: 'c',
            affects: 'a',
            myPart: 'm',
            createdAt: now,
          ));
      await good.close();

      const wrongKey =
          'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';
      final bad = AppDatabase.forTesting(dbFile, wrongKey);
      try {
        await expectLater(
          bad.select(bad.resentments).get(),
          throwsA(anything),
        );
      } finally {
        await bad.close();
      }
    });

    test('schema version is 16 after fresh create', () async {
      final db = await openDb();
      addTearDown(db.close);
      final row = await db
          .customSelect('PRAGMA user_version')
          .map((r) => r.read<int>('user_version'))
          .getSingle();
      expect(row, 16);
    });

    test('all user tables exist', () async {
      final db = await openDb();
      addTearDown(db.close);
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' "
            "AND name NOT LIKE 'sqlite_%' ORDER BY name",
          )
          .map((r) => r.read<String>('name'))
          .get();
      expect(rows.toSet(), expectedTables);
    });
  });

  group('CRUD round-trip per table', () {
    test('insert and read one row in every table', () async {
      final db = await openDb();
      addTearDown(db.close);
      final now = DateTime.now();

      await db.into(db.resentments).insert(ResentmentsCompanion.insert(
            person: 'P',
            cause: 'c',
            affects: 'a',
            myPart: 'm',
            createdAt: now,
          ));

      await db.into(db.fears).insert(FearsCompanion.insert(
            subject: 'S',
            why: 'w',
            myPart: 'm',
            createdAt: now,
          ));

      final harmId = await db.into(db.harms).insert(HarmsCompanion.insert(
            person: 'HP',
            conduct: 'c',
            myPart: 'm',
            createdAt: now,
          ));

      final reviewId = await db.into(db.dailyReviews).insert(
            DailyReviewsCompanion.insert(date: now, createdAt: now),
          );

      await db.into(db.amends).insert(AmendsCompanion.insert(
            person: 'AP',
            harmId: Value(harmId),
            amendsType: const Value(AmendsType.personal),
          ));

      final defectId = await db.into(db.defects).insert(
            DefectsCompanion.insert(name: 'D', createdAt: now),
          );

      await db.into(db.shortcomingLogs).insert(ShortcomingLogsCompanion.insert(
            description: 'desc',
            dateObserved: now,
            relatedReviewId: Value(reviewId),
            defectId: Value(defectId),
          ));

      await db.into(db.step5Completions).insert(Step5CompletionsCompanion.insert(
            completedAt: now,
          ));

      await db.into(db.meditationSessions).insert(
            MeditationSessionsCompanion.insert(
              sessionType: 'morning',
              reflectionTheme: 't',
              reflectionKey: 'k',
              completedAt: now,
            ),
          );

      await db.into(db.stepTwelveEvents).insert(
            StepTwelveEventsCompanion.insert(
              title: 'T',
              startTime: now,
            ),
          );

      final meetingId = await db.into(db.meetings).insert(
            MeetingsCompanion.insert(
              sourceId: 'src',
              externalId: 'ext1',
              name: 'N',
              city: 'C',
              state: 'ST',
              weekday: 1,
              startTime: '10:00',
            ),
          );

      await db.into(db.attendanceLogs).insert(
            AttendanceLogsCompanion.insert(
              meetingId: Value(meetingId),
              meetingName: 'MN',
              attendedAt: now,
            ),
          );

      await db.into(db.syncMetas).insert(
            SyncMetasCompanion.insert(
              sourceId: 'guide',
              displayName: 'Guide',
            ),
          );

      await db.into(db.serviceCommitments).insert(
            ServiceCommitmentsCompanion.insert(
              title: 'coffee',
              startDate: now,
            ),
          );

      final sponseeId = await db.into(db.sponsees).insert(
            SponseesCompanion.insert(name: 'Sam'),
          );

      await db.into(db.sponseeStepProgress).insert(
            SponseeStepProgressCompanion.insert(
              sponseeId: sponseeId,
              stepNumber: 1,
            ),
          );

      await db.into(db.sponseeCheckIns).insert(
            SponseeCheckInsCompanion.insert(
              sponseeId: sponseeId,
              scheduledAt: now,
            ),
          );

      await db.into(db.twelfthStepCalls).insert(
            TwelfthStepCallsCompanion.insert(
              description: 'helped',
              occurredAt: now,
              sponseeId: Value(sponseeId),
            ),
          );

      await db.into(db.journalEntries).insert(
            JournalEntriesCompanion.insert(content: 'hello'),
          );

      await db.into(db.literatureBookmarks).insert(
            LiteratureBookmarksCompanion.insert(
              bookKey: 'bigbook',
              chapterKey: 'bb_ch1',
              chapterTitle: 'Bill',
            ),
          );

      await db.into(db.sponsorCallLogs).insert(
            SponsorCallLogsCompanion.insert(confirmedAt: now),
          );

      await db.into(db.rolodexContacts).insert(
            RolodexContactsCompanion.insert(name: 'Bob S.'),
          );

      expect(await db.select(db.resentments).get(), hasLength(1));
      expect(await db.select(db.fears).get(), hasLength(1));
      expect(await db.select(db.harms).get(), hasLength(1));
      expect(await db.select(db.dailyReviews).get(), hasLength(1));
      expect(await db.select(db.amends).get(), hasLength(1));
      expect(await db.select(db.defects).get(), hasLength(1));
      expect(await db.select(db.shortcomingLogs).get(), hasLength(1));
      expect(await db.select(db.step5Completions).get(), hasLength(1));
      expect(await db.select(db.meditationSessions).get(), hasLength(1));
      expect(await db.select(db.stepTwelveEvents).get(), hasLength(1));
      expect(await db.select(db.meetings).get(), hasLength(1));
      expect(await db.select(db.attendanceLogs).get(), hasLength(1));
      expect(await db.select(db.syncMetas).get(), hasLength(1));
      expect(await db.select(db.serviceCommitments).get(), hasLength(1));
      expect(await db.select(db.sponsees).get(), hasLength(1));
      expect(await db.select(db.sponseeStepProgress).get(), hasLength(1));
      expect(await db.select(db.sponseeCheckIns).get(), hasLength(1));
      expect(await db.select(db.twelfthStepCalls).get(), hasLength(1));
      expect(await db.select(db.journalEntries).get(), hasLength(1));
      expect(await db.select(db.literatureBookmarks).get(), hasLength(1));
      expect(await db.select(db.sponsorCallLogs).get(), hasLength(1));
      expect(await db.select(db.rolodexContacts).get(), hasLength(1));
    });
  });

  group('foreign keys', () {
    test('Harms → Amends ON DELETE CASCADE removes amends', () async {
      final db = await openDb();
      addTearDown(db.close);
      final now = DateTime.now();
      final harmId = await db.into(db.harms).insert(HarmsCompanion.insert(
            person: 'X',
            conduct: 'c',
            myPart: 'm',
            createdAt: now,
          ));
      await db.into(db.amends).insert(
            AmendsCompanion.insert(person: 'Y', harmId: Value(harmId)),
          );
      await (db.delete(db.harms)..where((t) => t.id.equals(harmId))).go();
      expect(await db.select(db.amends).get(), isEmpty);
    });

    test('Sponsees → child tables CASCADE; TwelfthStepCalls SET NULL',
        () async {
      final db = await openDb();
      addTearDown(db.close);
      final now = DateTime.now();
      final sid = await db.into(db.sponsees).insert(
            SponseesCompanion.insert(name: 'Pat'),
          );
      await db.into(db.sponseeStepProgress).insert(
            SponseeStepProgressCompanion.insert(
              sponseeId: sid,
              stepNumber: 2,
            ),
          );
      await db.into(db.sponseeCheckIns).insert(
            SponseeCheckInsCompanion.insert(
              sponseeId: sid,
              scheduledAt: now,
            ),
          );
      final callId = await db.into(db.twelfthStepCalls).insert(
            TwelfthStepCallsCompanion.insert(
              description: 'd',
              occurredAt: now,
              sponseeId: Value(sid),
            ),
          );
      await (db.delete(db.sponsees)..where((t) => t.id.equals(sid))).go();
      expect(await db.select(db.sponseeStepProgress).get(), isEmpty);
      expect(await db.select(db.sponseeCheckIns).get(), isEmpty);
      final calls = await db.select(db.twelfthStepCalls).get();
      expect(calls, hasLength(1));
      expect(calls.single.sponseeId, isNull);
      expect(calls.single.id, callId);
    });

    test('Defects → ShortcomingLogs ON DELETE SET NULL', () async {
      final db = await openDb();
      addTearDown(db.close);
      final now = DateTime.now();
      final did = await db.into(db.defects).insert(
            DefectsCompanion.insert(name: 'envy', createdAt: now),
          );
      final lid = await db.into(db.shortcomingLogs).insert(
            ShortcomingLogsCompanion.insert(
              description: 'x',
              dateObserved: now,
              defectId: Value(did),
            ),
          );
      await (db.delete(db.defects)..where((t) => t.id.equals(did))).go();
      final rows = await db.select(db.shortcomingLogs).get();
      expect(rows.single.id, lid);
      expect(rows.single.defectId, isNull);
    });
  });

  group('wipeAllData', () {
    test('clears every user table', () async {
      final db = await openDb();
      addTearDown(db.close);
      final now = DateTime.now();

      await db.into(db.resentments).insert(ResentmentsCompanion.insert(
            person: 'P',
            cause: 'c',
            affects: 'a',
            myPart: 'm',
            createdAt: now,
          ));
      await db.into(db.step5Completions).insert(
            Step5CompletionsCompanion.insert(completedAt: now),
          );
      await db.into(db.meditationSessions).insert(
            MeditationSessionsCompanion.insert(
              sessionType: 'evening',
              reflectionTheme: 't',
              reflectionKey: 'k',
              completedAt: now,
            ),
          );

      await db.wipeAllData();

      for (final table in expectedTables) {
        final count = await db
            .customSelect('SELECT COUNT(*) AS c FROM $table')
            .map((r) => r.read<int>('c'))
            .getSingle();
        expect(count, 0, reason: table);
      }
    });
  });
}
