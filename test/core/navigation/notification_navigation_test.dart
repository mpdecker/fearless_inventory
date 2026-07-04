import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/native.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/navigation/notification_navigation.dart';
import 'package:fearless_inventory/core/navigation/root_navigator.dart';
import 'package:fearless_inventory/core/services/notification_service.dart';
import 'package:fearless_inventory/features/review/daily_review_hub_screen.dart';
import 'package:fearless_inventory/features/sponsor_call/sponsor_call_screen.dart';
import 'package:fearless_inventory/features/stepwork/bedtime_meditation_screen.dart';

import '../../data/repositories/repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpWithDb(
    WidgetTester tester, {
    required AppDatabase db,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            ref.onDispose(() {});
            return db;
          }),
        ],
        child: MaterialApp(
          navigatorKey: rootNavigatorKey,
          home: const Scaffold(body: Text('home')),
        ),
      ),
    );
  }

  testWidgets('daily review notification pushes DailyReviewHubScreen',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase.testing(NativeDatabase.memory());
    addTearDown(() => db.close());

    await pumpWithDb(tester, db: db);

    navigateFromNotificationTap(
      const NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotification,
        id: NotificationService.idDailyReview,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(DailyReviewHubScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('bedtime notification pushes BedtimeMeditationScreen',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase.testing(NativeDatabase.memory());
    addTearDown(() => db.close());

    await pumpWithDb(tester, db: db);

    navigateFromNotificationTap(
      const NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotification,
        id: NotificationService.idBedtimeMeditation,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(BedtimeMeditationScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('sponsor call notification pushes SponsorCallScreen',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase.testing(NativeDatabase.memory());
    addTearDown(() => db.close());

    await pumpWithDb(tester, db: db);

    navigateFromNotificationTap(
      const NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotification,
        id: NotificationService.idSponsorCall,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SponsorCallScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
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

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
