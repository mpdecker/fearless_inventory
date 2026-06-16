// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/native.dart';
import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/providers/sobriety_provider.dart';
import 'package:fearless_inventory/features/meetings/services/meeting_sync_service.dart';
import 'package:fearless_inventory/features/meetings/services/location_service.dart';
import 'package:fearless_inventory/main.dart';

void main() {
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
        child: const FearlessInventoryApp(showOnboarding: false),
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
