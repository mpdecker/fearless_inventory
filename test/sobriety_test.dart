import 'package:flutter_test/flutter_test.dart';
import 'package:fearless_inventory/core/services/sobriety_service.dart';

void main() {
  group('SobrietyService Calculations', () {
    test('daysSober calculates correct number of calendar days', () {
      final now = DateTime.now();
      // Today
      expect(SobrietyService.daysSober(now), 0);

      // Yesterday
      final yesterday = now.subtract(const Duration(days: 1));
      expect(SobrietyService.daysSober(yesterday), 1);

      // Future date
      final future = now.add(const Duration(days: 5));
      expect(SobrietyService.daysSober(future), 0);
    });

    test('currentMilestone returns expected milestones based on days', () {
      expect(SobrietyService.currentMilestone(15), null);
      expect(SobrietyService.currentMilestone(30), SobrietyMilestone.thirtyDays);
      expect(SobrietyService.currentMilestone(45), SobrietyMilestone.thirtyDays);
      expect(SobrietyService.currentMilestone(60), SobrietyMilestone.sixtyDays);
      expect(SobrietyService.currentMilestone(365), SobrietyMilestone.oneYear);
      expect(SobrietyService.currentMilestone(4000), SobrietyMilestone.tenYears);
    });

    test('nextMilestone returns the upcoming milestone', () {
      expect(SobrietyService.nextMilestone(0), SobrietyMilestone.thirtyDays);
      expect(SobrietyService.nextMilestone(30), SobrietyMilestone.sixtyDays);
      expect(SobrietyService.nextMilestone(364), SobrietyMilestone.oneYear);
      expect(SobrietyService.nextMilestone(4000), null);
    });
  });
}
