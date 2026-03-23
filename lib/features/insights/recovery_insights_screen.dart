import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../amends/providers/amends_stats_provider.dart';
import '../review/providers/insight_provider.dart';
import '../review/providers/trend_provider.dart';
import '../meetings/providers/meeting_attendance_provider.dart';

class RecoveryInsightsScreen extends ConsumerWidget {
  const RecoveryInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final landscapeAsync = ref.watch(spiritualLandscapeProvider);
    final insightsAsync = ref.watch(insightsProvider);
    final attendanceAsync = ref.watch(meetingAttendanceStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Insights'),
        actions: [
          // Manual refresh — useful since autoDispose re-fetches on tab change
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(insightsProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(insightsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // ── Spiritual Landscape heatmap ──────────────────────────────
            _SectionHeader(
                title: 'Spiritual Landscape',
                subtitle: 'Last 14 days of Step 10 reviews'),
            const SizedBox(height: 12),
            landscapeAsync.when(
              data: (data) => _LandscapeCard(days: data),
              loading: () =>
                  const SizedBox(height: 60, child: LinearProgressIndicator()),
              error: (_, __) => const Text('Error loading landscape'),
            ),

            const SizedBox(height: 32),

            // ── Meeting attendance ────────────────────────────────────────
            const _SectionHeader(
                title: 'Meetings & Fellowship',
                subtitle: 'Based on your logged attendance'),
            const SizedBox(height: 12),
            attendanceAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (stats) => _MeetingStatsCard(stats: stats),
            ),

            const SizedBox(height: 32),

            // ── Pattern insights ─────────────────────────────────────────
            _SectionHeader(
                title: 'Pattern Insights',
                subtitle: 'Computed from your Step 4, 8, and 10 data'),
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
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(subtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Landscape heatmap
// ─────────────────────────────────────────────────────────────────────────────

class _LandscapeCard extends StatelessWidget {
  final List<DayReflection> days;
  const _LandscapeCard({required this.days});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          children: [
            if (days.isEmpty)
              const Text('Complete a Step 10 review to start your landscape.',
                  style: TextStyle(color: Colors.grey))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: days
                    .map((d) => _LandscapeSquare(day: d))
                    .toList(),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(Colors.teal.shade50, 'Clear'),
                const SizedBox(width: 12),
                _legendDot(Colors.orange.shade100, '1–2 flags'),
                const SizedBox(width: 12),
                _legendDot(Colors.orange.shade400, '3–4 flags'),
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
          '${day.intensity} flag${day.intensity == 1 ? '' : 's'}'
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
// Individual insight card
// ─────────────────────────────────────────────────────────────────────────────

class _InsightCardWidget extends StatelessWidget {
  final InsightCard card;
  const _InsightCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentFor(card.level);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: accentColor.withOpacity(0.25), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon column
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(card.icon, color: accentColor, size: 22),
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
                        color: Colors.grey.shade600,
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
        return Colors.teal;
      case InsightLevel.neutral:
        return Colors.blueGrey;
      case InsightLevel.reflective:
        return Colors.deepPurple;
      case InsightLevel.attention:
        return Colors.deepOrange;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meeting attendance stats card
// ─────────────────────────────────────────────────────────────────────────────

class _MeetingStatsCard extends StatelessWidget {
  final AttendanceStats stats;
  const _MeetingStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.lifetimeCount == 0) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stat row ────────────────────────────────────────────────
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
                            ? Colors.deepOrange
                            : Colors.amber.shade700),
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
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
