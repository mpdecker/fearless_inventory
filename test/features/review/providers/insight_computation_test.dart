import 'package:flutter/material.dart' show Icons;
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/features/review/providers/insight_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Builder helpers — create Drift data objects without a real database.
// ─────────────────────────────────────────────────────────────────────────────

DailyReview _review({
  int id = 1,
  DateTime? date,
  bool resentful = false,
  bool selfish   = false,
  bool dishonest = false,
  bool afraid    = false,
  String? notes,
  String? gratitude,
}) {
  final d = date ?? DateTime(2026, 4, 5);
  return DailyReview(
    id:           id,
    date:         d,
    wasResentful: resentful,
    wasSelfish:   selfish,
    wasDishonest: dishonest,
    wasAfraid:    afraid,
    notes:        notes,
    gratitude:    gratitude,
    reviewType:   'nightly',
    createdAt:    d,
  );
}

Resentment _resentment({
  int id = 1,
  String person  = 'Person',
  String affects = 'security',
  bool   flagged = false,
}) =>
    Resentment(
      id:            id,
      person:        person,
      cause:         'some cause',
      affects:       affects,
      myPart:        'my part',
      flagForReview: flagged,
      createdAt:     DateTime(2026, 4, 1),
    );

Fear _fear({int id = 1, bool flagged = false}) => Fear(
      id:            id,
      subject:       'some fear',
      why:           'why',
      myPart:        'my part',
      flagForReview: flagged,
      createdAt:     DateTime(2026, 4, 1),
    );

Harm _harm({int id = 1, bool flagged = false}) => Harm(
      id:            id,
      person:        'Harmed Person',
      conduct:       'conduct',
      myPart:        'my part',
      flagForReview: flagged,
      isAmendsDone:  false,
      createdAt:     DateTime(2026, 4, 1),
    );

Amend _amend({int id = 1, required String status}) => Amend(
      id:        id,
      person:    'Person',
      priority:  2,
      status:    status,
      createdAt: DateTime(2026, 1, 1),
    );

ShortcomingLog _shortcoming({
  int id = 1,
  String description = 'pride',
  DateTime? dateObserved,
}) =>
    ShortcomingLog(
      id:           id,
      description:  description,
      dateObserved: dateObserved ?? DateTime(2026, 4, 1),
    );

MeditationSession _session({
  int id = 1,
  DateTime? completedAt,
  int durationSeconds = 600,
}) =>
    MeditationSession(
      id:               id,
      sessionType:      'morning',
      reflectionTheme:  'courage',
      reflectionKey:    'key$id',
      durationSeconds:  durationSeconds,
      completedAt:      completedAt ?? DateTime(2026, 4, 5),
    );

JournalEntry _journalEntry({int id = 1, int? stepNumber}) => JournalEntry(
      id:         id,
      content:    'Some reflection text.',
      stepNumber: stepNumber,
      createdAt:  DateTime(2026, 4, 1),
      updatedAt:  DateTime(2026, 4, 1),
    );

Sponsee _sponsee({int id = 1, int? currentStep, bool isActive = true}) =>
    Sponsee(
      id:        id,
      name:      'Sam',
      isActive:  isActive,
      currentStep: currentStep,
      createdAt: DateTime(2026, 1, 1),
    );

// ─────────────────────────────────────────────────────────────────────────────
// Shorthand caller with all-empty defaults
// ─────────────────────────────────────────────────────────────────────────────

List<InsightCard> _insights({
  List<Resentment>       resentments        = const [],
  List<Fear>             fears              = const [],
  List<Harm>             harms              = const [],
  List<DailyReview>      reviews            = const [],
  List<Amend>            amends             = const [],
  List<ShortcomingLog>   shortcomings       = const [],
  List<MeditationSession> meditationSessions = const [],
  List<JournalEntry>     journalEntries     = const [],
  List<Sponsee>          sponsees           = const [],
}) =>
    computeInsights(
      resentments:        resentments,
      fears:              fears,
      harms:              harms,
      reviews:            reviews,
      amends:             amends,
      shortcomings:       shortcomings,
      meditationSessions: meditationSessions,
      journalEntries:     journalEntries,
      sponsees:           sponsees,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('computeInsights — empty state', () {
    test('returns the "story is just beginning" placeholder card', () {
      final cards = _insights();
      expect(cards, hasLength(1));
      expect(cards.first.title, 'Your story is just beginning');
      expect(cards.first.level, InsightLevel.neutral);
    });
  });

  // ── 1. Most threatened instinct ──────────────────────────────────────────

  group('insight 1 — most threatened instinct', () {
    test('single-affect resentment shows correct label', () {
      final cards = _insights(resentments: [
        _resentment(id: 1, affects: 'security'),
        _resentment(id: 2, affects: 'security'),
        _resentment(id: 3, affects: 'self_esteem'),
      ]);
      final card = cards.firstWhere((c) => c.title == 'Most threatened instinct');
      expect(card.value, 'Security');
      expect(card.level, InsightLevel.reflective);
    });

    test('multi-affect string counts every part', () {
      final cards = _insights(resentments: [
        _resentment(id: 1, affects: 'pride,security'),
        _resentment(id: 2, affects: 'pride'),
      ]);
      final card = cards.firstWhere((c) => c.title == 'Most threatened instinct');
      expect(card.value, 'Pride'); // 2 vs 1
    });

    test('unknown affect key falls back to raw key string', () {
      final cards =
          _insights(resentments: [_resentment(id: 1, affects: 'custom_key')]);
      final card = cards.firstWhere((c) => c.title == 'Most threatened instinct');
      expect(card.value, 'custom_key');
    });

    test('not produced when resentments list is empty', () {
      final cards = _insights(resentments: []);
      expect(cards.any((c) => c.title == 'Most threatened instinct'), isFalse);
    });
  });

  // ── 2. Step 10 trend ─────────────────────────────────────────────────────

  group('insight 2 — Step 10 trend', () {
    List<DailyReview> _reviewsWithDisturbers(int count, {bool recent = true}) {
      final base = DateTime(2026, 4, 5);
      return List.generate(count, (i) {
        final offset = recent ? i : count + i;
        return _review(
          id: offset,
          date: base.subtract(Duration(days: offset)),
          resentful: true,
        );
      });
    }

    test('not produced with fewer than 6 reviews', () {
      final cards = _insights(
        reviews: List.generate(5, (i) => _review(id: i, date: DateTime(2026, 4, 5 - i))),
      );
      expect(cards.any((c) => c.title == 'Step 10 trend'), isFalse);
    });

    test('improving trend → encouraging level', () {
      // Older half: all 4 disturbers each. Recent half: no disturbers.
      final base = DateTime(2026, 4, 5);
      final reviews = [
        // recent 3 — clean
        ...List.generate(3, (i) => _review(id: i, date: base.subtract(Duration(days: i)))),
        // older 3 — fully flagged
        ...List.generate(3, (i) => _review(
              id: 10 + i,
              date: base.subtract(Duration(days: 3 + i)),
              resentful: true,
              selfish:   true,
              dishonest: true,
              afraid:    true,
            )),
      ];
      final cards = _insights(reviews: reviews);
      final trend = cards.firstWhere((c) => c.title == 'Step 10 trend');
      expect(trend.level, InsightLevel.encouraging);
      expect(trend.value, contains('less'));
    });

    test('worsening trend → gentle level', () {
      final base = DateTime(2026, 4, 5);
      final reviews = [
        // recent 3 — fully flagged (avg = 4)
        ...List.generate(3, (i) => _review(
              id: i,
              date: base.subtract(Duration(days: i)),
              resentful: true,
              selfish:   true,
              dishonest: true,
              afraid:    true,
            )),
        // older 3 — one flag each (avg = 1) → delta = 300% ≥ 15 → gentle
        ...List.generate(3, (i) => _review(
              id: 10 + i,
              date: base.subtract(Duration(days: 3 + i)),
              resentful: true,
            )),
      ];
      final cards = _insights(reviews: reviews);
      final trend = cards.firstWhere((c) => c.title == 'Step 10 trend');
      expect(trend.level, InsightLevel.gentle);
    });

    test('stable trend (delta < 10%) → neutral level', () {
      // Both halves identical → delta = 0
      final base = DateTime(2026, 4, 5);
      final reviews = List.generate(
        6,
        (i) => _review(id: i, date: base.subtract(Duration(days: i)), resentful: true),
      );
      final cards = _insights(reviews: reviews);
      final trend = cards.firstWhere((c) => c.title == 'Step 10 trend');
      expect(trend.level, InsightLevel.neutral);
      expect(trend.value, 'Steady');
    });
  });

  // ── 3. Review consistency ─────────────────────────────────────────────────

  group('insight 3 — review consistency', () {
    test('strong consistency (≥80%) → encouraging', () {
      final base = DateTime(2026, 4, 5);
      // 25 of 30 days
      final reviews = List.generate(
        25,
        (i) => _review(id: i, date: base.subtract(Duration(days: i))),
      );
      final cards = _insights(reviews: reviews);
      final card = cards.firstWhere((c) => c.title == 'Review consistency');
      expect(card.level, InsightLevel.encouraging);
    });

    test('moderate consistency (50–79%) → neutral', () {
      final base = DateTime(2026, 4, 5);
      final reviews = List.generate(
        18,
        (i) => _review(id: i, date: base.subtract(Duration(days: i))),
      );
      final cards = _insights(reviews: reviews);
      final card = cards.firstWhere((c) => c.title == 'Review consistency');
      expect(card.level, InsightLevel.neutral);
    });

    test('low consistency (<50%) → gentle', () {
      final base = DateTime(2026, 4, 5);
      final reviews = List.generate(
        10,
        (i) => _review(id: i, date: base.subtract(Duration(days: i * 3))),
      );
      final cards = _insights(reviews: reviews);
      final card = cards.firstWhere((c) => c.title == 'Review consistency');
      expect(card.level, InsightLevel.gentle);
    });

    test('multiple reviews on same day count as one distinct day', () {
      final sameDay = DateTime(2026, 4, 5);
      final reviews = List.generate(5, (i) => _review(id: i, date: sameDay));
      final cards = _insights(reviews: reviews);
      final card = cards.firstWhere((c) => c.title == 'Review consistency');
      // 1 unique day out of 30 = 3%
      expect(card.level, InsightLevel.gentle);
    });
  });

  // ── 4. Amends progress ────────────────────────────────────────────────────

  group('insight 4 — amends progress', () {
    test('75%+ completed → encouraging', () {
      final cards = _insights(amends: [
        _amend(id: 1, status: 'completed'),
        _amend(id: 2, status: 'completed'),
        _amend(id: 3, status: 'completed'),
        _amend(id: 4, status: 'pending'),
      ]);
      final card = cards.firstWhere((c) => c.title == 'Amends progress');
      expect(card.level, InsightLevel.encouraging);
      expect(card.value, '3 / 4');
    });

    test('25–74% completed → neutral', () {
      final cards = _insights(amends: [
        _amend(id: 1, status: 'completed'),
        _amend(id: 2, status: 'pending'),
        _amend(id: 3, status: 'step8'),
        _amend(id: 4, status: 'step8'),
      ]);
      final card = cards.firstWhere((c) => c.title == 'Amends progress');
      expect(card.level, InsightLevel.neutral);
    });

    test('<25% completed → reflective', () {
      final cards = _insights(amends: [
        _amend(id: 1, status: 'completed'),
        _amend(id: 2, status: 'step8'),
        _amend(id: 3, status: 'step8'),
        _amend(id: 4, status: 'step8'),
        _amend(id: 5, status: 'step8'),
      ]);
      final card = cards.firstWhere((c) => c.title == 'Amends progress');
      expect(card.level, InsightLevel.reflective);
    });

    test('not produced when amends list is empty', () {
      expect(_insights().any((c) => c.title == 'Amends progress'), isFalse);
    });
  });

  // ── 5. Recurring resentment ───────────────────────────────────────────────

  group('insight 5 — recurring resentment', () {
    test('person appearing ≥2 times is surfaced', () {
      final cards = _insights(resentments: [
        _resentment(id: 1, person: 'Dad', affects: 'security'),
        _resentment(id: 2, person: 'Dad', affects: 'security'),
        _resentment(id: 3, person: 'Boss', affects: 'pride'),
      ]);
      final card = cards.firstWhere((c) => c.title == 'Recurring resentment');
      expect(card.value, 'Dad');
      expect(card.level, InsightLevel.reflective);
    });

    test('case-insensitive deduplication', () {
      final cards = _insights(resentments: [
        _resentment(id: 1, person: 'alice', affects: 'security'),
        _resentment(id: 2, person: 'Alice', affects: 'security'),
      ]);
      expect(cards.any((c) => c.title == 'Recurring resentment'), isTrue);
    });

    test('person appearing once → not produced', () {
      final cards = _insights(resentments: [
        _resentment(id: 1, person: 'A', affects: 'security'),
        _resentment(id: 2, person: 'B', affects: 'pride'),
      ]);
      expect(cards.any((c) => c.title == 'Recurring resentment'), isFalse);
    });

    test('not produced with fewer than 2 resentments total', () {
      final cards =
          _insights(resentments: [_resentment(id: 1, person: 'Someone', affects: 'security')]);
      expect(cards.any((c) => c.title == 'Recurring resentment'), isFalse);
    });
  });

  // ── 6. Flagged for sponsor ────────────────────────────────────────────────

  group('insight 6 — flagged items', () {
    test('counts flags across resentments + fears + harms', () {
      final cards = _insights(
        resentments: [_resentment(id: 1, flagged: true)],
        fears:       [_fear(id: 1, flagged: true)],
        harms:       [_harm(id: 1, flagged: true)],
      );
      final card = cards.firstWhere((c) => c.title == 'Ready for sponsor review');
      expect(card.value, '3');
    });

    test('not produced when no items flagged', () {
      final cards = _insights(
        resentments: [_resentment(id: 1)],
        fears:       [_fear(id: 1)],
      );
      expect(cards.any((c) => c.title == 'Ready for sponsor review'), isFalse);
    });
  });

  // ── 7. Most active shortcoming ────────────────────────────────────────────

  group('insight 7 — most noticed shortcoming', () {
    test('most frequent shortcoming in last 30 days is surfaced', () {
      final recent = DateTime.now().subtract(const Duration(days: 5));
      final cards = _insights(shortcomings: [
        _shortcoming(id: 1, description: 'pride',   dateObserved: recent),
        _shortcoming(id: 2, description: 'pride',   dateObserved: recent),
        _shortcoming(id: 3, description: 'fear',    dateObserved: recent),
      ]);
      final card = cards.firstWhere((c) => c.title == 'Most noticed shortcoming');
      expect(card.value, '2×');
      expect(card.interpretation, contains('pride'));
    });

    test('shortcomings older than 30 days are excluded', () {
      final old = DateTime.now().subtract(const Duration(days: 31));
      final cards = _insights(shortcomings: [
        _shortcoming(id: 1, description: 'envy', dateObserved: old),
      ]);
      expect(cards.any((c) => c.title == 'Most noticed shortcoming'), isFalse);
    });

    test('≥5 occurrences → gentle level', () {
      final recent = DateTime.now().subtract(const Duration(days: 1));
      final cards = _insights(shortcomings: List.generate(
        6,
        (i) => _shortcoming(id: i, description: 'pride', dateObserved: recent),
      ));
      final card = cards.firstWhere((c) => c.title == 'Most noticed shortcoming');
      expect(card.level, InsightLevel.gentle);
    });
  });

  // ── 8. Meditation consistency ─────────────────────────────────────────────

  group('insight 8 — meditation consistency', () {
    test('≥80% days with session → encouraging', () {
      final now = DateTime.now();
      final sessions = List.generate(
        25,
        (i) => _session(id: i, completedAt: now.subtract(Duration(days: i))),
      );
      final cards = _insights(meditationSessions: sessions);
      final card = cards.firstWhere((c) => c.title == 'Meditation consistency');
      expect(card.level, InsightLevel.encouraging);
    });

    test('sessions older than 30 days are excluded from count', () {
      final old = DateTime.now().subtract(const Duration(days: 35));
      final cards =
          _insights(meditationSessions: [_session(id: 1, completedAt: old)]);
      final card = cards.firstWhere((c) => c.title == 'Meditation consistency');
      // 0 sessions in 30 days → 0%
      expect(card.level, InsightLevel.gentle);
    });
  });

  // ── 9. Meditation time week-over-week ─────────────────────────────────────

  group('insight 9 — meditation this week vs last', () {
    test('more minutes this week → encouraging', () {
      final now    = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final thisWeekDay = DateTime(monday.year, monday.month, monday.day);
      final lastWeekDay = thisWeekDay.subtract(const Duration(days: 3));

      final sessions = [
        _session(id: 1, completedAt: thisWeekDay.add(const Duration(hours: 8)), durationSeconds: 600),
        _session(id: 2, completedAt: lastWeekDay, durationSeconds: 300),
      ];
      final cards = _insights(meditationSessions: sessions);
      final card = cards.firstWhere((c) => c.title == 'Meditation this week');
      expect(card.level, InsightLevel.encouraging);
    });

    test('no duration sessions → card not produced', () {
      final cards = _insights(meditationSessions: [
        _session(id: 1, durationSeconds: 0),
      ]);
      expect(cards.any((c) => c.title == 'Meditation this week'), isFalse);
    });
  });

  // ── 10. Journal breadth ───────────────────────────────────────────────────

  group('insight 10 — journal breadth', () {
    test('steps covered reported correctly', () {
      final cards = _insights(journalEntries: [
        _journalEntry(id: 1, stepNumber: 1),
        _journalEntry(id: 2, stepNumber: 4),
        _journalEntry(id: 3, stepNumber: 4), // duplicate step
      ]);
      final card = cards.firstWhere((c) => c.title == 'Steps reflected on');
      expect(card.value, '2 / 12');
    });

    test('≥8 steps → encouraging level', () {
      final cards = _insights(
        journalEntries: List.generate(9, (i) => _journalEntry(id: i, stepNumber: i + 1)),
      );
      final card = cards.firstWhere((c) => c.title == 'Steps reflected on');
      expect(card.level, InsightLevel.encouraging);
    });

    test('entries without stepNumber are excluded from step count', () {
      final cards = _insights(journalEntries: [
        _journalEntry(id: 1), // no stepNumber
      ]);
      expect(cards.any((c) => c.title == 'Steps reflected on'), isFalse);
    });
  });

  // ── 11. Sponsee progress ──────────────────────────────────────────────────

  group('insight 11 — sponsee progress', () {
    test('single sponsee shows their step number', () {
      final cards = _insights(sponsees: [_sponsee(id: 1, currentStep: 7)]);
      final card = cards.firstWhere((c) => c.title == 'Sponsee progress');
      expect(card.value, 'Step 7');
    });

    test('multiple sponsees shows count + average step', () {
      final cards = _insights(sponsees: [
        _sponsee(id: 1, currentStep: 4),
        _sponsee(id: 2, currentStep: 8),
      ]);
      final card = cards.firstWhere((c) => c.title == 'Sponsee progress');
      expect(card.value, '2 sponsees');
      expect(card.interpretation, contains('Step 6')); // avg of 4+8=12/2=6
    });

    test('inactive sponsees are excluded', () {
      final cards = _insights(sponsees: [
        _sponsee(id: 1, currentStep: 10, isActive: false),
      ]);
      expect(cards.any((c) => c.title == 'Sponsee progress'), isFalse);
    });
  });

  // ── 12. Gratitude practice ────────────────────────────────────────────────

  group('insight 12 — gratitude in reviews', () {
    test('≥70% with gratitude → encouraging', () {
      final cards = _insights(reviews: List.generate(
        10,
        (i) => _review(id: i, date: DateTime(2026, 4, 5 - i), gratitude: i < 8 ? 'grateful' : null),
      ));
      final card = cards.firstWhere((c) => c.title == 'Gratitude in reviews');
      expect(card.level, InsightLevel.encouraging);
    });

    test('not produced if fewer than 3 reviews have gratitude', () {
      final cards = _insights(reviews: [
        _review(id: 1, date: DateTime(2026, 4, 5), gratitude: 'thank you'),
        _review(id: 2, date: DateTime(2026, 4, 4)),
        _review(id: 3, date: DateTime(2026, 4, 3)),
      ]);
      expect(cards.any((c) => c.title == 'Gratitude in reviews'), isFalse);
    });
  });

  // ── avgDisturbers helper ──────────────────────────────────────────────────

  group('avgDisturbers', () {
    test('empty list → 0', () => expect(avgDisturbers([]), 0.0));

    test('all four flags set → 4.0', () {
      final reviews = [
        _review(resentful: true, selfish: true, dishonest: true, afraid: true),
      ];
      expect(avgDisturbers(reviews), 4.0);
    });

    test('two flags each across two reviews → 2.0', () {
      final reviews = [
        _review(id: 1, resentful: true, selfish: true),
        _review(id: 2, dishonest: true, afraid: true),
      ];
      expect(avgDisturbers(reviews), 2.0);
    });
  });
}
