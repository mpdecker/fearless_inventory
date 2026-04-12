import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/onboarding_service.dart';

/// Whether first-run onboarding has been completed (persisted in secure storage).
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  return OnboardingService.hasCompleted();
});
