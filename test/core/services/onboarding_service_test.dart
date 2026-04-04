import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/services/onboarding_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('OnboardingService', () {
    test('hasCompleted is false until markComplete', () async {
      expect(await OnboardingService.hasCompleted(), isFalse);
      await OnboardingService.markComplete();
      expect(await OnboardingService.hasCompleted(), isTrue);
    });

    test('markComplete is idempotent', () async {
      await OnboardingService.markComplete();
      await OnboardingService.markComplete();
      expect(await OnboardingService.hasCompleted(), isTrue);
    });

    test('tab visit tracking and reset', () async {
      expect(await OnboardingService.hasVisitedTab(1), isFalse);
      await OnboardingService.markTabVisited(1);
      expect(await OnboardingService.hasVisitedTab(1), isTrue);

      await OnboardingService.markComplete();
      await OnboardingService.reset();

      expect(await OnboardingService.hasCompleted(), isFalse);
      expect(await OnboardingService.hasVisitedTab(1), isFalse);
    });
  });
}
