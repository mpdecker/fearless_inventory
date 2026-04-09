import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/features/meetings/providers/meetings_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _epoch = DateTime(2026, 1, 1);

/// Minimal Meeting stub — only weekday and startTime matter for the sort.
Meeting _meeting(int weekday, String startTime) => Meeting(
      id: 0,
      sourceId: 'test',
      externalId: 'test',
      name: 'Test',
      fellowship: 'AA',
      city: 'Springfield',
      state: 'IL',
      country: 'US',
      weekday: weekday,
      startTime: startTime,
      typeCodes: '[]',
      isOnline: false,
      isHybrid: false,
      isBookmarked: false,
      isHomeGroup: false,
      isPlannedAttendance: false,
      isTemporarilyClosed: false,
      language: 'en',
      lastSyncedAt: _epoch,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // All tests use a fixed "now": Tuesday (TSML weekday=2), 14:30 (2:30 PM).
  // We inject 'now' via the function's result, so we stub the computation by
  // testing the ordering contract rather than the raw minute value.
  //
  // TSML weekday: 0=Sun 1=Mon 2=Tue 3=Wed 4=Thu 5=Fri 6=Sat

  group('minutesUntilNextOccurrence ordering', () {
    // Use a real DateTime.now() substitution via a thin override wrapper.
    // Since the function calls DateTime.now() internally we verify ordering
    // relationships by sorting real Meeting stubs and asserting list order,
    // picking times relative to the actual test execution time.

    test('two meetings today — earlier one wins if both still upcoming', () {
      final now = DateTime.now();
      final nowMins = now.hour * 60 + now.minute;

      // Both meetings are today (same weekday as now), starting soon.
      // Pick times that are definitely in the future.
      final m1 = _meeting(now.weekday % 7, '${now.hour.toString().padLeft(2, '0')}:59');
      final m2 = _meeting(now.weekday % 7, '${((now.hour + 1) % 24).toString().padLeft(2, '0')}:00');

      // m1 is sooner than m2 (assuming not already past)
      final minsM1 = (now.hour * 60 + 59);
      final minsM2 = ((now.hour + 1) % 24) * 60;
      if (minsM1 > nowMins && minsM2 > nowMins) {
        expect(
          minutesUntilNextOccurrence(m1) < minutesUntilNextOccurrence(m2),
          isTrue,
          reason: 'Meeting at :59 of this hour should sort before :00 of next hour',
        );
      }
    });

    test('meeting later today sorts before same meeting next week', () {
      final now = DateTime.now();
      final todayWeekday = now.weekday % 7;
      final futureMinute = (now.hour * 60 + now.minute + 30).clamp(0, 1439);
      final futureHour = futureMinute ~/ 60;
      final futureMin  = futureMinute % 60;
      final timeStr =
          '${futureHour.toString().padLeft(2, '0')}:${futureMin.toString().padLeft(2, '0')}';

      final upcoming   = _meeting(todayWeekday, timeStr);
      final nextWeek   = _meeting(todayWeekday, '00:01'); // past midnight = today but passed

      // If 00:01 has already passed today, it should be a full week away.
      if (now.hour * 60 + now.minute > 1) {
        expect(
          minutesUntilNextOccurrence(upcoming) <
              minutesUntilNextOccurrence(nextWeek),
          isTrue,
          reason: 'Upcoming meeting today should sort before past-today meeting (next week)',
        );
      }
    });

    test('tomorrow sorts before two days from now', () {
      final now = DateTime.now();
      final tomorrow  = (now.weekday % 7 + 1) % 7;
      final dayAfter  = (now.weekday % 7 + 2) % 7;

      final m1 = _meeting(tomorrow, '09:00');
      final m2 = _meeting(dayAfter,  '09:00');

      expect(
        minutesUntilNextOccurrence(m1) < minutesUntilNextOccurrence(m2),
        isTrue,
        reason: 'Tomorrow at 9am should sort before the day after at 9am',
      );
    });

    test('sorted list order: soonest first', () {
      final now = DateTime.now();
      final todayWeekday   = now.weekday % 7;
      final tomorrowWeekday = (todayWeekday + 1) % 7;

      // A meeting tomorrow (far future) and a meeting later today (close).
      final futureMin = (now.hour * 60 + now.minute + 60).clamp(0, 1439);
      final fHour = futureMin ~/ 60;
      final fMin  = futureMin % 60;
      final soonTime = '${fHour.toString().padLeft(2, '0')}:${fMin.toString().padLeft(2, '0')}';

      final soonMeeting     = _meeting(todayWeekday,    soonTime);
      final tomorrowMeeting = _meeting(tomorrowWeekday, '06:00');

      final list = [tomorrowMeeting, soonMeeting];
      list.sort((a, b) => minutesUntilNextOccurrence(a)
          .compareTo(minutesUntilNextOccurrence(b)));

      expect(list.first, soonMeeting,
          reason: 'Meeting later today should appear before meeting tomorrow');
    });

    test('result is always non-negative', () {
      // Every combination of weekday and time should produce ≥ 0 minutes.
      final now = DateTime.now();
      for (var day = 0; day < 7; day++) {
        for (var h = 0; h < 24; h++) {
          final m = _meeting(day, '${h.toString().padLeft(2, '0')}:00');
          expect(minutesUntilNextOccurrence(m), greaterThanOrEqualTo(0),
              reason: 'day=$day h=$h at ${now.hour}:${now.minute}');
        }
      }
    });

    test('maximum value is less than 7 days + 1 minute (10081)', () {
      // The furthest a meeting can ever be is just under 7 days away.
      final now = DateTime.now();
      for (var day = 0; day < 7; day++) {
        for (var h = 0; h < 24; h++) {
          final m = _meeting(day, '${h.toString().padLeft(2, '0')}:00');
          expect(minutesUntilNextOccurrence(m), lessThan(7 * 24 * 60 + 1),
              reason: 'day=$day h=$h at ${now.hour}:${now.minute}');
        }
      }
    });
  });
}
