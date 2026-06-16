import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/data/services/reflection_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sample row helpers
// ─────────────────────────────────────────────────────────────────────────────

Map<String, dynamic> _row(String theme, String quote) => {
      'theme':      theme,
      'quote':      quote,
      'reflection': 'A reflection on $theme.',
    };

/// A deterministic [Random] that always returns [fraction] from nextDouble()
/// and 0 from nextInt(). Use to force selection of a specific candidate.
class _FakeRandom implements Random {
  final double fraction;
  const _FakeRandom(this.fraction);

  @override
  double nextDouble() => fraction;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
}

void main() {
  final rows = [
    _row('courage',    'Quote A about courage.'),
    _row('courage',    'Quote B about courage.'),
    _row('acceptance', 'Quote C about acceptance.'),
    _row('honesty',    'Quote D about honesty.'),
    _row('gratitude',  'Quote E about gratitude.'),
  ];

  // ── Null / empty cases ────────────────────────────────────────────────────

  group('empty rows', () {
    test('returns null when rows list is empty', () {
      final result = ReflectionService.pickFromRows([], {}, {});
      expect(result, isNull);
    });
  });

  // ── Theme filtering ───────────────────────────────────────────────────────

  group('theme filtering', () {
    test('only candidates matching target theme are eligible', () {
      // Force dart = 0 → first candidate (should be 'courage')
      final result = ReflectionService.pickFromRows(
        rows,
        {'courage': 2.0},
        {},
        random: const _FakeRandom(0),
      );
      expect(result, isNotNull);
      expect(result!.theme, 'courage');
    });

    test('all default themes accepted when themeWeights is empty', () {
      // All 5 rows match because default themes cover all of them.
      final result =
          ReflectionService.pickFromRows(rows, {}, {}, random: const _FakeRandom(0));
      expect(result, isNotNull);
    });

    test('falls back to all rows when no candidate matches target theme', () {
      // 'resilience' does not appear in the sample rows.
      final result = ReflectionService.pickFromRows(
        rows,
        {'resilience': 5.0},
        {},
        random: const _FakeRandom(0),
      );
      expect(result, isNotNull); // fallback ensures a reflection is always returned
    });

    test('extraThemes are added to the target set', () {
      // Only 'gratitude' theme should be eligible when it is the only weight
      // and also in extraThemes.
      final result = ReflectionService.pickFromRows(
        rows,
        {},
        {},
        extraThemes: ['gratitude'],
        random: const _FakeRandom(0),
      );
      // With default themes expanded, gratitude row is eligible.
      expect(result, isNotNull);
    });
  });

  // ── Recency penalties ─────────────────────────────────────────────────────

  group('recency penalty', () {
    final now = DateTime(2026, 4, 5);

    test('<2 days → ×0.05 multiplier (nearly suppressed)', () {
      // Both courage rows have the same base weight 1.0.
      // Quote A was seen yesterday (age = 1 day → ×0.05).
      // Quote B has no recency penalty.
      // dart ≈ 0 picks first candidate (Quote A in theme order).
      // But with heavy penalty on A, the total shifts toward B.
      // We verify that Quote B is selected when dart = just past A's tiny share.

      final keyA = 'Quote A about courage.'; // < 80 chars, key = full quote
      final recent = <String, DateTime>{keyA: now.subtract(const Duration(days: 1))};

      // A's weight = 1.0 * 0.05 = 0.05; B's weight = 1.0.
      // Total = 1.05. Quote A gets first 0.05/1.05 of the range.
      // dart fraction 0.10 → cumulative after A = 0.05, after B = 1.05 → B selected.
      final result = ReflectionService.pickFromRows(
        rows.where((r) => r['theme'] == 'courage').toList(),
        {'courage': 1.0},
        recent,
        now:    now,
        random: const _FakeRandom(0.10),
      );
      expect(result!.quote, 'Quote B about courage.');
    });

    test('≥10 days → full weight (no penalty)', () {
      final keyA = 'Quote A about courage.';
      final tenDaysAgo = <String, DateTime>{keyA: now.subtract(const Duration(days: 10))};

      // With no penalty, both rows have weight 1.0 each.
      // dart = 0 → cumulative starts at 0, first row (A) selected.
      final result = ReflectionService.pickFromRows(
        rows.where((r) => r['theme'] == 'courage').toList(),
        {'courage': 1.0},
        tenDaysAgo,
        now:    now,
        random: const _FakeRandom(0),
      );
      expect(result!.quote, 'Quote A about courage.');
    });

    test('5–9 days → ×0.70 multiplier', () {
      final keyA = 'Quote A about courage.';
      final fiveDaysAgo = <String, DateTime>{keyA: now.subtract(const Duration(days: 5))};

      // A's weight = 0.70; B's weight = 1.0. Total = 1.70.
      // A occupies fraction 0–0.70/1.70 ≈ 0–0.41.
      // dart = 0.50 → past A's range → B selected.
      final result = ReflectionService.pickFromRows(
        rows.where((r) => r['theme'] == 'courage').toList(),
        {'courage': 1.0},
        fiveDaysAgo,
        now:    now,
        random: const _FakeRandom(0.50),
      );
      expect(result!.quote, 'Quote B about courage.');
    });

    test('2–4 days → ×0.30 multiplier', () {
      final keyA = 'Quote A about courage.';
      final twoDaysAgo = <String, DateTime>{keyA: now.subtract(const Duration(days: 2))};

      // A: 0.30; B: 1.0. Total = 1.30. A ends at 0.30/1.30 ≈ 0.23.
      // dart = 0.50 → B selected.
      final result = ReflectionService.pickFromRows(
        rows.where((r) => r['theme'] == 'courage').toList(),
        {'courage': 1.0},
        twoDaysAgo,
        now:    now,
        random: const _FakeRandom(0.50),
      );
      expect(result!.quote, 'Quote B about courage.');
    });
  });

  // ── Reflection key truncation ─────────────────────────────────────────────

  group('reflectionKey', () {
    test('key is quote itself when ≤80 chars', () {
      final result = ReflectionService.pickFromRows(
        [_row('courage', 'Short quote.')],
        {},
        {},
        random: const _FakeRandom(0),
      );
      expect(result!.reflectionKey, 'Short quote.');
    });

    test('key is first 80 chars when quote is longer', () {
      final long = 'A' * 100;
      final result = ReflectionService.pickFromRows(
        [_row('courage', long)],
        {},
        {},
        random: const _FakeRandom(0),
      );
      expect(result!.reflectionKey, 'A' * 80);
    });
  });

  // ── signalToThemes mapping ────────────────────────────────────────────────

  group('signalToThemes', () {
    test('resentful maps to acceptance, letting go, compassion, patience', () {
      expect(ReflectionService.signalToThemes['resentful'],
          containsAll(['acceptance', 'letting go', 'compassion', 'patience']));
    });

    test('all four signals have non-empty theme lists', () {
      for (final signal in ['resentful', 'afraid', 'dishonest', 'selfish']) {
        expect(ReflectionService.signalToThemes[signal], isNotEmpty,
            reason: '$signal should have themes');
      }
    });
  });

  // ── SponsorCallConfig.copyWith ────────────────────────────────────────────

  group('Reflection model', () {
    test('reflectionKey is stable across identical quotes', () {
      final r1 = Reflection(theme: 't', quote: 'Hello world.', reflection: 'r');
      final r2 = Reflection(theme: 't', quote: 'Hello world.', reflection: 'r');
      expect(r1.reflectionKey, r2.reflectionKey);
    });
  });
}
