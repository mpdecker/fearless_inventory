import 'dart:io';

import 'package:drift/native.dart';
import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/providers/sobriety_provider.dart';
import 'package:fearless_inventory/features/meetings/services/location_service.dart';
import 'package:fearless_inventory/features/meetings/services/meeting_sync_service.dart';
import 'package:fearless_inventory/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testKey =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

  testWidgets('databaseProvider override supplies AppDatabase to UI',
      (WidgetTester tester) async {
    final dir = Directory.systemTemp.createTempSync('fi_widget_');
    final dbFile = File(p.join(dir.path, 'widget.db'));
    final db = AppDatabase.forTesting(dbFile, testKey);
    addTearDown(() async {
      await db.close();
      try {
        await dir.delete(recursive: true);
      } catch (_) {}
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            ref.onDispose(() {});
            return db;
          }),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              ref.watch(databaseProvider);
              return const Text('db_ok');
            },
          ),
        ),
      ),
    );

    expect(find.text('db_ok'), findsOneWidget);
  });

  testWidgets('app boots', (WidgetTester tester) async {
    // Use an in-memory Drift database — no encryption key, no file I/O.
    final db = AppDatabase.testing(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Inject the in-memory database.
          databaseProvider.overrideWithValue(db),
          // Empty adapter list — no network calls in tests.
          meetingAdaptersProvider.overrideWithValue([]),
          // Stub location providers — Geolocator blocks on the headless runner.
          activeLocationProvider.overrideWith((ref) => null),
          userLocationProvider.overrideWith((ref) => null),
          geocodedLocationProvider.overrideWith((ref) => null),
          // Stub sobriety provider — FlutterSecureStorage not available in tests.
          sobrietyDateProvider.overrideWith(
            (ref) => SobrietyDateNotifier.testing(),
          ),
        ],
        child: const FearlessInventoryApp(initialOnboardingComplete: true),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);

    // Replace the tree with an empty widget so Riverpod disposes its container
    // and cancels all stream subscriptions.
    await tester.pumpWidget(const SizedBox());

    // Flush zero-duration timers that Drift's StreamQueryStore schedules
    // synchronously on stream cancellation — satisfies flutter_test's
    // timersPending invariant.
    await tester.pump(Duration.zero);
  });
}
