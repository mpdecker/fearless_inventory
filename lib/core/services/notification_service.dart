import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Notification IDs (avoid cancelAll so multiple reminders can coexist).
  static const int idDailyReview = 101;
  static const int idBedtimeMeditation = 102;

  /// Default times — keep in sync when rescheduling after daily review save.
  static const int defaultDailyReviewHour = 21;
  static const int defaultDailyReviewMinute = 0;
  static const int defaultBedtimeHour = 22;
  static const int defaultBedtimeMinute = 30;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    
    // Automatically request permissions on initialization
    await requestPermissions();
  }

  /// Requests permissions for both Notifications and Exact Alarms (Android 13+)
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // 1. Request standard notification permission (Android 13+)
      await Permission.notification.request();

      // 2. Request Exact Alarm permission (Android 13+)
      // This is required to fix the "exact_alarms_not_permitted" exception
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    }
  }

  Future<void> scheduleDailyReviewReminder({required int hour, required int minute}) async {
    // Check permission again before scheduling to avoid crash
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isDenied) {
        print("Cannot schedule: Exact Alarm permission denied.");
        return;
      }
    }

    await _notifications.zonedSchedule(
      idDailyReview,
      "Daily Review",
      "Time for your 10th step. Keep your side of the street clean!",
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_review_channel',
          'Daily Review Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Correct mode for exact timing
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily at this time
    );
  }

  Future<void> scheduleBedtimeMeditationReminder({required int hour, required int minute}) async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isDenied) {
        return;
      }
    }

    await _notifications.zonedSchedule(
      idBedtimeMeditation,
      "Before bed meditation",
      "Wind down with a short reflection and rest.",
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bedtime_meditation_channel',
          'Before Bed Meditation',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
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

  Future<void> cancelAll() async => await _notifications.cancelAll();
}