import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/database/database.dart';
import 'core/services/key_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/onboarding_service.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Per-device database encryption key ──────────────────────────────────
  final dbKey = await KeyService.getOrCreateDatabaseKey();

  // ── First-run onboarding flag ────────────────────────────────────────────
  final hasSeenOnboarding = await OnboardingService.hasCompleted();

  // ── Notification service ─────────────────────────────────────────────────
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyReviewReminder(
    hour: NotificationService.defaultDailyReviewHour,
    minute: NotificationService.defaultDailyReviewMinute,
  );
  await notificationService.scheduleBedtimeMeditationReminder(
    hour: NotificationService.defaultBedtimeHour,
    minute: NotificationService.defaultBedtimeMinute,
  );

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWith((ref) {
          final db = AppDatabase(dbKey);
          ref.onDispose(() => db.close());
          return db;
        }),
      ],
      child: FearlessInventoryApp(showOnboarding: !hasSeenOnboarding),
    ),
  );
}

class FearlessInventoryApp extends ConsumerWidget {
  final bool showOnboarding;
  const FearlessInventoryApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Fearless Inventory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
