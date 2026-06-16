import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/database/database.dart';
import 'core/navigation/bootstrap_shell.dart';
import 'core/navigation/notification_navigation.dart';
import 'core/navigation/root_navigator.dart';
import 'core/providers/app_lock_provider.dart';
import 'core/services/biometric_service.dart';
import 'core/services/key_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/onboarding_service.dart';
import 'core/services/pin_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.scaffold,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Per-device database encryption key ──────────────────────────────────
  final dbFile = await KeyService.productionDatabaseFile();
  await KeyService.clearStaleEncryptionKeyIfDatabaseMissing(dbFile);
  final dbKey = await KeyService.getOrCreateDatabaseKey();

  // ── First-run onboarding flag ────────────────────────────────────────────
  final hasSeenOnboarding = await OnboardingService.hasCompleted();

  // ── Resolve initial app-lock state before first frame ───────────────────
  // Doing this in main() avoids a loading-state flicker on the lock screen.
  final pinService = PinService();
  final hasPin = await pinService.hasPin();
  final biometricEnabled = await pinService.isBiometricEnabled();
  final biometricAvailable = await BiometricService().isAvailable();

  final initialLockState = AppLockState(
    isLoading: false,
    isLocked: hasPin, // locked on every cold start when a PIN exists
    hasPin: hasPin,
    biometricEnabled: biometricEnabled,
    biometricAvailable: biometricAvailable,
  );

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
        // Seed the lock provider with state already resolved — no flicker.
        appLockProvider.overrideWith(
          () => _SeededAppLockNotifier(initialLockState),
        ),
      ],
      child: FearlessInventoryApp(
        initialOnboardingComplete: hasSeenOnboarding,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Seeded notifier — skips async _initialize(), uses state from main()
// ─────────────────────────────────────────────────────────────────────────────

class _SeededAppLockNotifier extends AppLockNotifier {
  final AppLockState _initial;
  _SeededAppLockNotifier(this._initial);

  @override
  AppLockState build() => _initial;
}

// ─────────────────────────────────────────────────────────────────────────────
// Root app widget
// ─────────────────────────────────────────────────────────────────────────────

class FearlessInventoryApp extends ConsumerStatefulWidget {
  /// Used only to decide whether to process a pending notification on launch.
  final bool initialOnboardingComplete;
  const FearlessInventoryApp({
    super.key,
    required this.initialOnboardingComplete,
  });

  @override
  ConsumerState<FearlessInventoryApp> createState() =>
      _FearlessInventoryAppState();
}

class _FearlessInventoryAppState extends ConsumerState<FearlessInventoryApp>
    with WidgetsBindingObserver {
  /// Timestamp when the app moved to the background.
  DateTime? _backgroundedAt;

  /// Lock after this much background time.
  static const _lockTimeout = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialOnboardingComplete) {
        NotificationService().processPendingLaunchNotification();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Lock the app when it returns from background after [_lockTimeout].
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _backgroundedAt = DateTime.now();
      case AppLifecycleState.resumed:
        final backgrounded = _backgroundedAt;
        _backgroundedAt = null;
        if (backgrounded != null) {
          final elapsed = DateTime.now().difference(backgrounded);
          if (elapsed >= _lockTimeout) {
            ref.read(appLockProvider.notifier).lock();
          }
        }
      default:
        break;
    }
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
      home: const BootstrapShell(),
    );
  }
}
