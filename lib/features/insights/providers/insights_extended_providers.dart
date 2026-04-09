import 'package:drift/drift.dart' show OrderingTerm;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/sobriety_provider.dart';
import '../../../data/repositories/sponsor_call_repository.dart';
import '../../../data/repositories/review_repository.dart';
import '../../review/review_type.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Journal insights
// ─────────────────────────────────────────────────────────────────────────────

class JournalInsights {
  final int totalEntries;
  final int stepsCovered;       // steps 1–12 that have ≥ 1 entry
  final Set<int> coveredSteps;  // which step numbers have entries
  final int last7DaysCount;
  final DateTime? lastEntryAt;

  JournalInsights({
    required this.totalEntries,
    required this.stepsCovered,
    required this.coveredSteps,
    required this.last7DaysCount,
    this.lastEntryAt,
  });
}

final journalInsightsProvider =
    FutureProvider.autoDispose<JournalInsights>((ref) async {
  final db = ref.watch(databaseProvider);
  final entries = await db.select(db.journalEntries).get();

  final cutoff7 = DateTime.now().subtract(const Duration(days: 7));
  final stepSet = <int>{};
  int recent = 0;
  DateTime? last;

  for (final e in entries) {
    if (e.stepNumber != null) stepSet.add(e.stepNumber!);
    if (e.createdAt.isAfter(cutoff7)) recent++;
    if (last == null || e.createdAt.isAfter(last)) last = e.createdAt;
  }

  return JournalInsights(
    totalEntries: entries.length,
    stepsCovered: stepSet.length,
    coveredSteps: stepSet,
    last7DaysCount: recent,
    lastEntryAt: last,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// 7-day activity grid
// ─────────────────────────────────────────────────────────────────────────────

/// What the user did on a single calendar day.
class DayActivity {
  final DateTime date;
  final bool hasReview;
  final bool hasMeditation;
  final bool hasMeeting;
  final bool hasJournalEntry;

  const DayActivity({
    required this.date,
    required this.hasReview,
    required this.hasMeditation,
    required this.hasMeeting,
    required this.hasJournalEntry,
  });

  bool get hasAnything =>
      hasReview || hasMeditation || hasMeeting || hasJournalEntry;
}

final weekActivityProvider =
    FutureProvider.autoDispose<List<DayActivity>>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  // 7 days: oldest first (index 0 = 6 days ago, index 6 = today)
  final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
  final cutoff = DateTime(
      days.first.year, days.first.month, days.first.day); // midnight

  // Fetch each category — client-side filtering is fine for 7-day windows
  final results = await Future.wait([
    db.select(db.dailyReviews).get(),
    db.select(db.meditationSessions).get(),
    db.select(db.attendanceLogs).get(),
    db.select(db.journalEntries).get(),
  ]);

  final reviews     = results[0] as List<DailyReview>;
  final meditations = results[1] as List<MeditationSession>;
  final attendance  = results[2] as List<AttendanceLog>;
  final journal     = results[3] as List<JournalEntry>;

  String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}'
      '-${d.day.toString().padLeft(2, '0')}';

  final reviewDays = reviews
      .where((r) => !r.date.isBefore(cutoff))
      .map((r) => dateKey(r.date))
      .toSet();
  final meditationDays = meditations
      .where((s) => !s.completedAt.isBefore(cutoff))
      .map((s) => dateKey(s.completedAt))
      .toSet();
  final meetingDays = attendance
      .where((a) => !a.attendedAt.isBefore(cutoff))
      .map((a) => dateKey(a.attendedAt))
      .toSet();
  final journalDays = journal
      .where((j) => !j.createdAt.isBefore(cutoff))
      .map((j) => dateKey(j.createdAt))
      .toSet();

  return days
      .map((d) => DayActivity(
            date: d,
            hasReview: reviewDays.contains(dateKey(d)),
            hasMeditation: meditationDays.contains(dateKey(d)),
            hasMeeting: meetingDays.contains(dateKey(d)),
            hasJournalEntry: journalDays.contains(dateKey(d)),
          ))
      .toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Disturber breakdown — last 30 reviews
// ─────────────────────────────────────────────────────────────────────────────

class DisturberBreakdown {
  final int resentful;
  final int selfish;
  final int dishonest;
  final int afraid;
  final int totalReviews;

  const DisturberBreakdown({
    required this.resentful,
    required this.selfish,
    required this.dishonest,
    required this.afraid,
    required this.totalReviews,
  });

  /// Fraction (0.0 – 1.0) of reviews where [count] appeared.
  double fractionOf(int count) =>
      totalReviews == 0 ? 0.0 : (count / totalReviews).clamp(0.0, 1.0);

  int get maxCount {
    int m = resentful;
    if (selfish > m) m = selfish;
    if (dishonest > m) m = dishonest;
    if (afraid > m) m = afraid;
    return m;
  }
}

final disturberBreakdownProvider =
    FutureProvider.autoDispose<DisturberBreakdown>((ref) async {
  final db = ref.watch(databaseProvider);
  final reviews = await (db.select(db.dailyReviews)
        ..orderBy([(t) => OrderingTerm.desc(t.date)])
        ..limit(30))
      .get();

  int r = 0, s = 0, d = 0, a = 0;
  for (final rev in reviews) {
    if (rev.wasResentful) r++;
    if (rev.wasSelfish) s++;
    if (rev.wasDishonest) d++;
    if (rev.wasAfraid) a++;
  }

  return DisturberBreakdown(
    resentful: r,
    selfish: s,
    dishonest: d,
    afraid: a,
    totalReviews: reviews.length,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Service & Giving insights
// ─────────────────────────────────────────────────────────────────────────────

class ServiceInsights {
  final int activeCommitments;
  final int callsThisMonth;
  final int callsLastMonth;
  final int activeSponsees;
  final double avgSponseeStep; // 0 if no active sponsees

  const ServiceInsights({
    required this.activeCommitments,
    required this.callsThisMonth,
    required this.callsLastMonth,
    required this.activeSponsees,
    required this.avgSponseeStep,
  });

  bool get hasAnyActivity =>
      activeCommitments > 0 || callsThisMonth > 0 || activeSponsees > 0;
}

final serviceInsightsProvider =
    FutureProvider.autoDispose<ServiceInsights>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final thisMonthStart = DateTime(now.year, now.month, 1);
  final lastMonthStart = now.month > 1
      ? DateTime(now.year, now.month - 1, 1)
      : DateTime(now.year - 1, 12, 1);

  final results = await Future.wait([
    db.select(db.serviceCommitments).get(),
    db.select(db.twelfthStepCalls).get(),
    db.select(db.sponsees).get(),
  ]);

  final commitments = results[0] as List<ServiceCommitment>;
  final calls       = results[1] as List<TwelfthStepCall>;
  final sponsees    = results[2] as List<Sponsee>;

  final activeCommitments = commitments.where((c) => c.isActive).length;
  final callsThis = calls
      .where((c) => !c.occurredAt.isBefore(thisMonthStart))
      .length;
  final callsLast = calls
      .where((c) =>
          !c.occurredAt.isBefore(lastMonthStart) &&
          c.occurredAt.isBefore(thisMonthStart))
      .length;

  final active = sponsees.where((s) => s.isActive).toList();
  double avgStep = 0;
  if (active.isNotEmpty) {
    final steps = active.map((s) => (s.currentStep ?? 1).toDouble()).toList();
    avgStep = steps.reduce((a, b) => a + b) / steps.length;
  }

  return ServiceInsights(
    activeCommitments: activeCommitments,
    callsThisMonth: callsThis,
    callsLastMonth: callsLast,
    activeSponsees: active.length,
    avgSponseeStep: avgStep,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Amends journey stats
// ─────────────────────────────────────────────────────────────────────────────

class AmendsJourney {
  final int total;
  final int step8;
  final int pending;
  final int completed;

  const AmendsJourney({
    required this.total,
    required this.step8,
    required this.pending,
    required this.completed,
  });

  double get completedFraction =>
      total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
  int get completedPct => total == 0 ? 0 : ((completed / total) * 100).round();
}

final amendsJourneyProvider =
    FutureProvider.autoDispose<AmendsJourney>((ref) async {
  final db = ref.watch(databaseProvider);
  final all = await db.select(db.amends).get();

  final step8     = all.where((a) => a.status == 'step8').length;
  final pending   = all.where((a) => a.status == 'pending').length;
  final completed = all.where((a) => a.status == 'completed').length;

  return AmendsJourney(
    total: all.length,
    step8: step8,
    pending: pending,
    completed: completed,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Sobriety milestone
// ─────────────────────────────────────────────────────────────────────────────

class SobrietyMilestone {
  final int daysSober;
  final String? currentMilestoneLabel; // null until first milestone reached
  final String nextMilestoneLabel;
  final int daysToNext;
  final double progressToNext; // 0.0 – 1.0

  const SobrietyMilestone({
    required this.daysSober,
    required this.currentMilestoneLabel,
    required this.nextMilestoneLabel,
    required this.daysToNext,
    required this.progressToNext,
  });
}

final sobrietyMilestoneProvider = Provider<SobrietyMilestone?>((ref) {
  final days = ref.watch(daysSoberProvider);
  if (days == null) return null;
  return _computeMilestone(days);
});

SobrietyMilestone _computeMilestone(int days) {
  const milestones = <(int, String)>[
    (1, '1 day'),
    (7, '1 week'),
    (30, '30 days'),
    (60, '60 days'),
    (90, '90 days'),
    (180, '6 months'),
    (365, '1 year'),
    (730, '2 years'),
    (1095, '3 years'),
    (1460, '4 years'),
    (1825, '5 years'),
    (2555, '7 years'),
    (3650, '10 years'),
    (5475, '15 years'),
    (7300, '20 years'),
  ];

  String? current;
  int prevThreshold = 0;
  int nextThreshold = 1;
  String nextLabel = '1 day';

  for (int i = 0; i < milestones.length; i++) {
    final (threshold, label) = milestones[i];
    if (days >= threshold) {
      current = label;
      prevThreshold = threshold;
      if (i + 1 < milestones.length) {
        nextThreshold = milestones[i + 1].$1;
        nextLabel = milestones[i + 1].$2;
      } else {
        final nextYears = (((days ~/ 365) ~/ 5) + 1) * 5;
        nextThreshold = nextYears * 365;
        nextLabel = '$nextYears years';
      }
    } else if (current == null) {
      // Haven't hit any milestone yet — first upcoming one
      nextThreshold = threshold;
      nextLabel = label;
      break;
    } else {
      break;
    }
  }

  final range = nextThreshold - prevThreshold;
  final progress = range > 0
      ? ((days - prevThreshold) / range).clamp(0.0, 1.0)
      : 1.0;

  return SobrietyMilestone(
    daysSober: days,
    currentMilestoneLabel: current,
    nextMilestoneLabel: nextLabel,
    daysToNext: nextThreshold - days,
    progressToNext: progress,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sponsor call insights
// ─────────────────────────────────────────────────────────────────────────────

class SponsorCallInsights {
  /// Calls logged in the last 7 days.
  final int callsThisWeek;

  /// Calls logged in the 7 days before that (days 8–14 ago).
  final int callsLastWeek;

  /// Calls logged in the last 28 days.
  final int callsLast4Weeks;

  /// How many consecutive weeks (ending today) had at least one logged call.
  final int weekStreak;

  /// The most recent confirmed call time, or null if no calls have been logged.
  final DateTime? lastCallAt;

  const SponsorCallInsights({
    required this.callsThisWeek,
    required this.callsLastWeek,
    required this.callsLast4Weeks,
    required this.weekStreak,
    this.lastCallAt,
  });

  bool get hasCalls => callsLast4Weeks > 0;
}

final sponsorCallInsightsProvider =
    FutureProvider.autoDispose<SponsorCallInsights>((ref) async {
  final repo = ref.watch(sponsorCallRepositoryProvider);
  final now = DateTime.now();

  // Fetch enough history to calculate a 12-week streak ceiling.
  final logs = await repo.getRecentLogs(84); // 12 weeks

  final thisWeekCutoff = now.subtract(const Duration(days: 7));
  final lastWeekCutoff = now.subtract(const Duration(days: 14));
  final month4Cutoff = now.subtract(const Duration(days: 28));

  final callsThisWeek =
      logs.where((l) => l.confirmedAt.isAfter(thisWeekCutoff)).length;
  final callsLastWeek = logs
      .where((l) =>
          l.confirmedAt.isAfter(lastWeekCutoff) &&
          !l.confirmedAt.isAfter(thisWeekCutoff))
      .length;
  final callsLast4Weeks =
      logs.where((l) => l.confirmedAt.isAfter(month4Cutoff)).length;

  final lastCallAt = logs.isEmpty ? null : logs.first.confirmedAt;

  // Consecutive-week streak: walk backwards week by week from the current week.
  int streak = 0;
  for (int week = 0; week < 12; week++) {
    final weekEnd = now.subtract(Duration(days: week * 7));
    final weekStart = now.subtract(Duration(days: (week + 1) * 7));
    final hasCall =
        logs.any((l) => l.confirmedAt.isAfter(weekStart) && !l.confirmedAt.isAfter(weekEnd));
    if (hasCall) {
      streak++;
    } else {
      break;
    }
  }

  return SponsorCallInsights(
    callsThisWeek: callsThisWeek,
    callsLastWeek: callsLastWeek,
    callsLast4Weeks: callsLast4Weeks,
    weekStreak: streak,
    lastCallAt: lastCallAt,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Step 10 reviews by time-of-day context (last 30 days)
// ─────────────────────────────────────────────────────────────────────────────

class Step10TypeInsights {
  final int morningCount;
  final int spotCheckCount;
  final int nightlyCount;

  /// % of each type that flagged at least one disturber signal.
  final double morningSignalRate;   // 0.0 – 1.0
  final double spotCheckSignalRate;
  final double nightlySignalRate;

  /// Total reviews in the window.
  final int totalCount;

  const Step10TypeInsights({
    required this.morningCount,
    required this.spotCheckCount,
    required this.nightlyCount,
    required this.morningSignalRate,
    required this.spotCheckSignalRate,
    required this.nightlySignalRate,
    required this.totalCount,
  });

  bool get hasData => totalCount > 0;
}

double _signalRate(List<DailyReview> reviews) {
  if (reviews.isEmpty) return 0.0;
  final withSignal = reviews.where((r) =>
      r.wasResentful || r.wasSelfish || r.wasDishonest || r.wasAfraid).length;
  return withSignal / reviews.length;
}

final step10TypeInsightsProvider =
    FutureProvider.autoDispose<Step10TypeInsights>((ref) async {
  final repo = ref.watch(reviewRepositoryProvider);

  final results = await Future.wait([
    repo.getRecentByType(ReviewType.morning,    30),
    repo.getRecentByType(ReviewType.spotCheck,  30),
    repo.getRecentByType(ReviewType.nightly,    30),
  ]);

  final morning    = results[0];
  final spotCheck  = results[1];
  final nightly    = results[2];

  return Step10TypeInsights(
    morningCount:      morning.length,
    spotCheckCount:    spotCheck.length,
    nightlyCount:      nightly.length,
    morningSignalRate:    _signalRate(morning),
    spotCheckSignalRate:  _signalRate(spotCheck),
    nightlySignalRate:    _signalRate(nightly),
    totalCount:        morning.length + spotCheck.length + nightly.length,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Recovery pillars — which of the 6 core tools were used in the last 7 days
// ─────────────────────────────────────────────────────────────────────────────

class WeeklyPillars {
  final bool didReview;
  final bool didMeditation;
  final bool didMeeting;
  final bool didJournal;
  final bool didSponsorCall;
  final bool didService; // active commitment or a 12th-step call this week

  const WeeklyPillars({
    required this.didReview,
    required this.didMeditation,
    required this.didMeeting,
    required this.didJournal,
    required this.didSponsorCall,
    required this.didService,
  });

  int get activeCount => [
        didReview,
        didMeditation,
        didMeeting,
        didJournal,
        didSponsorCall,
        didService,
      ].where((b) => b).length;
}

final weeklyPillarsProvider =
    FutureProvider.autoDispose<WeeklyPillars>((ref) async {
  final db = ref.watch(databaseProvider);
  final cutoff = DateTime.now().subtract(const Duration(days: 7));

  final results = await Future.wait([
    db.select(db.dailyReviews).get(),
    db.select(db.meditationSessions).get(),
    db.select(db.attendanceLogs).get(),
    db.select(db.journalEntries).get(),
    db.select(db.sponsorCallLogs).get(),
    db.select(db.twelfthStepCalls).get(),
    db.select(db.serviceCommitments).get(),
  ]);

  final reviews      = results[0] as List<DailyReview>;
  final meditations  = results[1] as List<MeditationSession>;
  final attendance   = results[2] as List<AttendanceLog>;
  final journal      = results[3] as List<JournalEntry>;
  final sponsorCalls = results[4] as List<SponsorCallLog>;
  final stepCalls    = results[5] as List<TwelfthStepCall>;
  final commitments  = results[6] as List<ServiceCommitment>;

  return WeeklyPillars(
    didReview:      reviews.any((r) => r.createdAt.isAfter(cutoff)),
    didMeditation:  meditations.any((s) => s.completedAt.isAfter(cutoff)),
    didMeeting:     attendance.any((a) => a.attendedAt.isAfter(cutoff)),
    didJournal:     journal.any((j) => j.createdAt.isAfter(cutoff)),
    didSponsorCall: sponsorCalls.any((c) => c.confirmedAt.isAfter(cutoff)),
    didService:     stepCalls.any((c) => c.occurredAt.isAfter(cutoff)) ||
                    commitments.any((c) => c.isActive),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Meeting momentum — this month vs prior month
// ─────────────────────────────────────────────────────────────────────────────

class MeetingMomentum {
  final int thisMonth;
  final int priorMonth;

  const MeetingMomentum({required this.thisMonth, required this.priorMonth});

  int get delta => thisMonth - priorMonth;
  bool get isGrowing => thisMonth > priorMonth;
  bool get hasEnoughData => thisMonth + priorMonth >= 4;
}

final meetingMomentumProvider =
    FutureProvider.autoDispose<MeetingMomentum>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final cutoff30 = now.subtract(const Duration(days: 30));
  final cutoff60 = now.subtract(const Duration(days: 60));

  final logs = await db.select(db.attendanceLogs).get();
  final thisMonth = logs
      .where((l) => l.attendedAt.isAfter(cutoff30))
      .length;
  final priorMonth = logs
      .where((l) =>
          l.attendedAt.isAfter(cutoff60) && !l.attendedAt.isAfter(cutoff30))
      .length;

  return MeetingMomentum(thisMonth: thisMonth, priorMonth: priorMonth);
});

// ─────────────────────────────────────────────────────────────────────────────
// Fear work — inventory depth and myPart completion
// ─────────────────────────────────────────────────────────────────────────────

class FearInsights {
  final int total;
  final int withMyPart; // fears with a non-empty "my part" column

  const FearInsights({required this.total, required this.withMyPart});

  bool get hasAny => total > 0;
  int get pctWorked =>
      total == 0 ? 0 : ((withMyPart / total) * 100).round();
}

final fearInsightsProvider =
    FutureProvider.autoDispose<FearInsights>((ref) async {
  final db = ref.watch(databaseProvider);
  final fears = await db.select(db.fears).get();
  final withMyPart = fears.where((f) => f.myPart.trim().isNotEmpty).length;
  return FearInsights(total: fears.length, withMyPart: withMyPart);
});
