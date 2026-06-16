import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fearless_inventory/core/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService (iOS target)', () {
    const channel =
        MethodChannel('dexterous.com/flutter/local_notifications');

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'initialize':
            final args = call.arguments as Map<dynamic, dynamic>?;
            expect(args?['requestProvisionalPermission'], true);
            expect(args?['requestAlertPermission'], true);
            return true;
          case 'getNotificationAppLaunchDetails':
            return null;
          case 'zonedSchedule':
            return null;
          default:
            return null;
        }
      });
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('init completes without throwing', () async {
      final svc = NotificationService();
      await expectLater(svc.init(), completes);
    });

    test('scheduling daily reminders completes without throwing', () async {
      final svc = NotificationService();
      await svc.init();
      await expectLater(
        svc.scheduleDailyReviewReminder(
          hour: NotificationService.defaultDailyReviewHour,
          minute: NotificationService.defaultDailyReviewMinute,
        ),
        completes,
      );
      await expectLater(
        svc.scheduleBedtimeMeditationReminder(
          hour: NotificationService.defaultBedtimeHour,
          minute: NotificationService.defaultBedtimeMinute,
        ),
        completes,
      );
    });
  });

  group('NotificationService (no Android-only permission channel)', () {
    const notificationsChannel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    const permissionsChannel =
        MethodChannel('flutter.baseflow.com/permissions/methods');

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(notificationsChannel, (call) async {
        switch (call.method) {
          case 'initialize':
            return true;
          case 'getNotificationAppLaunchDetails':
            return null;
          default:
            return null;
        }
      });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(permissionsChannel, (call) async {
        fail(
          'permission_handler must not be invoked on iOS from NotificationService.init',
        );
      });
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(notificationsChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(permissionsChannel, null);
    });

    test('init does not call permission_handler on iOS', () async {
      await NotificationService().init();
    });
  });
}
