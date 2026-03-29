import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

enum InsightLevel {
  encouraging, // positive trend, achievement to celebrate
  neutral,     // factual observation, no strong valence
  reflective,  // worth sitting with; bring to sponsor
  gentle,      // pattern worth noticing — warm, never shaming
}

class InsightCard {
  final String title;
  final String value; // the key number or word shown as the metric
  final String interpretation;
  final InsightLevel level;
  final IconData icon;

  const InsightCard({
    required this.title,
    required this.value,
    required this.interpretation,
    required this.level,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Human-readable affects labels (mirrors affects.dart)
// ─────────────────────────────────────────────────────────────────────────────

const _affectsLabels = {
  'self_esteem': 'Self-Esteem',
  'security': 'Security',
  'ambitions': 'Ambitions',
  'personal_relations': 'Personal Relations',
  'sex_relations': 'Sex Relations',
  'pride': 'Pride',
  'pocketbook': 'Pocketbook',
  'fears': 'Fears',
};

// ─────────────────────────────────────────────────────────────────────────────
// Provider — autoDispose so data refreshes on re-entry to the insights tab
// ─────────────────────────────────────────────────────────────────────────────

final insightsProvider =
    FutureProvider.autoDispose<List<InsightCard>>((ref) async {
  final db = ref.watch(databaseProvider);

  // Fetch everything in parallel
  final results = await Future.wait([
    db.select(db.resentments).get(),
    db.select(db.fears).get(),
    db.select(db.harms).get(),
    (db.select(db.dailyReviews)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(30))
        .get(),
    db.select(db.amends).get(),
    db.select(db.shortcomingLogs).get(),
    db.select(db.meditationSessions).get(),
    db.select(db.journalEntries).get(),
    db.select(db.sponsees).get(),
  ]);

  final resentments        = results[0] as List<Resentment>;
  final fears              = results[1] as List<Fear>;
  final harms              = results[2] as List<Harm>;
  final reviews            = results[3] as List<DailyReview>;
  final amends             = results[4] as List<Amend>;
  final shortcomings       = results[5] as List<ShortcomingLog>;
  final meditationSessions = results[6] as List<MeditationSession>;
  final journalEntries     = results[7] as List<JournalEntry>;
  final sponsees           = results[8] as List<Sponsee>;

  return _computeInsights(
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
});

// ─────────────────────────────────────────────────────────────────────────────
// Core computation — pure function, easy to unit-test
// ─────────────────────────────────────────────────────────────────────────────

List<InsightCard> _computeInsights({
  required List<Resentment> resentments,
  required List<Fear> fears,
  required List<Harm> harms,
  required List<DailyReview> reviews,
  required List<Amend> amends,
  required List<ShortcomingLog> shortcomings,
  required List<MeditationSession> meditationSessions,
  required List<JournalEntry> journalEntries,
  required List<Sponsee> sponsees,
}) {
  final cards = <InsightCard>[];

  // ── 1. Most threatened instinct ──────────────────────────────────────────
  if (resentments.isNotEmpty) {
    final affectCounts = <String, int>{};
    for (final r in resentments) {
      for (final a in r.affects.split(',').where((s) => s.isNotEmpty)) {
        affectCounts[a] = (affectCounts[a] ?? 0) + 1;
      }
    }
    if (affectCounts.isNotEmpty) {
      final sorted = affectCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.first;
      final label = _affectsLabels[top.key] ?? top.key;
      final pct = ((top.value / resentments.length) * 100).round();

      cards.add(InsightCard(
        title: 'Most threatened instinct',
        value: label,
        interpretation:
            'Appears in ${top.value} of ${resentments.length} resentments ($pct%). '
            'This is often where our deepest pain and our greatest opportunity '
            'for growth live side by side.',
        level: InsightLevel.reflective,
        icon: Icons.psychology_outlined,
      ));
    }
  }

  // ── 2. Step 10 trend ─────────────────────────────────────────────────────
  if (reviews.length >= 6) {
    final half = (reviews.length / 2).floor();
    final recent = reviews.take(half).toList();
    final older = reviews.skip(half).take(half).toList();
    final avgRecent = _avgDisturbers(recent);
    final avgOlder = _avgDisturbers(older);

    final delta = avgOlder > 0
        ? ((avgRecent - avgOlder) / avgOlder * 100).round()
        : 0;

    if (delta <= -10) {
      cards.add(InsightCard(
        title: 'Step 10 trend',
        value: '${delta.abs()}% less',
        interpretation:
            'Your disturber frequency has dropped ${delta.abs()}% compared to '
            'the previous period. The daily review is working.',
        level: InsightLevel.encouraging,
        icon: Icons.trending_down_outlined,
      ));
    } else if (delta >= 15) {
      cards.add(InsightCard(
        title: 'Step 10 trend',
        value: '+${delta.abs()}% more',
        interpretation:
            'Disturbers are up ${delta.abs()}% lately — life can get busy. '
            'Worth mentioning to your sponsor, not to analyse, just to share.',
        level: InsightLevel.gentle,
        icon: Icons.trending_up_outlined,
      ));
    } else {
      cards.add(InsightCard(
        title: 'Step 10 trend',
        value: 'Steady',
        interpretation:
            'Your disturber frequency has been stable. '
            'Consistency in the daily review is the practice itself.',
        level: InsightLevel.neutral,
        icon: Icons.trending_flat_outlined,
      ));
    }
  }

  // ── 3. Step 10 consistency ───────────────────────────────────────────────
  if (reviews.isNotEmpty) {
    final daysCovered = reviews
        .map((r) => r.date.toIso8601String().split('T').first)
        .toSet()
        .length;
    final pct = ((daysCovered / 30) * 100).round().clamp(0, 100);

    cards.add(InsightCard(
      title: 'Review consistency',
      value: '$pct%',
      interpretation: pct >= 80
          ? '$daysCovered of the last 30 days. '
              'Strong consistency — this foundation supports everything else.'
          : pct >= 50
              ? '$daysCovered of the last 30 days. '
                  'Good effort. Each review is a renewed choice.'
              : '$daysCovered of the last 30 days. '
                  'Even a brief nightly check-in counts — it\'s not about perfection.',
      level: pct >= 80
          ? InsightLevel.encouraging
          : pct >= 50
              ? InsightLevel.neutral
              : InsightLevel.gentle,
      icon: Icons.calendar_today_outlined,
    ));
  }

  // ── 4. Amends progress ───────────────────────────────────────────────────
  if (amends.isNotEmpty) {
    final completed = amends.where((a) => a.status == 'completed').length;
    final pending   = amends.where((a) => a.status == 'pending').length;
    final step8     = amends.where((a) => a.status == 'step8').length;
    final pct       = ((completed / amends.length) * 100).round();

    cards.add(InsightCard(
      title: 'Amends progress',
      value: '$completed / ${amends.length}',
      interpretation:
          '$completed complete · $pending planned · $step8 on Step 8 list. '
          '${pct >= 50 ? "You\'ve come more than halfway — each one matters." : "Every completed amends is a piece of freedom returned."}',
      level: pct >= 75
          ? InsightLevel.encouraging
          : pct >= 25
              ? InsightLevel.neutral
              : InsightLevel.reflective,
      icon: Icons.handshake_outlined,
    ));
  }

  // ── 5. Recurring person in resentments ───────────────────────────────────
  if (resentments.length >= 2) {
    final personCounts = <String, int>{};
    for (final r in resentments) {
      final name = r.person.trim().toLowerCase();
      personCounts[name] = (personCounts[name] ?? 0) + 1;
    }
    final recurring = personCounts.entries.where((e) => e.value >= 2).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (recurring.isNotEmpty) {
      final top = recurring.first;
      final displayName = resentments
          .firstWhere((r) => r.person.trim().toLowerCase() == top.key)
          .person
          .trim();

      cards.add(InsightCard(
        title: 'Recurring resentment',
        value: displayName,
        interpretation:
            '$displayName appears ${top.value} times. '
            'Multiple entries toward the same person often reveal a deep pattern '
            'that your sponsor can help you see more clearly.',
        level: InsightLevel.reflective,
        icon: Icons.repeat_outlined,
      ));
    }
  }

  // ── 6. Flagged for sponsor ────────────────────────────────────────────────
  final flaggedCount = resentments.where((r) => r.flagForReview).length +
      fears.where((f) => f.flagForReview).length +
      harms.where((h) => h.flagForReview).length;

  if (flaggedCount > 0) {
    cards.add(InsightCard(
      title: 'Ready for sponsor review',
      value: '$flaggedCount',
      interpretation:
          '$flaggedCount item${flaggedCount == 1 ? '' : 's'} flagged across your inventory. '
          'Export the sponsor review sheet from Settings whenever you\'re ready.',
      level: InsightLevel.neutral,
      icon: Icons.supervised_user_circle_outlined,
    ));
  }

  // ── 7. Most active shortcoming (last 30 days) ────────────────────────────
  if (shortcomings.isNotEmpty) {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final recent = shortcomings.where((s) => s.dateObserved.isAfter(cutoff)).toList();
    if (recent.isNotEmpty) {
      final counts = <String, int>{};
      for (final s in recent) {
        final key = s.description.trim().toLowerCase();
        counts[key] = (counts[key] ?? 0) + 1;
      }
      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.first;
      final displayDesc = recent
          .firstWhere((s) => s.description.trim().toLowerCase() == top.key)
          .description
          .trim();

      cards.add(InsightCard(
        title: 'Most noticed shortcoming',
        value: '${top.value}×',
        interpretation:
            '"$displayDesc" noticed ${top.value} time${top.value == 1 ? '' : 's'} '
            'this month. Awareness is the beginning of freedom — you\'re doing the work.',
        level: top.value >= 5 ? InsightLevel.gentle : InsightLevel.neutral,
        icon: Icons.self_improvement,
      ));
    }
  }

  // ── 8. Meditation consistency (last 30 days) ─────────────────────────────
  if (meditationSessions.isNotEmpty) {
    final cutoff30 = DateTime.now().subtract(const Duration(days: 30));
    final recentSessions =
        meditationSessions.where((s) => s.completedAt.isAfter(cutoff30));
    final daysWithSession = recentSessions
        .map((s) => s.completedAt.toIso8601String().split('T').first)
        .toSet()
        .length;
    final pct = ((daysWithSession / 30) * 100).round().clamp(0, 100);

    cards.add(InsightCard(
      title: 'Meditation consistency',
      value: '$pct%',
      interpretation: pct >= 80
          ? '$daysWithSession of the last 30 days — your inner life is getting real attention.'
          : pct >= 40
              ? '$daysWithSession of the last 30 days. Every quiet moment is worthwhile.'
              : '$daysWithSession of the last 30 days. '
                  'Even a few minutes of stillness is a Step 11 in action.',
      level: pct >= 80
          ? InsightLevel.encouraging
          : pct >= 40
              ? InsightLevel.neutral
              : InsightLevel.gentle,
      icon: Icons.self_improvement,
    ));
  }

  // ── 9. Meditation time — this week vs last week ───────────────────────────
  if (meditationSessions.any((s) => s.durationSeconds > 0)) {
    final now           = DateTime.now();
    final monday        = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekStart = DateTime(monday.year, monday.month, monday.day);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    int sumSeconds(DateTime from, DateTime to) => meditationSessions
        .where((s) =>
            !s.completedAt.isBefore(from) &&
            s.completedAt.isBefore(to) &&
            s.durationSeconds > 0)
        .fold(0, (acc, s) => acc + s.durationSeconds);

    final thisWeekSec = sumSeconds(thisWeekStart, now);
    final lastWeekSec = sumSeconds(lastWeekStart, thisWeekStart);
    final thisWeekMin = (thisWeekSec / 60).round();
    final lastWeekMin = (lastWeekSec / 60).round();

    if (thisWeekSec > 0 || lastWeekSec > 0) {
      final delta = lastWeekMin > 0
          ? ((thisWeekMin - lastWeekMin) / lastWeekMin * 100).round()
          : 0;

      cards.add(InsightCard(
        title: 'Meditation this week',
        value: '${thisWeekMin}m',
        interpretation: lastWeekMin == 0
            ? '$thisWeekMin min this week. Using the timer builds a measurable practice.'
            : thisWeekMin >= lastWeekMin
                ? '$thisWeekMin min this week vs $lastWeekMin min last week '
                    '(+${delta.abs()}%). Growing quiet time.'
                : '$thisWeekMin min this week vs $lastWeekMin min last week. '
                    'The stillness is always there when you come back to it.',
        level: thisWeekMin >= lastWeekMin
            ? InsightLevel.encouraging
            : InsightLevel.neutral,
        icon: Icons.timer_outlined,
      ));
    }
  }

  // ── 10. Journal breadth ───────────────────────────────────────────────────
  if (journalEntries.isNotEmpty) {
    final stepSet = journalEntries
        .where((e) => e.stepNumber != null)
        .map((e) => e.stepNumber!)
        .toSet();
    final covered = stepSet.length;

    if (covered >= 1) {
      cards.add(InsightCard(
        title: 'Steps reflected on',
        value: '$covered / 12',
        interpretation: covered >= 8
            ? 'You\'ve written across $covered of the 12 steps. '
                'Wide reflection is a mark of thoroughness.'
            : covered >= 4
                ? 'You\'ve written about $covered steps so far. '
                    'The journal grows step by step.'
                : 'You\'ve started reflecting on $covered step${covered == 1 ? '' : 's'}. '
                    'Every entry is a moment of honesty with yourself.',
        level: covered >= 8
            ? InsightLevel.encouraging
            : covered >= 4
                ? InsightLevel.neutral
                : InsightLevel.reflective,
        icon: Icons.menu_book_outlined,
      ));
    }
  }

  // ── 11. Sponsee progress (if sponsoring others) ───────────────────────────
  final activeSponsees = sponsees.where((s) => s.isActive).toList();
  if (activeSponsees.isNotEmpty) {
    final avg = activeSponsees
            .map((s) => (s.currentStep ?? 1).toDouble())
            .reduce((a, b) => a + b) /
        activeSponsees.length;
    final avgRounded = avg.round();

    cards.add(InsightCard(
      title: 'Sponsee progress',
      value: activeSponsees.length == 1
          ? 'Step $avgRounded'
          : '${activeSponsees.length} sponsees',
      interpretation: activeSponsees.length == 1
          ? 'Your sponsee is working Step $avgRounded. '
              'The best sponsorship is your own continued recovery.'
          : '${activeSponsees.length} active sponsees, '
              'averaging around Step $avgRounded. '
              'Carrying the message is the heart of Step 12.',
      level: InsightLevel.encouraging,
      icon: Icons.diversity_3_outlined,
    ));
  }

  // ── 12. Gratitude practice ────────────────────────────────────────────────
  if (reviews.isNotEmpty) {
    final withGratitude = reviews.where((r) =>
        r.gratitude != null && r.gratitude!.trim().isNotEmpty).length;
    final pct = ((withGratitude / reviews.length) * 100).round();

    if (withGratitude >= 3) {
      cards.add(InsightCard(
        title: 'Gratitude in reviews',
        value: '$pct%',
        interpretation: pct >= 70
            ? 'You wrote gratitude in $withGratitude of your last '
                '${reviews.length} reviews. '
                'A grateful heart is a protected heart.'
            : 'You\'ve included gratitude in $withGratitude of your recent reviews. '
                'Adding even one thing each night builds the habit naturally.',
        level: pct >= 70 ? InsightLevel.encouraging : InsightLevel.neutral,
        icon: Icons.favorite_border,
      ));
    }
  }

  // ── 13. Empty state ───────────────────────────────────────────────────────
  if (cards.isEmpty) {
    cards.add(const InsightCard(
      title: 'Your story is just beginning',
      value: '—',
      interpretation:
          'Complete some Step 10 reviews, stepwork entries, and amends '
          'to start seeing patterns emerge here.',
      level: InsightLevel.neutral,
      icon: Icons.hourglass_empty_outlined,
    ));
  }

  return cards;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper
// ─────────────────────────────────────────────────────────────────────────────

double _avgDisturbers(List<DailyReview> reviews) {
  if (reviews.isEmpty) return 0;
  final total = reviews.fold<int>(0, (sum, r) {
    int count = 0;
    if (r.wasResentful) count++;
    if (r.wasSelfish) count++;
    if (r.wasDishonest) count++;
    if (r.wasAfraid) count++;
    return sum + count;
  });
  return total / reviews.length;
}
