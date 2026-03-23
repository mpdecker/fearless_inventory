import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/database/database.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Reminder offset options
// ─────────────────────────────────────────────────────────────────────────────

enum ReminderOffset {
  fifteenMin(15, '15 min before'),
  thirtyMin(30, '30 min before'),
  oneHour(60, '1 hour before'),
  twoHours(120, '2 hours before');

  final int minutes;
  final String label;
  const ReminderOffset(this.minutes, this.label);
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final meetingNotificationServiceProvider =
    Provider<MeetingNotificationService>((ref) {
  return MeetingNotificationService();
});

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

/// Manages per-meeting reminder notifications.
///
/// Notification ID allocation (avoids clashing with app-level IDs 101/102):
///   id = 10_000 + (meetingId * 4) + ReminderOffset.index
class MeetingNotificationService {
  // Shares the same underlying platform channel as NotificationService,
  // but uses a separate Dart wrapper instance.  The plugin is idempotent
  // after the first initialize() call.
  static final _plugin = FlutterLocalNotificationsPlugin();

  static int _idFor(int meetingId, ReminderOffset offset) =>
      10000 + meetingId * 4 + offset.index;

  // ── Schedule ─────────────────────────────────────────────────────────────

  /// Schedule a *weekly recurring* reminder [offset] before each occurrence
  /// of [meeting], starting from [nextOccurrence].
  ///
  /// Uses [DateTimeComponents.dayOfWeekAndTime] so the OS repeats it every
  /// week without the app needing to reschedule.
  ///
  /// Returns `false` if the first trigger would be in the past (nothing
  /// scheduled in that case).
  Future<bool> scheduleWeeklyReminder(
    Meeting meeting,
    DateTime nextOccurrence,
    ReminderOffset offset,
  ) async {
    final triggerTime =
        nextOccurrence.subtract(Duration(minutes: offset.minutes));
    if (triggerTime.isBefore(DateTime.now())) return false;

    final tzTime = tz.TZDateTime.from(triggerTime, tz.local);
    final id = _idFor(meeting.id, offset);

    try {
      await _plugin.zonedSchedule(
        id,
        '${meeting.name} — starting soon',
        '${offset.label} · ${meeting.city}',
        tzTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'meeting_reminders',
            'Meeting Reminders',
            channelDescription: 'Reminders before your scheduled meetings',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // Repeat weekly at the same day-of-week + time
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Cancel ───────────────────────────────────────────────────────────────

  /// Cancel all reminder offsets for a meeting.
  Future<void> cancelAll(int meetingId) async {
    for (final o in ReminderOffset.values) {
      await _plugin.cancel(_idFor(meetingId, o));
    }
  }

  /// Cancel one specific reminder offset.
  Future<void> cancel(int meetingId, ReminderOffset offset) async {
    await _plugin.cancel(_idFor(meetingId, offset));
  }
}
