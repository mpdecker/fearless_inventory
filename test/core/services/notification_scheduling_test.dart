import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the decision to schedule reminders **inexactly**.
///
/// `SCHEDULE_EXACT_ALARM` is a Play "sensitive" permission that is not granted
/// by default on Android 13+. The app previously declared it and skipped
/// scheduling entirely when it was denied, so users who never granted it
/// silently got no reminders. These tests fail if that combination returns.
void main() {
  final manifest =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
  final notificationService =
      File('lib/core/services/notification_service.dart').readAsStringSync();
  final meetingNotifications =
      File('lib/features/meetings/services/meeting_notification_service.dart')
          .readAsStringSync();

  test('the Android manifest does not request exact-alarm permissions', () {
    expect(manifest, isNot(contains('SCHEDULE_EXACT_ALARM')));
    expect(manifest, isNot(contains('USE_EXACT_ALARM')));
  });

  test('POST_NOTIFICATIONS is still declared', () {
    // Removing exact alarms must not take the notification permission with it.
    expect(manifest, contains('POST_NOTIFICATIONS'));
  });

  test('no scheduler uses an exact Android schedule mode', () {
    for (final source in [notificationService, meetingNotifications]) {
      expect(source, isNot(contains('AndroidScheduleMode.exact')));
      expect(source, isNot(contains('AndroidScheduleMode.alarmClock')));
    }
  });

  test('every scheduler still passes an inexact schedule mode', () {
    // One shared constant in NotificationService, one inline in the meetings
    // service; both must resolve to an inexact mode.
    expect(notificationService,
        contains('AndroidScheduleMode.inexactAllowWhileIdle'));
    expect(meetingNotifications,
        contains('AndroidScheduleMode.inexactAllowWhileIdle'));
  });

  test('reminders are not gated behind an exact-alarm permission check', () {
    // The old code returned early when Permission.scheduleExactAlarm was
    // denied, which silently disabled reminders.
    expect(notificationService, isNot(contains('Permission.scheduleExactAlarm')));
  });
}
