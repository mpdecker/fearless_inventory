import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/services/seed_data_service.dart';

import '../../data/repositories/repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SeedDataService', () {
    test('sampleSponsorReviewJson is valid export-shaped JSON', () {
      final decoded =
          jsonDecode(SeedDataService.sampleSponsorReviewJson) as Map<String, dynamic>;
      expect(decoded['resentments'], isA<List<dynamic>>());
      expect(decoded['fears'], isA<List<dynamic>>());
      expect(decoded['harms'], isA<List<dynamic>>());
      expect((decoded['resentments'] as List).length, greaterThanOrEqualTo(1));
    });

    test('seed populates core tables with expected row counts', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final (:dir, :dbFile, :db) = await openTempEncryptedDb('fi_seed_');
      addTearDown(() => disposeTempDb(db: db, dir: dir, dbFile: dbFile));

      await SeedDataService(db).seed();

      expect((await db.select(db.resentments).get()).length, 8);
      expect((await db.select(db.fears).get()).length, 6);
      expect((await db.select(db.harms).get()).length, 7);
      expect((await db.select(db.amends).get()).length, 8);
      expect((await db.select(db.dailyReviews).get()).length, 32);
      expect((await db.select(db.journalEntries).get()).length, 10);
      expect((await db.select(db.sponsorCallLogs).get()).length, 10);
      expect((await db.select(db.sponsees).get()).length, 2);
      expect((await db.select(db.meetings).get()).length, 4);
      expect((await db.select(db.rolodexContacts).get()).length, 5);
    });
  });
}
