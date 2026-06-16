import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/features/insights/providers/insights_extended_providers.dart';

void main() {
  group('DisturberBreakdown', () {
    test('fractionOf returns 0 when there are no reviews', () {
      const b = DisturberBreakdown(
        resentful: 0,
        selfish: 0,
        dishonest: 0,
        afraid: 0,
        totalReviews: 0,
      );
      expect(b.fractionOf(0), 0.0);
    });

    test('fractionOf and maxCount', () {
      const b = DisturberBreakdown(
        resentful: 2,
        selfish: 5,
        dishonest: 1,
        afraid: 3,
        totalReviews: 10,
      );
      expect(b.fractionOf(b.selfish), 0.5);
      expect(b.maxCount, 5);
    });
  });

  group('AmendsJourney', () {
    test('completedFraction and completedPct', () {
      const j = AmendsJourney(
        total: 8,
        step8: 2,
        pending: 3,
        completed: 3,
      );
      expect(j.completedFraction, closeTo(0.375, 1e-9));
      expect(j.completedPct, 38);
    });

    test('handles empty total', () {
      const j = AmendsJourney(
        total: 0,
        step8: 0,
        pending: 0,
        completed: 0,
      );
      expect(j.completedFraction, 0.0);
      expect(j.completedPct, 0);
    });
  });

  group('MeetingMomentum', () {
    test('delta, isGrowing, hasEnoughData', () {
      const m = MeetingMomentum(thisMonth: 5, priorMonth: 3);
      expect(m.delta, 2);
      expect(m.isGrowing, isTrue);
      expect(m.hasEnoughData, isTrue);
    });

    test('hasEnoughData is false when counts are small', () {
      const m = MeetingMomentum(thisMonth: 1, priorMonth: 2);
      expect(m.hasEnoughData, isFalse);
    });
  });

  group('WeeklyPillars', () {
    test('activeCount counts true flags', () {
      const p = WeeklyPillars(
        didReview: true,
        didMeditation: false,
        didMeeting: true,
        didJournal: true,
        didSponsorCall: false,
        didService: true,
      );
      expect(p.activeCount, 4);
    });
  });

  group('DayActivity', () {
    test('hasAnything is false when all false', () {
      final d = DateTime(2026, 1, 15);
      final a = DayActivity(
        date: d,
        hasReview: false,
        hasMeditation: false,
        hasMeeting: false,
        hasJournalEntry: false,
      );
      expect(a.hasAnything, isFalse);
    });

    test('hasAnything is true when any flag is set', () {
      final d = DateTime(2026, 1, 15);
      final a = DayActivity(
        date: d,
        hasReview: false,
        hasMeditation: true,
        hasMeeting: false,
        hasJournalEntry: false,
      );
      expect(a.hasAnything, isTrue);
    });
  });

  group('ServiceInsights', () {
    test('hasAnyActivity', () {
      expect(
        const ServiceInsights(
          activeCommitments: 0,
          callsThisMonth: 0,
          callsLastMonth: 0,
          activeSponsees: 0,
          avgSponseeStep: 0,
        ).hasAnyActivity,
        isFalse,
      );
      expect(
        const ServiceInsights(
          activeCommitments: 1,
          callsThisMonth: 0,
          callsLastMonth: 0,
          activeSponsees: 0,
          avgSponseeStep: 0,
        ).hasAnyActivity,
        isTrue,
      );
    });
  });

  group('FearInsights', () {
    test('pctWorked rounds correctly', () {
      const f = FearInsights(total: 3, withMyPart: 1);
      expect(f.pctWorked, 33);
      expect(f.hasAny, isTrue);
    });
  });

  group('SponsorCallInsights', () {
    test('hasCalls', () {
      expect(
        const SponsorCallInsights(
          callsThisWeek: 0,
          callsLastWeek: 0,
          callsLast4Weeks: 0,
          weekStreak: 0,
        ).hasCalls,
        isFalse,
      );
      expect(
        const SponsorCallInsights(
          callsThisWeek: 1,
          callsLastWeek: 0,
          callsLast4Weeks: 1,
          weekStreak: 1,
        ).hasCalls,
        isTrue,
      );
    });
  });

  group('Step10TypeInsights', () {
    test('hasData', () {
      expect(
        const Step10TypeInsights(
          morningCount: 0,
          spotCheckCount: 0,
          nightlyCount: 0,
          morningSignalRate: 0,
          spotCheckSignalRate: 0,
          nightlySignalRate: 0,
          totalCount: 0,
        ).hasData,
        isFalse,
      );
    });
  });

  group('JournalInsights', () {
    test('holds aggregated journal stats', () {
      final j = JournalInsights(
        totalEntries: 5,
        stepsCovered: 3,
        coveredSteps: {1, 4, 10},
        last7DaysCount: 2,
        lastEntryAt: DateTime(2026, 4, 1),
      );
      expect(j.stepsCovered, 3);
      expect(j.coveredSteps, {1, 4, 10});
    });
  });
}
