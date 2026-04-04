import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/database.dart';
import 'core/navigation/notification_navigation.dart';
import 'core/navigation/root_navigator.dart';
import 'core/services/key_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/onboarding_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF12121F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Per-device database encryption key ──────────────────────────────────
  final dbFile = await KeyService.productionDatabaseFile();
  await KeyService.clearStaleEncryptionKeyIfDatabaseMissing(dbFile);
  final dbKey = await KeyService.getOrCreateDatabaseKey();

  // ── First-run onboarding flag ────────────────────────────────────────────
  final hasSeenOnboarding = await OnboardingService.hasCompleted();

  // ── Notification service ─────────────────────────────────────────────────
  final notificationService = NotificationService();
  await notificationService.init(
    onNotificationResponse: navigateFromNotificationTap,
  );
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

class FearlessInventoryApp extends ConsumerStatefulWidget {
  final bool showOnboarding;
  const FearlessInventoryApp({super.key, required this.showOnboarding});

  @override
  ConsumerState<FearlessInventoryApp> createState() =>
      _FearlessInventoryAppState();
}

class _FearlessInventoryAppState extends ConsumerState<FearlessInventoryApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.showOnboarding) {
        NotificationService().processPendingLaunchNotification();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'Fearless Inventory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      // Locked dark palette: iOS/Android system appearance does not override.
      themeMode: ThemeMode.dark,
      home: widget.showOnboarding
          ? const OnboardingScreen()
          : const HomeScreen(),
    );
  }
}
