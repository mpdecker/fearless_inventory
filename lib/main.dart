import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/database/database.dart';
import 'core/navigation/bootstrap_shell.dart';
import 'core/navigation/notification_navigation.dart';
import 'core/navigation/root_navigator.dart';
import 'core/providers/app_lock_provider.dart';
import 'core/providers/guest_mode_provider.dart';
import 'core/services/biometric_service.dart';
import 'core/services/guest_mode_service.dart';
import 'core/services/key_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/onboarding_service.dart';
import 'core/services/pin_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

/// Central sink for uncaught errors. Presents them in debug and logs them
/// everywhere; a crash reporter (Crashlytics/Sentry) would be forwarded here.
void _reportError(String source, Object error, StackTrace? stack) {
  debugPrint('[$source] $error');
  if (stack != null) debugPrint('$stack');
  // TODO(release): forward to a crash reporter once one is chosen.
}

void main() {
  // Run the whole app inside a guarded zone so an error during startup or in
  // any async callback is caught and logged instead of white-screening the
  // app with no diagnostics.
  runZonedGuarded(_bootstrap, (error, stack) {
    _reportError('Uncaught zone error', error, stack);
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Framework build/layout/paint errors → present (debug) + log (all builds).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _reportError('FlutterError', details.exception, details.stack);
  };
  // Uncaught async errors that reach the engine.
  PlatformDispatcher.instance.onError = (error, stack) {
    _reportError('PlatformDispatcher', error, stack);
    return true;
  };
  // Neutral fallback instead of the raw grey error box in release builds.
  ErrorWidget.builder = (details) => _ReleaseErrorWidget(details: details);

  // Firebase is only used for optional cloud identity; a failure here must not
  // block a user who wants to use the app locally. Log and continue.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    _reportError('Firebase.initializeApp', e, st);
  }

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

  // ── Local-only (guest) mode flag ─────────────────────────────────────────
  // Resolved here so the sign-in gate decision is made without a flicker.
  final isGuest = await GuestModeService.isEnabled();

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
        // Seed guest mode from storage, same reason.
        guestModeProvider.overrideWith(() => _SeededGuestModeNotifier(isGuest)),
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

class _SeededGuestModeNotifier extends GuestModeNotifier {
  final bool _initial;
  _SeededGuestModeNotifier(this._initial);

  @override
  bool build() => _initial;
}

// ─────────────────────────────────────────────────────────────────────────────
// Release error widget — replaces the default grey box for build errors
// ─────────────────────────────────────────────────────────────────────────────

class _ReleaseErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  const _ReleaseErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    // In debug, keep the informative red screen.
    if (kDebugMode) return ErrorWidget(details.exception);
    return Container(
      color: AppColors.scaffold,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: const Text(
        'Something went wrong on this screen.\nPlease try again.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
      ),
    );
  }
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
