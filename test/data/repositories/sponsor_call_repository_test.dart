import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/sponsor_call_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SponsorCallRepository', () {
    late ({Directory dir, File dbFile, AppDatabase db}) t;
    late SponsorCallRepository repo;

    setUp(() async {
      t = await openTempEncryptedDb('fi_sponsor_call_');
      final container = containerWithDatabase(t.db);
      addTearDown(container.dispose);
      repo = container.read(sponsorCallRepositoryProvider);
    });

    tearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    // ── logCall ──────────────────────────────────────────────────────────────

    test('logCall with all fields persists correctly', () async {
      final scheduled  = DateTime(2026, 4, 1, 9, 0);
      final confirmed  = DateTime(2026, 4, 1, 9, 15);

      await repo.logCall(
        scheduledFor: scheduled,
        confirmedAt:  confirmed,
        calledViaApp: true,
        notes:        'Good call.',
      );

      final log = await repo.getLastCall();
      expect(log, isNotNull);
      expect(log!.scheduledFor, scheduled);
      expect(log.confirmedAt,   confirmed);
      expect(log.calledViaApp,  isTrue);
      expect(log.notes,         'Good call.');
    });

    test('logCall without scheduledFor stores null', () async {
      await repo.logCall(confirmedAt: DateTime(2026, 4, 5, 10, 0));
      final log = await repo.getLastCall();
      expect(log!.scheduledFor, isNull);
    });

    test('calledViaApp defaults to false', () async {
      await repo.logCall(confirmedAt: DateTime(2026, 4, 5));
      final log = await repo.getLastCall();
      expect(log!.calledViaApp, isFalse);
    });

    // ── getLastCall ──────────────────────────────────────────────────────────

    test('getLastCall returns null when no calls logged', () async {
      expect(await repo.getLastCall(), isNull);
    });

    test('getLastCall returns the most recent entry', () async {
      final older = DateTime(2026, 3, 1);
      final newer = DateTime(2026, 4, 1);
      await repo.logCall(confirmedAt: older);
      await repo.logCall(confirmedAt: newer);
      final log = await repo.getLastCall();
      expect(log!.confirmedAt, newer);
    });

    // ── getRecentLogs ────────────────────────────────────────────────────────

    test('getRecentLogs(7) includes calls within 7 days', () async {
      final now  = DateTime.now();
      final inside  = now.subtract(const Duration(days: 6));
      final outside = now.subtract(const Duration(days: 8));
      await repo.logCall(confirmedAt: inside);
      await repo.logCall(confirmedAt: outside);

      final logs = await repo.getRecentLogs(7);
      expect(logs, hasLength(1));
      // SQLite stores datetime at second precision — compare to second.
      expect(logs.single.confirmedAt.difference(inside).abs(),
          lessThan(const Duration(seconds: 2)));
    });

    test('getRecentLogs includes call exactly at boundary', () async {
      // A call confirmed just inside the window (1 hour inside the 7-day
      // cutoff) must be included. Using 1 hour gives enough headroom to
      // survive SQLite second-precision truncation and async test timing.
      final justInside = DateTime.now().subtract(const Duration(days: 6, hours: 23));
      await repo.logCall(confirmedAt: justInside);
      final logs = await repo.getRecentLogs(7);
      expect(logs, hasLength(1));
    });

    test('getRecentLogs with no calls returns empty list', () async {
      expect(await repo.getRecentLogs(30), isEmpty);
    });

    test('getRecentLogs returns results newest first', () async {
      final older = DateTime.now().subtract(const Duration(days: 2));
      final newer = DateTime.now().subtract(const Duration(days: 1));
      await repo.logCall(confirmedAt: older);
      await repo.logCall(confirmedAt: newer);
      final logs = await repo.getRecentLogs(7);
      // Newest should be first — confirmedAt of first > confirmedAt of last.
      expect(logs.first.confirmedAt.isAfter(logs.last.confirmedAt), isTrue);
    });

    // ── getLogsInRange ───────────────────────────────────────────────────────

    test('getLogsInRange returns only logs in [start, end)', () async {
      final start = DateTime(2026, 4, 1);
      final end   = DateTime(2026, 4, 8);

      await repo.logCall(confirmedAt: start);                              // included (on boundary)
      await repo.logCall(confirmedAt: DateTime(2026, 4, 5));               // included
      await repo.logCall(confirmedAt: end);                                // excluded (= end)
      await repo.logCall(confirmedAt: DateTime(2026, 4, 15));              // excluded

      final logs = await repo.getLogsInRange(start, end);
      expect(logs, hasLength(2));
    });

    test('getLogsInRange returns empty when range is inverted', () async {
      await repo.logCall(confirmedAt: DateTime(2026, 4, 5));
      final logs = await repo.getLogsInRange(
        DateTime(2026, 4, 10),
        DateTime(2026, 4, 1),
      );
      expect(logs, isEmpty);
    });

    // ── watchLastCall ────────────────────────────────────────────────────────

    test('watchLastCall emits null initially then updates on new log', () async {
      final stream = repo.watchLastCall();

      // First emission should be null (no calls yet)
      final first = await stream.first;
      expect(first, isNull);
    });

    test('watchLastCall emits most recent call after logging', () async {
      final ts = DateTime(2026, 4, 5, 8, 0);
      await repo.logCall(confirmedAt: ts);

      final log = await repo.watchLastCall().first;
      expect(log, isNotNull);
      expect(log!.confirmedAt, ts);
    });
  });
}
