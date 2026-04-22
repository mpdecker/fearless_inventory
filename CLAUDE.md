# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                          # Install dependencies
flutter analyze                          # Lint (flutter_lints); excludes packages/flutter_contacts/example_full via analysis_options.yaml
flutter test                             # Run tests
flutter test test/path/to_test.dart      # Run a single test file
dart run build_runner build              # Regenerate Drift ORM code after schema changes
dart run build_runner build --delete-conflicting-outputs  # Force-regenerate if conflicts
flutter build apk                        # Android build
flutter build ipa                        # iOS build
```

After any change to `lib/core/database/database.dart`, run `build_runner build` to regenerate `database.g.dart`.

## Architecture

**Fearless Inventory** is a 12-step recovery companion app (AA/NA/OA). It guides users through structured inventory work (Steps 4–12), daily reflection, meeting tracking, and sponsorship management.

### State Management: Riverpod

- `hooks_riverpod` + `flutter_hooks` throughout
- Database provider is overridden at app root in `main.dart` with the encrypted `AppDatabase`
- Feature-level providers live in `features/<feature>/providers/`
- Core cross-feature providers are in `lib/core/providers/`

### Data Layer: Drift ORM + Repository Pattern

- **Schema**: `lib/core/database/database.dart` (currently v14 — bump version and add migration when changing tables)
- **Generated code**: `lib/core/database/database.g.dart` (do not edit manually)
- **Repositories**: `lib/data/repositories/` — one per domain (inventory, meetings, amends, etc.)
- **Encryption**: SQLCipher via `KeyService`; sobriety date stored in Flutter Secure Storage

### Feature Modules

Each feature under `lib/features/<name>/` is self-contained with its own screens, providers, and widgets. The main `HomeScreen` uses a bottom `NavigationBar` with four tabs: Dashboard, Meetings, Step 12, Insights. Onboarding is shown only on first launch.

Key domain areas:
- **inventory** — Step 4 resentments/fears/harms entry and listing
- **review** — daily Step 10 review workflow and streak tracking
- **stepwork** — Steps 5–11 (ceremony, defects, shortcomings, meditation)
- **amends** — Steps 8–9 amends planning and execution
- **meetings** — Meeting Finder using AA Meeting Guide / NA APIs with attendance logs
- **insights** — Recovery metrics, trends, meditation history
- **journal** — Step/tradition journal with AI-assisted prompts (`lib/features/journal/`)
- **settings** — App settings including in-app literature reader (`lib/features/settings/`)

### Auth & App Lock

Two separate auth layers exist:

- **PIN / Biometric lock** — local, always-on. `PinService` stores the hashed PIN in Flutter Secure Storage; `BiometricService` wraps `local_auth`. State is managed by `AppLockNotifier` (`lib/core/providers/app_lock_provider.dart`). The app locks after 5 minutes in the background and re-requires the PIN/biometric.
- **Firebase Auth** — optional cloud identity (email/password, Google, Apple). `FirebaseAuthService` (`lib/core/services/firebase_auth_service.dart`) and stream providers in `lib/core/providers/auth_provider.dart`. Firebase is used **only** for identity; all recovery content stays on-device. Firebase is currently commented out in `main.dart` — run `flutterfire configure` and uncomment to activate.
- **Auth screens** live in `lib/features/auth/screens/`: `AppLockScreen`, `PinSetupScreen`, `LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen`, `AccountScreen`.

### App Initialization (`main.dart`)

Before the widget tree is built, four things are initialized:
1. Per-device encryption key (`KeyService`)
2. First-run onboarding flag (`OnboardingService`)
3. App-lock state (PIN + biometric) — seeded directly into `appLockProvider` to avoid a loading flicker
4. Notification schedules — daily review at 21:00, bedtime meditation at 22:30 (`NotificationService`)

Root routing decision (`_RootRouter`): Onboarding → PIN setup (first time) → Lock screen → HomeScreen.

### Database Schema Notes

The Drift schema is at version 9. Tables span all 12-step domains: Resentments, Fears, Harms, DailyReviews, Step5Completions, Defects, ShortcomingLogs, Amends, MeditationSessions, ServiceCommitments, TwelfthStepCalls, Sponsees, Meetings, AttendanceLogs, SyncMetas.

When adding or modifying tables: bump `schemaVersion`, add a `MigrationStrategy` step in `database.dart`, then re-run `build_runner`.
