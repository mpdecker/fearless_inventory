import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/features/review/providers/streak_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper — builds a DailyReview without needing a real database.
// ─────────────────────────────────────────────────────────────────────────────

DailyReview _review({
  required int id,
  required DateTime date,
  bool resentful = false,
  bool selfish   = false,
  bool dishonest = false,
  bool afraid    = false,
}) =>
    DailyReview(
      id:            id,
      date:          date,
      wasResentful:  resentful,
      wasSelfish:    selfish,
      wasDishonest:  dishonest,
      wasAfraid:     afraid,
      reviewType:    'nightly',
      createdAt:     date,
    );

/// Midnight for [date], optionally offset by [days].
DateTime _day(DateTime base, {int offset = 0}) {
  final d = base.subtract(Duration(days: offset));
  return DateTime(d.year, d.month, d.day);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Fix "today" so tests are deterministic regardless of when they run.
  final today     = DateTime(2026, 4, 5); // Saturday
  final yesterday = today.subtract(const Duration(days: 1));

  group('calculateStreak', () {
    // ── Edge cases ─────────────────────────────────────────────────────────

    test('empty list → 0', () {
      expect(calculateStreak([], today), 0);
    });

    test('single review far in the past → 0 (gap to today)', () {
      final review = _review(id: 1, date: today.subtract(const Duration(days: 5)));
      expect(calculateStreak([review], today), 0);
    });

    test('review only yesterday → 0 (today not covered)', () {
      final review = _review(id: 1, date: yesterday);
      expect(calculateStreak([review], today), 0);
    });

    // ── Single-day streaks ──────────────────────────────────────────────────

    test('review today → streak 1', () {
      final review = _review(id: 1, date: today);
      expect(calculateStreak([review], today), 1);
    });

    // ── Multi-day streaks ───────────────────────────────────────────────────

    test('today + yesterday → streak 2', () {
      final reviews = [
        _review(id: 1, date: today),
        _review(id: 2, date: yesterday),
      ];
      expect(calculateStreak(reviews, today), 2);
    });

    test('7 consecutive days → streak 7', () {
      final reviews = List.generate(
        7,
        (i) => _review(id: i, date: today.subtract(Duration(days: i))),
      );
      expect(calculateStreak(reviews, today), 7);
    });

    test('gap on day 3 stops streak at 2', () {
      // today, yesterday, but NOT 2 days ago, then 3 days ago
      final reviews = [
        _review(id: 1, date: today),
        _review(id: 2, date: yesterday),
        _review(id: 3, date: today.subtract(const Duration(days: 3))),
      ];
      expect(calculateStreak(reviews, today), 2);
    });

    // ── Multiple reviews on same day ────────────────────────────────────────

    test('multiple reviews same day count as one streak day', () {
      final reviews = [
        _review(id: 1, date: today),
        _review(id: 2, date: today),
        _review(id: 3, date: today),
      ];
      expect(calculateStreak(reviews, today), 1);
    });

    test('multiple reviews on today + yesterday each = streak 2', () {
      final reviews = [
        _review(id: 1, date: today),
        _review(id: 2, date: today),
        _review(id: 3, date: yesterday),
        _review(id: 4, date: yesterday),
      ];
      expect(calculateStreak(reviews, today), 2);
    });

    // ── Unsorted input ──────────────────────────────────────────────────────

    test('unsorted reviews are handled correctly', () {
      final reviews = [
        _review(id: 3, date: today.subtract(const Duration(days: 2))),
        _review(id: 1, date: today),
        _review(id: 2, date: yesterday),
      ];
      expect(calculateStreak(reviews, today), 3);
    });

    // ── Streak that does not include today ──────────────────────────────────

    test('streak anchored to yesterday (refNow = yesterday)', () {
      // If we evaluate as-of yesterday, yesterday + day before = streak 2
      final reviews = [
        _review(id: 1, date: yesterday),
        _review(id: 2, date: yesterday.subtract(const Duration(days: 1))),
      ];
      expect(calculateStreak(reviews, yesterday), 2);
    });

    // ── Long streaks ────────────────────────────────────────────────────────

    test('30 consecutive days → streak 30', () {
      final reviews = List.generate(
        30,
        (i) => _review(id: i, date: today.subtract(Duration(days: i))),
      );
      expect(calculateStreak(reviews, today), 30);
    });

    test('31 days with gap on day 15 → streak 14', () {
      // days 0–13: covered; day 14: gap; days 15–30: covered
      final reviews = [
        ...List.generate(14, (i) => _review(id: i, date: today.subtract(Duration(days: i)))),
        ...List.generate(16, (i) => _review(id: 100 + i, date: today.subtract(Duration(days: 15 + i)))),
      ];
      expect(calculateStreak(reviews, today), 14);
    });

    // ── Streak is not confused by reviews from before a gap ─────────────────

    test('old streak in history does not inflate current streak', () {
      // Very old continuous block should not count
      final reviews = [
        _review(id: 1, date: today),
        // 10-day gap
        ...List.generate(5, (i) => _review(id: 10 + i, date: today.subtract(Duration(days: 11 + i)))),
      ];
      expect(calculateStreak(reviews, today), 1);
    });
  });
}
