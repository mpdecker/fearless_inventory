import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../review/providers/insight_provider.dart';
import '../review/providers/streak_provider.dart';
import '../review/providers/trend_provider.dart';
import '../meetings/providers/meeting_attendance_provider.dart';
import 'providers/insights_extended_providers.dart';

class RecoveryInsightsScreen extends ConsumerWidget {
  const RecoveryInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final landscapeAsync    = ref.watch(spiritualLandscapeProvider);
    final insightsAsync     = ref.watch(insightsProvider);
    final attendanceAsync   = ref.watch(meetingAttendanceStatsProvider);
    final weekAsync         = ref.watch(weekActivityProvider);
    final journalAsync      = ref.watch(journalInsightsProvider);
    final serviceAsync      = ref.watch(serviceInsightsProvider);
    final disturberAsync    = ref.watch(disturberBreakdownProvider);
    final step10TypeAsync   = ref.watch(step10TypeInsightsProvider);
    final amendsAsync       = ref.watch(amendsJourneyProvider);
    final sponsorCallAsync  = ref.watch(sponsorCallInsightsProvider);
    final pillarsAsync      = ref.watch(weeklyPillarsProvider);
    final momentumAsync     = ref.watch(meetingMomentumProvider);
    final fearAsync         = ref.watch(fearInsightsProvider);
    final milestone         = ref.watch(sobrietyMilestoneProvider);
    final streak            = ref.watch(streakProvider);

    void invalidateAll() {
      ref.invalidate(insightsProvider);
      ref.invalidate(weekActivityProvider);
      ref.invalidate(journalInsightsProvider);
      ref.invalidate(serviceInsightsProvider);
      ref.invalidate(disturberBreakdownProvider);
      ref.invalidate(step10TypeInsightsProvider);
      ref.invalidate(amendsJourneyProvider);
      ref.invalidate(sponsorCallInsightsProvider);
      ref.invalidate(spiritualLandscapeProvider);
      ref.invalidate(meetingAttendanceStatsProvider);
      ref.invalidate(weeklyPillarsProvider);
      ref.invalidate(meetingMomentumProvider);
      ref.invalidate(fearInsightsProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: invalidateAll,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => invalidateAll(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            // ── 1. Sobriety milestone banner ─────────────────────────────
            if (milestone != null) ...[
              _MilestoneBanner(milestone: milestone, streak: streak),
              const SizedBox(height: 28),
            ],

            // ── 2. Week at a glance ──────────────────────────────────────
            const _SectionHeader(
              title: 'This Week',
              subtitle: 'Review · Meditation · Meetings · Journal',
            ),
            const SizedBox(height: 12),
            weekAsync.when(
              data: (days) => _WeekAtAGlance(days: days),
              loading: () => const SizedBox(
                  height: 60, child: LinearProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // ── 2b. Recovery pillars ─────────────────────────────────────
            pillarsAsync.when(
              data: (pillars) => _RecoveryPillarsCard(pillars: pillars),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),

            // ── 3. Spiritual Landscape ───────────────────────────────────
            const _SectionHeader(
              title: 'Spiritual Landscape',
              subtitle: 'Step 10 evening reviews — last 14 days',
            ),
            const SizedBox(height: 12),
            landscapeAsync.when(
              data: (data) => _LandscapeCard(days: data),
              loading: () => const SizedBox(
                  height: 60, child: LinearProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),

            // ── 4. Disturber breakdown ───────────────────────────────────
            disturberAsync.when(
              data: (breakdown) => breakdown.totalReviews >= 5
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(
                          title: 'Inner Weather',
                          subtitle:
                              'Which patterns surfaced in your last 30 reviews',
                        ),
                        const SizedBox(height: 12),
                        _DisturberBreakdownCard(breakdown: breakdown),
                        const SizedBox(height: 32),
                      ],
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ── 4b. Step 10 by context ───────────────────────────────────
            step10TypeAsync.when(
              data: (t) => t.hasData
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(
                          title: 'Step 10 by Context',
                          subtitle:
                              'Morning, Spot Check & Nightly reviews — last 30 days',
                        ),
                        const SizedBox(height: 12),
                        _Step10TypeCard(insights: t),
                        const SizedBox(height: 32),
                      ],
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ── 5. Meetings & Fellowship ─────────────────────────────────
            const _SectionHeader(
              title: 'Meetings & Fellowship',
              subtitle: 'Based on your logged attendance',
            ),
            const SizedBox(height: 12),
            attendanceAsync.when(
              data: (stats) => _MeetingStatsCard(stats: stats),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            momentumAsync.when(
              data: (m) => m.hasEnoughData
                  ? Column(
                      children: [
                        const SizedBox(height: 10),
                        _MeetingMomentumCard(momentum: m),
                      ],
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),

            // ── 6. Amends journey ────────────────────────────────────────
            amendsAsync.when(
              data: (journey) => journey.total > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(
                          title: 'Amends Journey',
                          subtitle: 'Steps 8 & 9 — every completed amends is freedom',
                        ),
                        const SizedBox(height: 12),
                        _AmendsJourneyCard(journey: journey),
                        const SizedBox(height: 32),
                      ],
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ── 7. Journal coverage ──────────────────────────────────────
            journalAsync.when(
              data: (ji) => ji.totalEntries > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(
                          title: 'Journal Reflection',
                          subtitle: 'Steps you\'ve written about',
                        ),
                        const SizedBox(height: 12),
                        _JournalCoverageCard(insights: ji),
                        const SizedBox(height: 32),
                      ],
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ── 8. Service & giving back ─────────────────────────────────
            serviceAsync.when(
              data: (si) => si.hasAnyActivity
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(
                          title: 'Service & Giving Back',
                          subtitle: 'Step 12 in action',
                        ),
                        const SizedBox(height: 12),
                        _ServiceCard(insights: si),
                        const SizedBox(height: 32),
                      ],
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ── 9. Sponsor calls ─────────────────────────────────────────
            sponsorCallAsync.when(
              data: (sc) => sc.hasCalls
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(
                          title: 'Sponsor Contact',
                          subtitle: 'Your connection with your sponsor',
                        ),
                        const SizedBox(height: 12),
                        _SponsorCallCard(insights: sc),
                        const SizedBox(height: 32),
                      ],
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ── 10. Fear work ────────────────────────────────────────────
            fearAsync.when(
              data: (f) => f.hasAny
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(
                          title: 'Fear Inventory',
                          subtitle: 'Step 4 fears — what you\'re afraid of & your part',
                        ),
                        const SizedBox(height: 12),
                        _FearWorkCard(insights: f),
                        const SizedBox(height: 32),
                      ],
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ── 11. Pattern insights ─────────────────────────────────────
            const _SectionHeader(
              title: 'Pattern Insights',
              subtitle: 'Observations from your Step 4, 8, 10 & journal data',
            ),
            const SizedBox(height: 12),
            insightsAsync.when(
              loading: () => const Center(
                  child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator())),
              error: (e, _) => Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: $e'))),
              data: (cards) => Column(
                children: cards
                    .map((card) => _InsightCardWidget(card: card))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(subtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sobriety milestone banner
// ─────────────────────────────────────────────────────────────────────────────

class _MilestoneBanner extends StatelessWidget {
  final SobrietyMilestone milestone;
  final int streak;
  const _MilestoneBanner({required this.milestone, required this.streak});

  @override
  Widget build(BuildContext context) {
    final days = milestone.daysSober;
    final current = milestone.currentMilestoneLabel;
    final next = milestone.nextMilestoneLabel;
    final toNext = milestone.daysToNext;
    final progress = milestone.progressToNext;

    return Card(
      elevation: 0,
      color: Colors.teal.shade700.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.teal.shade700.withOpacity(0.35), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_outlined,
                    color: Colors.teal.shade300, size: 20),
                const SizedBox(width: 8),
                Text(
                  current != null ? '$days days sober' : '$days day${days == 1 ? '' : 's'} sober',
                  style: TextStyle(
                    color: Colors.teal.shade200,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                if (streak > 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            size: 14, color: Colors.deepPurple.shade200),
                        const SizedBox(width: 4),
                        Text('$streak-day streak',
                            style: TextStyle(
                                color: Colors.deepPurple.shade200,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            if (current != null) ...[
              const SizedBox(height: 8),
              Text(
                current,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
            const SizedBox(height: 14),
            // Progress to next milestone
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.white12,
                      valueColor:
                          AlwaysStoppedAnimation(Colors.teal.shade400),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$toNext day${toNext == 1 ? '' : 's'} to $next',
                  style: TextStyle(
                      color: Colors.teal.shade300,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Week at a glance (7-day activity grid)
// ─────────────────────────────────────────────────────────────────────────────

class _WeekAtAGlance extends StatelessWidget {
  final List<DayActivity> days;
  const _WeekAtAGlance({required this.days});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          children: [
            // Legend
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 4,
              children: [
                _legendItem(Colors.teal.shade400, 'Review'),
                _legendItem(Colors.deepPurple.shade300, 'Meditation'),
                _legendItem(Colors.indigo.shade300, 'Meeting'),
                _legendItem(Colors.amber.shade600, 'Journal'),
              ],
            ),
            const SizedBox(height: 12),
            // Day columns
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((d) => _DayColumn(day: d)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
        ],
      );
}

class _DayColumn extends StatelessWidget {
  final DayActivity day;
  const _DayColumn({required this.day});

  @override
  Widget build(BuildContext context) {
    final isToday = _sameDay(day.date, DateTime.now());
    return Column(
      children: [
        Text(
          DateFormat('E').format(day.date)[0],
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? Colors.white : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 6),
        _actDot(day.hasReview, Colors.teal.shade400),
        const SizedBox(height: 3),
        _actDot(day.hasMeditation, Colors.deepPurple.shade300),
        const SizedBox(height: 3),
        _actDot(day.hasMeeting, Colors.indigo.shade300),
        const SizedBox(height: 3),
        _actDot(day.hasJournalEntry, Colors.amber.shade600),
      ],
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _actDot(bool active, Color color) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? color : Colors.white10,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Spiritual landscape heatmap
// ─────────────────────────────────────────────────────────────────────────────

class _LandscapeCard extends StatelessWidget {
  final List<DayReflection> days;
  const _LandscapeCard({required this.days});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          children: [
            if (days.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Complete a Step 10 review to see your landscape.',
                  style: TextStyle(color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: days.map((d) => _LandscapeSquare(day: d)).toList(),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(Colors.teal.shade50, 'Clear'),
                const SizedBox(width: 12),
                _legendDot(Colors.orange.shade100, '1–2 patterns'),
                const SizedBox(width: 12),
                _legendDot(Colors.orange.shade400, '3–4 patterns'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      );
}

class _LandscapeSquare extends StatelessWidget {
  final DayReflection day;
  const _LandscapeSquare({required this.day});

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (day.intensity >= 3) {
      color = Colors.orange.shade400;
    } else if (day.intensity >= 1) {
      color = Colors.orange.shade100;
    } else {
      color = Colors.teal.shade50;
    }

    return Tooltip(
      message: '${DateFormat('MMM d').format(day.date)} · '
          '${day.intensity} pattern${day.intensity == 1 ? '' : 's'}'
          '${day.hasNotes ? ' · has notes' : ''}',
      child: Column(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: day.hasNotes
                  ? Border.all(color: Colors.blueGrey.shade200, width: 1)
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('E').format(day.date)[0],
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Disturber breakdown
// ─────────────────────────────────────────────────────────────────────────────

class _DisturberBreakdownCard extends StatelessWidget {
  final DisturberBreakdown breakdown;
  const _DisturberBreakdownCard({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Resentful', breakdown.resentful, Colors.orange.shade400),
      ('Selfish', breakdown.selfish, Colors.purple.shade300),
      ('Dishonest', breakdown.dishonest, Colors.indigo.shade300),
      ('Afraid', breakdown.afraid, Colors.teal.shade400),
    ]..sort((a, b) => b.$2.compareTo(a.$2));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'of ${breakdown.totalReviews} reviews',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500),
            ),
            const SizedBox(height: 14),
            ...items.map((item) {
              final (label, count, color) = item;
              final fraction = breakdown.fractionOf(count);
              final pct = (fraction * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 72,
                          child: Text(label,
                              style: const TextStyle(fontSize: 13)),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: fraction,
                              minHeight: 8,
                              backgroundColor: Colors.white10,
                              valueColor:
                                  AlwaysStoppedAnimation(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$pct%',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            Text(
              'These four patterns are the focus of Step 10. '
              'Noticing them, without judgment, is the practice.',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Amends journey
// ─────────────────────────────────────────────────────────────────────────────

class _AmendsJourneyCard extends StatelessWidget {
  final AmendsJourney journey;
  const _AmendsJourneyCard({required this.journey});

  @override
  Widget build(BuildContext context) {
    final total     = journey.total;
    final step8     = journey.step8;
    final pending   = journey.pending;
    final completed = journey.completed;
    final pct       = journey.completedPct;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: journey.completedFraction,
                minHeight: 10,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation(Colors.teal.shade400),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$completed of $total complete ($pct%)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.teal.shade300),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _stageChip('Step 8 list', step8, Colors.blueGrey.shade400),
                const SizedBox(width: 8),
                _stageChip('Planned', pending, Colors.indigo.shade300),
                const SizedBox(width: 8),
                _stageChip('Complete', completed, Colors.teal.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stageChip(String label, int count, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text('$count',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 20)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      color: color.withOpacity(0.8),
                      fontSize: 11),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Journal step coverage grid
// ─────────────────────────────────────────────────────────────────────────────

class _JournalCoverageCard extends StatelessWidget {
  final JournalInsights insights;
  const _JournalCoverageCard({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${insights.totalEntries} '
                  'entr${insights.totalEntries == 1 ? 'y' : 'ies'} total',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  '${insights.stepsCovered} of 12 steps covered',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // 12 step dots in a row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(12, (i) {
                final step = i + 1;
                final covered = insights.coveredSteps.contains(step);
                return _StepDot(step: step, covered: covered);
              }),
            ),
            if (insights.last7DaysCount > 0) ...[
              const SizedBox(height: 12),
              Text(
                '${insights.last7DaysCount} '
                'entr${insights.last7DaysCount == 1 ? 'y' : 'ies'} this week',
                style: TextStyle(
                    fontSize: 12, color: Colors.teal.shade300),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int step;
  final bool covered;
  const _StepDot({required this.step, required this.covered});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: covered
                ? Colors.deepPurple.shade400
                : Colors.white10,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: covered ? Colors.white : Colors.grey.shade600),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Service & giving back
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final ServiceInsights insights;
  const _ServiceCard({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (insights.activeCommitments > 0)
                  _ServiceStat(
                    value: '${insights.activeCommitments}',
                    label: 'Active\ncommitments',
                    color: Colors.indigo.shade300,
                    icon: Icons.volunteer_activism_outlined,
                  ),
                if (insights.callsThisMonth > 0 ||
                    insights.callsLastMonth > 0) ...[
                  if (insights.activeCommitments > 0)
                    const SizedBox(width: 12),
                  _ServiceStat(
                    value: '${insights.callsThisMonth}',
                    label: 'Calls this\nmonth',
                    color: Colors.teal.shade400,
                    icon: Icons.phone_outlined,
                  ),
                ],
                if (insights.activeSponsees > 0) ...[
                  const SizedBox(width: 12),
                  _ServiceStat(
                    value: '${insights.activeSponsees}',
                    label: 'Active\nsponse${insights.activeSponsees == 1 ? 'e' : 'es'}',
                    color: Colors.deepPurple.shade300,
                    icon: Icons.diversity_3_outlined,
                  ),
                ],
              ],
            ),
            if (insights.callsThisMonth > 0 && insights.callsLastMonth > 0) ...[
              const SizedBox(height: 12),
              Text(
                insights.callsThisMonth >= insights.callsLastMonth
                    ? '${insights.callsThisMonth} calls this month vs '
                        '${insights.callsLastMonth} last month — the work continues.'
                    : '${insights.callsThisMonth} calls this month vs '
                        '${insights.callsLastMonth} last month.',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    height: 1.4),
              ),
            ],
            if (insights.activeSponsees > 0 && insights.avgSponseeStep > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Sponsees averaging around Step '
                '${insights.avgSponseeStep.round()}. '
                'The best thing you can give a sponsee is your own recovery.',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ServiceStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _ServiceStat(
      {required this.value,
      required this.label,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 24)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    TextStyle(color: color.withOpacity(0.8), fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pattern insight card
// ─────────────────────────────────────────────────────────────────────────────

class _InsightCardWidget extends StatelessWidget {
  final InsightCard card;
  const _InsightCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentFor(card.level);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: accentColor.withOpacity(0.22), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon column
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(card.icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          card.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          card.value,
                          style: TextStyle(
                              color: accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.interpretation,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentFor(InsightLevel level) {
    switch (level) {
      case InsightLevel.encouraging:
        return AppColors.cyanSecondary;
      case InsightLevel.neutral:
        return AppColors.meetingChipOtherBorder;
      case InsightLevel.reflective:
        return AppColors.accentDeepPurple;
      case InsightLevel.gentle:
        return AppColors.dashboardAmber;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meeting attendance stats
// ─────────────────────────────────────────────────────────────────────────────

class _MeetingStatsCard extends StatelessWidget {
  final AttendanceStats stats;
  const _MeetingStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.lifetimeCount == 0) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.groups_outlined,
                  color: Colors.orange.shade300, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Log meeting attendance in the Meetings tab to see fellowship insights here.',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatCell(
                    value: '${stats.last7Days}',
                    label: 'This week',
                    color: Colors.orange.shade700),
                _StatCell(
                    value: '${stats.last30Days}',
                    label: 'Last 30 days',
                    color: Colors.indigo),
                _StatCell(
                    value: '${stats.lifetimeCount}',
                    label: 'Lifetime',
                    color: Colors.teal),
              ],
            ),
            if (stats.timesShared > 0 || stats.longestGapDays != null) ...[
              const Divider(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (stats.timesShared > 0)
                    _badge('Shared ${stats.timesShared}×', Colors.indigo),
                  if (stats.longestGapDays != null &&
                      stats.longestGapDays! > 3)
                    _badge(
                        'Longest gap: ${stats.longestGapDays}d',
                        stats.longestGapDays! > 7
                            ? Colors.amber.shade700
                            : Colors.amber.shade600),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCell(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 26, color: color)),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sponsor call card
// ─────────────────────────────────────────────────────────────────────────────

class _SponsorCallCard extends StatelessWidget {
  final SponsorCallInsights insights;
  const _SponsorCallCard({required this.insights});

  static final _dateFmt = DateFormat('MMM d');

  @override
  Widget build(BuildContext context) {
    final lastCallLabel = insights.lastCallAt == null
        ? 'No calls yet'
        : _dateFmt.format(insights.lastCallAt!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Streak bar ────────────────────────────────────────────────
            if (insights.weekStreak > 0) ...[
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orangeAccent, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '${insights.weekStreak}-week streak',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // ── Stats row ─────────────────────────────────────────────────
            Row(
              children: [
                _StatCell(
                  value: insights.callsThisWeek.toString(),
                  label: 'This week',
                  color: insights.callsThisWeek > 0
                      ? Colors.tealAccent
                      : Colors.grey,
                ),
                _StatCell(
                  value: insights.callsLastWeek.toString(),
                  label: 'Last week',
                  color: insights.callsLastWeek > 0
                      ? Colors.tealAccent.withValues(alpha: 0.7)
                      : Colors.grey,
                ),
                _StatCell(
                  value: insights.callsLast4Weeks.toString(),
                  label: '4 weeks',
                  color: Colors.blueGrey,
                ),
              ],
            ),

            const Divider(height: 24),

            // ��─ Last call ─────────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.phone_outlined,
                    size: 14, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Text(
                  'Last call: $lastCallLabel',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recovery pillars
// ─────────────────────────────────────────────────────────────────────────────

class _RecoveryPillarsCard extends StatelessWidget {
  final WeeklyPillars pillars;
  const _RecoveryPillarsCard({required this.pillars});

  @override
  Widget build(BuildContext context) {
    final items = [
      (pillars.didReview,      Icons.track_changes_outlined, 'Review'),
      (pillars.didMeditation,  Icons.self_improvement,       'Meditation'),
      (pillars.didMeeting,     Icons.groups_outlined,         'Meeting'),
      (pillars.didJournal,     Icons.menu_book_outlined,      'Journal'),
      (pillars.didSponsorCall, Icons.phone_outlined,           'Sponsor'),
      (pillars.didService,     Icons.volunteer_activism_outlined, 'Service'),
    ];

    final all = pillars.activeCount == 6;
    final n = pillars.activeCount;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$n / 6 pillars this week',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: all ? Colors.teal.shade300 : Colors.white70,
                  ),
                ),
                const Spacer(),
                if (all)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Full toolkit',
                      style: TextStyle(
                        color: Colors.teal.shade300,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items.map((item) {
                final (active, icon, label) = item;
                final color =
                    active ? Colors.teal.shade300 : Colors.white12;
                final textColor = active
                    ? Colors.white70
                    : Colors.grey.shade700;
                return Column(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? Colors.teal.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      label,
                      style: TextStyle(fontSize: 10, color: textColor),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meeting momentum
// ─────────────────────────────────────────────────────────────────────────────

class _MeetingMomentumCard extends StatelessWidget {
  final MeetingMomentum momentum;
  const _MeetingMomentumCard({required this.momentum});

  @override
  Widget build(BuildContext context) {
    final delta = momentum.delta;
    final growing = momentum.isGrowing;
    final color =
        growing ? Colors.teal.shade400 : Colors.blueGrey.shade400;
    final icon =
        growing ? Icons.trending_up_outlined : Icons.trending_flat_outlined;
    final message = delta == 0
        ? 'Same as last month — steady fellowship.'
        : growing
            ? '+$delta meetings compared to last month. Keep showing up.'
            : '${delta.abs()} fewer than last month — meetings are worth protecting.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ),
          Text(
            '${momentum.thisMonth} vs ${momentum.priorMonth}',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fear work card
// ─────────────────────────────────────────────────────────────────────────────

class _FearWorkCard extends StatelessWidget {
  final FearInsights insights;
  const _FearWorkCard({required this.insights});

  @override
  Widget build(BuildContext context) {
    final pct = insights.pctWorked;
    final color = pct >= 75
        ? Colors.teal.shade400
        : pct >= 40
            ? Colors.indigo.shade300
            : Colors.blueGrey.shade400;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, color: color, size: 20),
                const SizedBox(width: 10),
                Text(
                  '${insights.total} fear${insights.total == 1 ? '' : 's'} inventoried',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  '${insights.withMyPart} worked',
                  style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 7,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              pct >= 75
                  ? '"My part" written for $pct% of fears. '
                      'Owning your side is where fear loses its grip.'
                  : insights.withMyPart == 0
                      ? 'Writing "my part" for each fear is the Step 4 work that dissolves them.'
                      : '"My part" written for $pct% of fears. '
                          'Each one you complete is fear made smaller.',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 10 type breakdown card
// ─────────────────────────────────────────────────────────────────────────────

class _Step10TypeCard extends StatelessWidget {
  final Step10TypeInsights insights;
  const _Step10TypeCard({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TypeRow(
            icon: Icons.wb_sunny_outlined,
            label: 'Morning',
            count: insights.morningCount,
            signalRate: insights.morningSignalRate,
            color: Colors.orange.shade300,
          ),
          const SizedBox(height: 14),
          _TypeRow(
            icon: Icons.track_changes_outlined,
            label: 'Spot Check',
            count: insights.spotCheckCount,
            signalRate: insights.spotCheckSignalRate,
            color: Colors.tealAccent.shade100,
          ),
          const SizedBox(height: 14),
          _TypeRow(
            icon: Icons.nightlight_round_outlined,
            label: 'Nightly',
            count: insights.nightlyCount,
            signalRate: insights.nightlySignalRate,
            color: Colors.indigo.shade200,
          ),
          const Divider(color: Colors.white12, height: 28),
          Text(
            '${insights.totalCount} total reviews in the last 30 days',
            style: TextStyle(fontSize: 11, color: Colors.indigo.shade300),
          ),
        ],
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final double signalRate;
  final Color color;

  const _TypeRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.signalRate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (signalRate * 100).round();
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        Text(
          '$count review${count == 1 ? '' : 's'}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const Spacer(),
        if (count > 0)
          Text(
            '$pct% flagged',
            style: TextStyle(
              fontSize: 11,
              color: pct > 50
                  ? Colors.redAccent.shade100
                  : Colors.green.shade300,
            ),
          ),
      ],
    );
  }
}
