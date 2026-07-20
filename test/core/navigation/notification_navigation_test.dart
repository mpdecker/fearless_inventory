import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/navigation/notification_navigation.dart';
import 'package:fearless_inventory/core/navigation/root_navigator.dart';
import 'package:fearless_inventory/core/services/notification_service.dart';
import 'package:fearless_inventory/features/review/daily_review_hub_screen.dart';
import 'package:fearless_inventory/features/sponsor_call/sponsor_call_screen.dart';
import 'package:fearless_inventory/features/stepwork/bedtime_meditation_screen.dart';

import '../../data/repositories/repository_test_support.dart';
import '../../support/widget_encrypted_db_binding.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpMaterialAppWithDatabase(
    WidgetTester tester, {
    required AppDatabase db,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          navigatorKey: rootNavigatorKey,
          home: const Scaffold(body: Text('home')),
        ),
      ),
    );
    // Attach [NavigatorState] so `navigateFromNotificationTap` can push.
    await tester.pump();
  }

  testWidgets('daily review notification pushes DailyReviewHubScreen',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final env = await openTempEncryptedDbForWidgetTest(tester, 'fi_nav_review_');
    addTearDown(() => disposeTempDb(db: env.db, dir: env.dir, dbFile: env.dbFile));

    await pumpMaterialAppWithDatabase(tester, db: env.db);

    navigateFromNotificationTap(
      const NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotification,
        id: NotificationService.idDailyReview,
      ),
    );

    await pumpSteadyNavigationFrames(tester);
    expect(find.byType(DailyReviewHubScreen), findsOneWidget);
    await resetWidgetBindingAfterDriftStreams(
      tester,
      rootNavigator: rootNavigatorKey,
    );
  });

  testWidgets('bedtime notification pushes BedtimeMeditationScreen',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final env = await openTempEncryptedDbForWidgetTest(tester, 'fi_nav_bed_');
    addTearDown(() => disposeTempDb(db: env.db, dir: env.dir, dbFile: env.dbFile));

    await pumpMaterialAppWithDatabase(tester, db: env.db);

    navigateFromNotificationTap(
      const NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotification,
        id: NotificationService.idBedtimeMeditation,
      ),
    );

    await pumpSteadyNavigationFrames(tester);
    expect(find.byType(BedtimeMeditationScreen), findsOneWidget);
    await resetWidgetBindingAfterDriftStreams(
      tester,
      rootNavigator: rootNavigatorKey,
    );
  });

  testWidgets('sponsor call notification pushes SponsorCallScreen',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final env =
        await openTempEncryptedDbForWidgetTest(tester, 'fi_nav_sponsor_');
    addTearDown(() => disposeTempDb(db: env.db, dir: env.dir, dbFile: env.dbFile));

    await pumpMaterialAppWithDatabase(tester, db: env.db);

    navigateFromNotificationTap(
      const NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotification,
        id: NotificationService.idSponsorCall,
      ),
    );

    await pumpSteadyNavigationFrames(tester);
    expect(find.byType(SponsorCallScreen), findsOneWidget);
    await resetWidgetBindingAfterDriftStreams(
      tester,
      rootNavigator: rootNavigatorKey,
    );
  });

  testWidgets('unknown notification id does not push a route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: rootNavigatorKey,
        home: const Scaffold(body: Text('home')),
      ),
    );

    navigateFromNotificationTap(
      const NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotification,
        id: 99999,
      ),
    );

    await tester.pump();
    expect(find.text('home'), findsOneWidget);
    expect(find.byType(DailyReviewHubScreen), findsNothing);
  });
}
