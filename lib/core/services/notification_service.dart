import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Notification IDs (avoid cancelAll so multiple reminders can coexist).
  static const int idDailyReview = 101;
  static const int idBedtimeMeditation = 102;

  static const String _payloadDailyReview = 'daily_review';
  static const String _payloadBedtime = 'bedtime_meditation';

  /// Default times — keep in sync when rescheduling after daily review save.
  static const int defaultDailyReviewHour = 21;
  static const int defaultDailyReviewMinute = 0;
  static const int defaultBedtimeHour = 22;
  static const int defaultBedtimeMinute = 30;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  DidReceiveNotificationResponseCallback? _onNotificationResponse;
  NotificationResponse? _pendingLaunchResponse;

  /// Call once after the first frame when [MaterialApp] is mounted (and after
  /// onboarding if you only want post-onboarding routing).
  void processPendingLaunchNotification() {
    final pending = _pendingLaunchResponse;
    if (pending == null) return;
    _pendingLaunchResponse = null;
    _onNotificationResponse?.call(pending);
  }

  Future<void> init({
    DidReceiveNotificationResponseCallback? onNotificationResponse,
  }) async {
    _onNotificationResponse = onNotificationResponse;

    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS has no notification "channels" (Android-only). Provisional
    // authorization (iOS 12+) avoids a blocking permission dialog on first
    // launch; reminders appear quietly in Notification Center until the user
    // promotes them in Settings.
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestProvisionalPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        _onNotificationResponse?.call(response);
      },
    );

    final launchDetails = await _notifications.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchDetails?.notificationResponse != null) {
      _pendingLaunchResponse = launchDetails!.notificationResponse;
    }

    await requestPermissions();
  }

  /// Android: post notifications (13+) and exact alarms. iOS: permissions are
  /// requested during [initialize] via [DarwinInitializationSettings]; there is
  /// no separate exact-alarm permission.
  Future<void> requestPermissions() async {
    if (!Platform.isAndroid) return;

    await Permission.notification.request();

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> scheduleDailyReviewReminder({
    required int hour,
    required int minute,
  }) async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isDenied) {
        debugPrint('Cannot schedule daily review: exact alarm permission denied.');
        return;
      }
    }

    try {
      await _notifications.zonedSchedule(
        idDailyReview,
        'Daily Review',
        'Time for your 10th step. Keep your side of the street clean!',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_review_channel',
            'Daily Review Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
        payload: _payloadDailyReview,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, st) {
      debugPrint('scheduleDailyReviewReminder failed: $e\n$st');
    }
  }

  Future<void> scheduleBedtimeMeditationReminder({
    required int hour,
    required int minute,
  }) async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isDenied) {
        debugPrint(
            'Cannot schedule bedtime meditation: exact alarm permission denied.');
        return;
      }
    }

    try {
      await _notifications.zonedSchedule(
        idBedtimeMeditation,
        'Before bed meditation',
        'Wind down with a short reflection and rest.',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'bedtime_meditation_channel',
            'Before Bed Meditation',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
        payload: _payloadBedtime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, st) {
      debugPrint('scheduleBedtimeMeditationReminder failed: $e\n$st');
    }
  }

  Future<void> cancelNotification(int id) => _notifications.cancel(id);

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelAll() async => _notifications.cancelAll();
}
