# Fearless Inventory — iOS Port & App Store Readiness Plan

**Created:** April 2, 2026
**Author:** Maat + Claude
**Status:** DRAFT — Awaiting review before implementation

---

## Executive Summary

Fearless Inventory is a mature, privacy-first 12-step recovery companion app currently targeting Android only. This plan covers every step required to produce a fully functional, App Store-approved iOS build that maintains 100% feature parity with the Android version. The approach is **test-first**: each phase includes specific test criteria that must pass before moving to the next.

The iOS folder does not currently exist. All Flutter dependencies are cross-platform Dart packages (no custom method channels), which significantly reduces porting risk. The primary work areas are: native iOS project scaffolding, platform permissions, signing/provisioning, SQLCipher compilation for iOS, notification configuration, App Store compliance, and building out a real test suite.

---

## Table of Contents

1. [Prerequisites & Apple Developer Setup](#phase-0-prerequisites--apple-developer-setup)
2. [iOS Project Scaffolding](#phase-1-ios-project-scaffolding)
3. [Database & Encryption (SQLCipher on iOS)](#phase-2-database--encryption-sqlcipher-on-ios)
4. [Secure Storage (Keychain)](#phase-3-secure-storage-keychain)
5. [Notifications (iOS-Specific)](#phase-4-notifications-ios-specific)
6. [Location Services (CoreLocation)](#phase-5-location-services-corelocation)
7. [URL Launching & Deep Links](#phase-6-url-launching--deep-links)
8. [Export, Sharing & Printing](#phase-7-export-sharing--printing)
9. [UI/UX Audit for iOS Conventions](#phase-8-uiux-audit-for-ios-conventions)
10. [Comprehensive Test Suite](#phase-9-comprehensive-test-suite)
11. [App Store Compliance & Metadata](#phase-10-app-store-compliance--metadata)
12. [Build, Sign & Submit](#phase-11-build-sign--submit)
13. [Post-Launch](#phase-12-post-launch)
14. [Risk Register](#risk-register)
15. [Dependency Compatibility Matrix](#dependency-compatibility-matrix)

---

## Phase 0: Prerequisites & Apple Developer Setup

**Goal:** Establish all accounts, tooling, and credentials needed before writing any code.

### Steps

0.1. **Enroll in the Apple Developer Program** ($99/year)
   - Required for App Store distribution, TestFlight, and provisioning profiles
   - If using an organization account, a D-U-N-S number is required (allow 2–4 weeks)

0.2. **Set up a Mac build environment**
   - macOS Ventura 14+ with Xcode 16+ installed
   - Flutter SDK (stable channel, ≥ 3.22)
   - CocoaPods (`sudo gem install cocoapods`)
   - Verify: `flutter doctor` shows all iOS checks green

0.3. **Create App ID in Apple Developer Portal**
   - Bundle ID: `com.fearlessinventory.fearlessInventory` (or chosen equivalent)
   - Enable capabilities: Push Notifications (local), Background Modes (if needed for notifications)

0.4. **Generate signing assets**
   - iOS Distribution Certificate (for App Store)
   - iOS Development Certificate (for testing)
   - Provisioning Profile (Development + Distribution)
   - Store securely; consider Fastlane `match` for team-based management

0.5. **Create App Store Connect listing (placeholder)**
   - Reserve the app name "Fearless Inventory"
   - Set primary category: Health & Fitness (or Lifestyle)
   - Secondary category: Reference

### Test Gate
- [ ] `flutter doctor` reports no iOS issues
- [ ] Xcode opens and builds a blank Flutter project to a simulator
- [ ] Apple Developer account is active with valid certificates

---

## Phase 1: iOS Project Scaffolding

**Goal:** Generate the iOS project structure and verify a bare app compiles and runs on simulator.

### Steps

1.1. **Generate the iOS platform folder**
   ```bash
   cd fearless_inventory
   flutter create --platforms ios .
   ```
   This creates `ios/` with Runner project, Podfile, Info.plist, etc.

1.2. **Set deployment target**
   - In `ios/Podfile`, set: `platform :ios, '15.0'`
   - Rationale: iOS 15 covers ~98% of active devices and is required by several dependencies (geolocator, flutter_local_notifications)

1.3. **Configure the Podfile for SQLCipher** (see Phase 2 for details)

1.4. **Set Bundle ID and display name**
   - Open `ios/Runner.xcodeproj` in Xcode
   - Set Bundle Identifier: `com.fearlessinventory.fearlessInventory`
   - Set Display Name: "Fearless Inventory"
   - Set version: match current Android version

1.5. **Run `flutter pub get` and `pod install`**
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   ```

1.6. **Build and run on iOS Simulator**
   ```bash
   flutter run -d "iPhone 16 Pro"
   ```

### Test Gate
- [ ] `flutter build ios --no-codesign` completes without errors
- [ ] App launches on iOS Simulator and shows the onboarding screen
- [ ] No CocoaPods dependency resolution errors

---

## Phase 2: Database & Encryption (SQLCipher on iOS)

**Goal:** Ensure the Drift ORM + SQLCipher encrypted database works identically on iOS.

### Background

The app uses `sqlite3_flutter_libs` which bundles a standard SQLite build. For SQLCipher encryption on iOS, additional configuration is needed. The `sqlite3_flutter_libs` package supports SQLCipher via a CocoaPods override.

### Steps

2.1. **Option A — Use `sqlcipher_flutter_libs` (recommended)**
   - Replace `sqlite3_flutter_libs` with `sqlcipher_flutter_libs` in `pubspec.yaml`
   - This package bundles SQLCipher for both Android and iOS
   - Requires: update the Drift database opener to use `sqlcipher_flutter_libs`'s setup
   - Verify the Android build still works after the swap

2.2. **Option B — CocoaPods SQLCipher override (if Option A has issues)**
   - In `ios/Podfile`, add:
     ```ruby
     pod 'SQLCipher', '~> 4.5'
     ```
   - Override the default SQLite with SQLCipher using a post-install script

2.3. **Verify encryption key flow on iOS**
   - `KeyService.getOrCreateDatabaseKey()` uses `flutter_secure_storage`
   - On iOS, this maps to the Keychain → should work out of the box
   - Verify key generation, storage, and retrieval in integration test

2.4. **Verify all 21 tables create correctly**
   - Run the app on simulator, trigger database initialization
   - Verify schema version 12 migration chain executes

2.5. **Test data round-trip**
   - Write unit tests that insert and query from every table
   - Verify foreign key constraints work (e.g., Sponsee → TwelfthStepCalls cascade)

### Test Gate
- [ ] Unit test: database opens with encryption key on iOS
- [ ] Unit test: all 21 tables are created at schema v12
- [ ] Unit test: CRUD operations on each table succeed
- [ ] Unit test: foreign key cascades (Harms→Amends, Sponsees→children) work
- [ ] Unit test: `wipeAllData()` clears all tables
- [ ] Integration test: app launches, creates database, writes a resentment, reads it back

---

## Phase 3: Secure Storage (Keychain)

**Goal:** Verify `flutter_secure_storage` works correctly with iOS Keychain for all stored keys.

### Stored Keys

| Key | Purpose |
|-----|---------|
| `fearless_db_encryption_key_v1` | SQLCipher database encryption key |
| `fearless_onboarding_complete_v1` | Onboarding completion flag |
| `fearless_tab_visited_*` | Tab-visit tracking (1–4) |
| `fearless_sobriety_date` | User's sobriety date |

### Steps

3.1. **Configure Keychain access**
   - In `ios/Runner/Runner.entitlements`, ensure Keychain Sharing is enabled if needed
   - Set accessibility level: `kSecAttrAccessibleAfterFirstUnlock` (default for flutter_secure_storage on iOS)
   - This allows notifications and background tasks to access the key

3.2. **Verify Keychain behavior across app lifecycle**
   - Install → generate key → verify stored
   - Kill app → relaunch → verify key retrieved (not regenerated)
   - Delete app → reinstall → verify new key generated (Keychain may persist; handle gracefully)

3.3. **Handle the Keychain persistence gotcha**
   - iOS Keychain data can persist after app deletion
   - If a user reinstalls, the old encryption key may still be in Keychain but the database file is gone
   - Add logic: if key exists in Keychain but no database file, delete the stale key and generate fresh

### Test Gate
- [ ] Unit test: key generation and retrieval from Keychain
- [ ] Integration test: app reinstall scenario handled correctly
- [ ] Manual test: fresh install on simulator creates key and database
- [ ] Manual test: app kill + relaunch preserves data

---

## Phase 4: Notifications (iOS-Specific)

**Goal:** Configure local notifications for iOS with proper permission flow and scheduling.

### Steps

4.1. **Add notification capabilities in Xcode**
   - In Runner target → Signing & Capabilities → add "Push Notifications" (even for local, this enables the notification framework)
   - Add "Background Modes" → check "Background fetch" and "Remote notifications" if needed

4.2. **Configure `flutter_local_notifications` for iOS**
   - In `AppDelegate.swift`, add:
     ```swift
     if #available(iOS 10.0, *) {
       UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
     }
     ```
   - Set `DarwinInitializationSettings` in the notification service:
     ```dart
     const DarwinInitializationSettings(
       requestAlertPermission: true,
       requestBadgePermission: true,
       requestSoundPermission: true,
     )
     ```

4.3. **Update `NotificationService.init()` for iOS**
   - iOS does not use channels (Android concept); verify the code gracefully handles this
   - iOS requires explicit user permission before showing notifications
   - Implement provisional authorization (iOS 12+) for a better first-run UX:
     - Provisional notifications appear silently in Notification Center
     - User isn't interrupted with a permission dialog on first launch
     - They can upgrade to prominent notifications later

4.4. **Handle permission denial gracefully**
   - If user denies notification permission, the app must still function
   - Show a gentle reminder in Settings that notifications are off
   - Do NOT repeatedly prompt (violates App Store guidelines)

4.5. **Update `permission_handler` usage**
   - Remove `Permission.scheduleExactAlarm` on iOS (Android-only concept)
   - iOS handles notification scheduling through the UNNotificationCenter framework; no separate "exact alarm" permission exists

4.6. **Verify notification scheduling**
   - Daily Review at 21:00 local time
   - Bedtime Meditation at 22:30 local time
   - Both should repeat daily using `matchDateTimeComponents: DateTimeComponents.time`

### Test Gate
- [ ] Unit test: notification initialization completes without error on iOS
- [ ] Manual test: grant permission → notifications fire at scheduled times
- [ ] Manual test: deny permission → app functions normally, no crash
- [ ] Manual test: notification tap opens the app to the correct screen
- [ ] Unit test: no Android-only permission calls execute on iOS

---

## Phase 5: Location Services (CoreLocation)

**Goal:** Enable the Meeting Finder's "nearby meetings" feature using GPS on iOS.

### Steps

5.1. **Add Info.plist usage descriptions** (required by Apple)
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>Fearless Inventory uses your location to find recovery meetings near you.</string>
   <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
   <string>Fearless Inventory uses your location to find recovery meetings near you.</string>
   ```
   - Only "When In Use" is needed (no background location tracking)

5.2. **Verify `geolocator` plugin works on iOS**
   - The plugin uses CoreLocation under the hood
   - Test accuracy settings match Android behavior
   - Verify permission request flow shows the iOS system dialog

5.3. **Verify Nominatim geocoding**
   - HTTP requests to `nominatim.openstreetmap.org` should work under ATS (App Transport Security) since it's HTTPS
   - Test zip code and city name geocoding returns results

5.4. **Handle "Precise Location" toggle (iOS 14+)**
   - iOS lets users grant approximate vs. precise location
   - If approximate is granted, nearby meeting distances may be less accurate
   - Consider showing a note to the user if precision is reduced

### Test Gate
- [ ] Integration test: GPS returns coordinates on a real device
- [ ] Unit test: geocoding service returns results for "Boston, MA"
- [ ] Manual test: location permission dialog appears with correct description text
- [ ] Manual test: denying location still allows manual zip/city search
- [ ] Manual test: approximate location degrades gracefully

---

## Phase 6: URL Launching & Deep Links

**Goal:** Ensure all URL launches (Zoom, Maps, phone, web) work on iOS.

### Steps

6.1. **Verify `url_launcher` iOS support**
   - Add LSApplicationQueriesSchemes to `Info.plist`:
     ```xml
     <key>LSApplicationQueriesSchemes</key>
     <array>
       <string>tel</string>
       <string>zoomus</string>
       <string>https</string>
       <string>maps</string>
     </array>
     ```

6.2. **Test each URL scheme**
   - `tel:` → Phone dialer for meeting dial-in numbers
   - `zoomus://` → Zoom app (if installed, falls back to web)
   - `https://` → Safari for meeting web links
   - `maps://` or `https://maps.apple.com/` → Apple Maps for meeting locations
   - `geo:` → Note: iOS does not support `geo:` scheme natively; convert to Apple Maps URL

6.3. **Handle `geo:` scheme conversion**
   - Android uses `geo:lat,lng` for map links
   - iOS needs `https://maps.apple.com/?ll=lat,lng` or `maps://maps.apple.com/?ll=lat,lng`
   - Add a platform check in the meeting detail screen:
     ```dart
     if (Platform.isIOS) {
       // Convert geo: to maps://
     }
     ```

### Test Gate
- [ ] Manual test: tapping a phone number opens the dialer
- [ ] Manual test: tapping a Zoom link opens Zoom (or falls back to Safari)
- [ ] Manual test: tapping a meeting address opens Apple Maps
- [ ] Unit test: URL scheme conversion logic for geo: → maps://

---

## Phase 7: Export, Sharing & Printing

**Goal:** Verify PDF/Excel/CSV export and sharing work on iOS.

### Steps

7.1. **Verify `printing` package on iOS**
   - Uses UIPrintInteractionController under the hood
   - Test: generate a Step Four Worksheet PDF → print dialog appears

7.2. **Verify `share_plus` on iOS**
   - Uses UIActivityViewController
   - Test: share a generated PDF file → iOS share sheet appears
   - Verify the file is accessible from the share sheet (not a broken path)

7.3. **Verify `path_provider` paths**
   - iOS app sandbox paths differ from Android
   - `getApplicationDocumentsDirectory()` → iOS documents directory
   - `getTemporaryDirectory()` → iOS temp directory
   - Ensure export files are written to a shareable location

7.4. **Verify Excel and CSV export**
   - Generate an export → share → open in Files/Numbers
   - Verify UTF-8 encoding for any special characters in recovery content

### Test Gate
- [ ] Integration test: PDF generation completes without error
- [ ] Manual test: share sheet presents with generated PDF on iOS
- [ ] Manual test: printed PDF renders correctly
- [ ] Manual test: Excel file opens in Numbers or Google Sheets
- [ ] Manual test: CSV export contains correct data

---

## Phase 8: UI/UX Audit for iOS Conventions

**Goal:** Ensure the app feels native on iOS while maintaining a consistent brand.

### Steps

8.1. **Navigation patterns**
   - Bottom NavigationBar is standard on both platforms — no change needed
   - Verify iOS back swipe gesture works (Flutter handles this by default with `CupertinoPageRoute`)
   - Check: if using `MaterialPageRoute`, consider `CupertinoPageRoute` on iOS for native feel

8.2. **Scrolling physics**
   - Flutter uses `BouncingScrollPhysics` on iOS by default — verify this is active
   - Android uses `ClampingScrollPhysics` — should auto-switch per platform

8.3. **Text rendering**
   - iOS uses San Francisco font by default for system text
   - Verify the app's dark theme renders well on iOS (especially in Dynamic Type/accessibility settings)

8.4. **Safe areas**
   - Verify content respects the iPhone notch / Dynamic Island
   - Check status bar color/style in dark theme
   - Verify bottom safe area on iPhones without home button

8.5. **Haptic feedback**
   - If any haptic feedback is used, verify it works with iOS Taptic Engine

8.6. **Date/Time pickers**
   - Verify `showDatePicker` / `showTimePicker` render appropriately on iOS
   - Consider offering Cupertino-style pickers for a more native feel

8.7. **Keyboard behavior**
   - Test text input fields don't get obscured by the iOS keyboard
   - Verify `Scaffold.resizeToAvoidBottomInset` is working

8.8. **Dark mode compatibility**
   - The app uses a custom dark theme — verify it doesn't conflict with iOS system dark mode
   - Test: toggle iOS system dark mode on/off → app appearance stays consistent

### Test Gate
- [ ] Manual test: all 4 main tabs render correctly on iPhone SE (small), iPhone 16 (standard), iPhone 16 Pro Max (large)
- [ ] Manual test: back swipe gesture works on all navigation stacks
- [ ] Manual test: all scrollable lists have bounce physics
- [ ] Manual test: content respects safe areas on notch devices
- [ ] Manual test: keyboards don't obscure input fields
- [ ] Manual test: text is readable at all Dynamic Type sizes (Small → AX5)

---

## Phase 9: Comprehensive Test Suite

**Goal:** Build a real test suite — the app currently only has a single boot-verification test. This phase must run **in parallel** with Phases 1–8, not after.

### 9A. Unit Tests (run on every PR)

| Test Area | File(s) to Create | What to Test |
|-----------|--------------------|--------------|
| Database | `test/core/database/database_test.dart` | Table creation, schema v12, all migrations, CRUD on every table, foreign key cascades, wipeAllData |
| KeyService | `test/core/services/key_service_test.dart` | Key generation, retrieval, idempotency |
| OnboardingService | `test/core/services/onboarding_service_test.dart` | Flag persistence, tab visit tracking, reset |
| NotificationService | `test/core/services/notification_service_test.dart` | Initialization, scheduling calls, platform branching |
| Repositories (×14) | `test/data/repositories/*_test.dart` | Each repository's query, insert, update, delete methods |
| ExportService | `test/data/services/export_service_test.dart` | PDF generation, Excel output, CSV formatting |
| Meeting Adapters (×5) | `test/features/meetings/adapters/*_test.dart` | JSON parsing, DTO mapping, error handling, delta sync |
| LocationService | `test/features/meetings/services/location_service_test.dart` | Geocoding, distance calculation (Haversine), permission states |
| Providers | `test/features/*/providers/*_test.dart` | State transitions, error states, loading states |

### 9B. Widget Tests

| Test Area | What to Test |
|-----------|--------------|
| HomeScreen | 4-tab navigation, correct screen per tab |
| OnboardingScreen | Page progression, completion triggers |
| Inventory screens | Resentment/Fear/Harm entry forms, validation, list display |
| Meeting Finder | Search, filter, distance display, empty states |
| Daily Review | Form fields, submission, streak display |
| Insights | Chart rendering, metric cards |
| Settings | Export options, data wipe confirmation dialog |

### 9C. Integration Tests (run before release)

| Test | Description |
|------|-------------|
| Full onboarding flow | Launch → onboarding → home screen |
| Resentment lifecycle | Add resentment → edit → flag for sponsor → complete |
| Amends pipeline | Add harm → promote to amend → mark completed |
| Meeting sync | Trigger sync → verify meetings appear → log attendance |
| Daily review streak | Complete 3 consecutive reviews → verify streak count |
| Export flow | Enter data → export PDF → verify content |
| Data wipe | Enter data → wipe → verify all tables empty |
| Database migration | Open a v1 database → run migrations to v12 → verify data intact |

### 9D. Platform-Specific Tests

| Test | Platform | Description |
|------|----------|-------------|
| SQLCipher encryption | iOS + Android | Database is encrypted; raw file is unreadable |
| Keychain storage | iOS | Keys persist across app restart, cleared on fresh install |
| Notifications | iOS | Permission flow, scheduling, delivery |
| Location | iOS | Permission dialog, GPS accuracy, geocoding |
| URL schemes | iOS | tel:, zoomus://, maps:// all resolve correctly |
| Share sheet | iOS | File appears in UIActivityViewController |

### Test Gate
- [ ] `flutter test` passes with 0 failures
- [ ] Unit test coverage ≥ 80% for `lib/core/` and `lib/data/`
- [ ] All widget tests pass on iOS simulator
- [ ] Integration test suite passes end-to-end on a real iOS device

---

## Phase 10: App Store Compliance & Metadata

**Goal:** Prepare everything Apple requires for review.

### 10.1. App Store Review Guidelines — Key Compliance Areas

| Guideline | Concern | Mitigation |
|-----------|---------|------------|
| **1.1 — Objectionable Content** | Recovery content is sensitive but not objectionable | App is therapeutic/wellness; no graphic content |
| **1.2 — User Generated Content** | All data is local; no UGC sharing | Not applicable |
| **2.1 — App Completeness** | All features must work in review | Ensure meeting APIs respond; test on airplane mode |
| **2.3 — Accurate Metadata** | Screenshots must match actual app | Generate real screenshots from the iOS build |
| **4.2 — Minimum Functionality** | Must not be a "web wrapper" | Full native Flutter app with rich features — well above minimum |
| **5.1.1 — Data Collection** | Must declare in privacy nutrition labels | See 10.3 below |
| **5.1.2 — Data Use and Sharing** | No data shared with third parties | True — all local. Nominatim queries transmit location but no user ID |

### 10.2. Privacy Policy

Create and host a privacy policy that covers:
- Data collected: location (when in use), recovery journal entries (local only), meeting attendance (local only)
- Data storage: all data encrypted on-device using SQLCipher; encryption key stored in iOS Keychain
- Data sharing: none. No analytics, no crash reporting, no third-party SDKs collecting data
- Data deletion: user can wipe all data from within the app at any time
- Third-party services: Nominatim geocoding (transmits location query, no user identifier); AA/NA meeting APIs (fetches public meeting data, no user data transmitted)
- Children: app is not directed at children under 13
- Contact: support email for privacy inquiries

**Host the privacy policy at a public URL** (required for App Store submission). Options: GitHub Pages, a simple static site, or a page on fearlessinventory.com.

### 10.3. App Privacy Nutrition Labels

Apple requires disclosure of all data types. Based on the current app:

| Data Type | Collected? | Linked to User? | Used for Tracking? |
|-----------|-----------|-----------------|-------------------|
| Location | Yes (when in use) | No | No |
| Health & Fitness | No | — | — |
| Contacts | No | — | — |
| User Content | Yes (local only) | No | No |
| Identifiers | No | — | — |
| Usage Data | No | — | — |
| Diagnostics | No | — | — |

Declare: **"Data Not Linked to You"** for Location. Or, if the app doesn't transmit any location to a server that logs it, declare **"Data Not Collected"** (since Nominatim does not log by policy, but Apple may interpret this differently — be conservative).

### 10.4. App Store Metadata

| Field | Value |
|-------|-------|
| App Name | Fearless Inventory |
| Subtitle | 12-Step Recovery Companion |
| Category | Health & Fitness |
| Secondary Category | Lifestyle |
| Age Rating | 12+ (Infrequent/Mild: Medical/Treatment Information) |
| Price | Free |
| Description | (see draft below) |
| Keywords | recovery, AA, NA, 12 step, inventory, sobriety, meetings, step work, amends, meditation |
| Support URL | (to be created) |
| Privacy Policy URL | (to be hosted) |

**App Store Description Draft:**

> Fearless Inventory is a private, encrypted companion for 12-step recovery work. Built for members of AA, NA, OA, and all 12-step fellowships, it guides you through the inventory and living-amends process from Step 4 through Step 12.
>
> YOUR RECOVERY, YOUR DEVICE
> All data stays on your phone, encrypted with military-grade SQLCipher encryption. No accounts. No cloud. No one sees your inventory but you.
>
> FEATURES
> • Step 4 Inventory — structured entry for resentments, fears, and harms
> • Steps 5–12 — guided workflow for the full step sequence
> • Daily Review — Step 10 check-in with streak tracking
> • Meeting Finder — search AA and NA meetings by location with GPS
> • Amends Tracker — plan and track your living amends
> • Meditation Timer — Step 11 meditation and reflection tools
> • Journal — daily entries with step and tradition tags
> • Sponsee Management — track sponsees' progress and check-ins
> • Service Tracker — log 12th-step calls and commitments
> • Insights Dashboard — recovery trends and growth metrics
> • Export — PDF, Excel, and CSV export for sponsor work
>
> NOT AFFILIATED with AA World Services, Inc., NA World Services, or any 12-step fellowship.

### 10.5. Screenshots

Required: at minimum, screenshots for iPhone 6.7" (iPhone 15 Pro Max / 16 Pro Max) and iPhone 6.5" (iPhone 11 Pro Max). iPad screenshots are optional but recommended if the app supports iPad.

Capture:
1. Onboarding screen (value proposition)
2. Dashboard with sobriety counter and insights
3. Step 4 inventory list (with sample data)
4. Meeting Finder with map/list view
5. Daily Review form
6. Meditation timer
7. Insights/trends charts

### 10.6. App Icon

- Must provide a 1024×1024 PNG (no alpha channel, no rounded corners — Apple applies rounding)
- Must be included in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Use the same design language as the Android icon for brand consistency

### Test Gate
- [ ] Privacy policy is written and hosted at a public URL
- [ ] All App Store metadata fields are filled in App Store Connect
- [ ] Screenshots are captured from the actual iOS build
- [ ] App icon renders correctly on iOS home screen
- [ ] Nutrition labels accurately reflect data practices
- [ ] App disclaimer about non-affiliation with AA/NA is visible in-app

---

## Phase 11: Build, Sign & Submit

**Goal:** Produce a signed IPA, test via TestFlight, then submit for App Store review.

### Steps

11.1. **Configure signing in Xcode**
   - Select the iOS Distribution certificate and provisioning profile
   - Enable "Automatically manage signing" or configure manually
   - Set the correct Team ID

11.2. **Build the release IPA**
   ```bash
   flutter build ipa --release
   ```
   - This produces `build/ios/ipa/fearless_inventory.ipa`

11.3. **Upload to App Store Connect**
   ```bash
   xcrun altool --upload-app -f build/ios/ipa/fearless_inventory.ipa -t ios -u "your@email.com" -p "app-specific-password"
   ```
   - Or use Transporter.app (Mac App Store, free)

11.4. **TestFlight internal testing**
   - Add internal testers (up to 25 without review)
   - Test every feature on at least 2 real devices:
     - Older device: iPhone SE (3rd gen) or iPhone 11
     - Newer device: iPhone 15 or 16
   - Run the full integration test suite on device

11.5. **TestFlight external testing (optional but recommended)**
   - Invite beta testers from the recovery community
   - Requires a lightweight App Review (usually 24–48 hours)
   - Gather feedback on UX, accessibility, and any crashes

11.6. **Submit for App Store Review**
   - Select the build in App Store Connect
   - Fill in all metadata, screenshots, privacy information
   - Submit for review
   - Typical review time: 24–48 hours (can be longer for first submission)
   - Be prepared to respond to reviewer questions about:
     - Health/medical claims (ensure the app makes no medical claims)
     - Data encryption (they may ask about export regulations — SQLCipher is widely used and generally fine)

### Test Gate
- [ ] Release IPA builds without warnings or errors
- [ ] TestFlight build installs and runs on 2+ real devices
- [ ] All integration tests pass on TestFlight build
- [ ] No crash reports in TestFlight after 48 hours of beta testing
- [ ] App Store review submission is accepted (no rejection)

---

## Phase 12: Post-Launch

### Steps

12.1. **Monitor crash reports** via App Store Connect / Xcode Organizer

12.2. **Respond to App Store reviews** promptly

12.3. **Set up a CI/CD pipeline** for ongoing iOS builds
   - GitHub Actions with `macos-latest` runner
   - Or Codemagic / Bitrise for Flutter-specific CI

12.4. **Plan for ongoing iOS maintenance**
   - Track iOS version deprecations (raise minimum deployment target as needed)
   - Update CocoaPods dependencies regularly
   - Test on new iPhone models as they launch (especially screen sizes)

12.5. **Consider iPad support**
   - Evaluate if the recovery community would benefit from an iPad-optimized layout
   - If so, add adaptive layouts with `LayoutBuilder` and `MediaQuery`

---

## Risk Register

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|------------|
| R1 | SQLCipher fails to compile on iOS | Low | Critical | `sqlcipher_flutter_libs` is well-maintained; fallback: manual CocoaPods integration |
| R2 | Keychain data persists after uninstall | High | Medium | Add stale-key detection logic (key exists but no DB file → regenerate) |
| R3 | App Store rejection for health claims | Medium | High | Audit all copy; add "not medical advice" disclaimer; avoid clinical language |
| R4 | Meeting APIs fail during Apple review | Medium | High | Add graceful offline handling; cache last-known meeting data; show meaningful empty states |
| R5 | Notification permission denied by most iOS users | Medium | Low | Use provisional notifications (iOS 12+); don't gate functionality on notification permission |
| R6 | `geo:` URL scheme doesn't work on iOS | Certain | Medium | Implement platform check and convert to `maps://` URL on iOS |
| R7 | Dynamic Type breaks layout | Medium | Medium | Test with accessibility font sizes; use flexible layouts |
| R8 | Export encryption compliance (ECCN) | Low | Medium | SQLCipher uses AES-256; may need to file an annual self-classification report with BIS |
| R9 | Apple rejects due to "minimum functionality" | Very Low | High | App is feature-rich with 12+ distinct features — well above threshold |
| R10 | Slow App Store review for first submission | Medium | Low | Budget 1–2 weeks; use TestFlight external testing as interim distribution |

---

## Dependency Compatibility Matrix

| Package | iOS Support | Notes |
|---------|------------|-------|
| `hooks_riverpod` | ✅ Pure Dart | No platform code |
| `flutter_hooks` | ✅ Pure Dart | No platform code |
| `drift` | ✅ Pure Dart | ORM layer is platform-agnostic |
| `sqlite3_flutter_libs` | ✅ iOS via CocoaPods | Must verify SQLCipher variant |
| `path_provider` | ✅ iOS native | Uses iOS file system APIs |
| `flutter_secure_storage` | ✅ iOS Keychain | Well-tested on iOS |
| `flutter_local_notifications` | ✅ iOS native | Requires UNUserNotificationCenter setup |
| `permission_handler` | ✅ iOS native | Remove Android-only permissions on iOS |
| `geolocator` | ✅ CoreLocation | Requires Info.plist usage descriptions |
| `url_launcher` | ✅ iOS native | Need LSApplicationQueriesSchemes |
| `share_plus` | ✅ UIActivityViewController | Works out of the box |
| `printing` | ✅ UIPrintInteractionController | Works out of the box |
| `pdf` | ✅ Pure Dart | No platform code |
| `excel` | ✅ Pure Dart | No platform code |
| `csv` | ✅ Pure Dart | No platform code |
| `http` | ✅ Pure Dart | No platform code |
| `intl` | ✅ Pure Dart | No platform code |
| `table_calendar` | ✅ Pure Dart | No platform code |
| `cupertino_icons` | ✅ iOS native | Already included |
| `timezone` | ✅ Pure Dart | No platform code |

---

## Estimated Timeline

| Phase | Duration | Dependencies |
|-------|----------|-------------|
| Phase 0: Prerequisites | 1–4 weeks | Apple Developer enrollment (D-U-N-S if org) |
| Phase 1: Scaffolding | 1 day | Phase 0 |
| Phase 2: Database | 2–3 days | Phase 1 |
| Phase 3: Secure Storage | 1 day | Phase 1 |
| Phase 4: Notifications | 1–2 days | Phase 1 |
| Phase 5: Location | 1 day | Phase 1 |
| Phase 6: URL Launching | 0.5 days | Phase 1 |
| Phase 7: Export | 0.5 days | Phase 1 |
| Phase 8: UI/UX Audit | 2–3 days | Phases 2–7 |
| Phase 9: Test Suite | 5–7 days | Runs in parallel with Phases 2–8 |
| Phase 10: App Store Prep | 3–5 days | Phase 8 |
| Phase 11: Build & Submit | 3–7 days | Phase 9, Phase 10 |
| Phase 12: Post-Launch | Ongoing | Phase 11 |

**Total estimated time: 3–6 weeks** (assuming Apple Developer account is already active and a Mac is available)

---

## Implementation Order Recommendation

```
Week 1:  Phase 0 (if not done) + Phase 1 + Phase 2 + Phase 3
         Begin Phase 9 (test suite) in parallel

Week 2:  Phase 4 + Phase 5 + Phase 6 + Phase 7
         Continue Phase 9

Week 3:  Phase 8 (UI/UX audit and fixes)
         Phase 9 (complete test suite)
         Begin Phase 10 (App Store prep)

Week 4:  Phase 10 (finalize) + Phase 11 (build, TestFlight, submit)

Week 5+: Phase 11 (App Store review) + Phase 12 (post-launch)
```

---

## Decision Points for Discussion

Before beginning implementation, the following decisions need your input:

1. **Apple Developer Account**: Do you have one already, or do we need to enroll? Individual ($99/yr) or Organization (requires D-U-N-S)?

2. **Bundle ID**: Is `com.fearlessinventory.fearlessInventory` the desired iOS bundle ID, or do you want something different?

3. **SQLCipher approach**: Should we go with Option A (`sqlcipher_flutter_libs` package swap) or Option B (CocoaPods manual configuration)?

4. **Minimum iOS version**: iOS 15.0 is recommended (covers ~98% of devices). Do you have a reason to go lower (14.0) or higher (16.0)?

5. **iPad support**: Should we include iPad layouts in v1, or defer to a future release?

6. **Privacy policy hosting**: Where should the privacy policy live? GitHub Pages? A custom domain?

7. **TestFlight beta**: Do you want an external beta period with community testers, or go straight to App Store after internal testing?

8. **CI/CD**: Any preference for build automation? (GitHub Actions, Codemagic, Bitrise, or manual builds?)

9. **App icon**: Do you have an existing 1024×1024 icon asset, or does one need to be designed?

10. **Analytics**: The app currently has zero analytics. Do you want to add crash reporting (e.g., Firebase Crashlytics, Sentry) before the iOS launch, or keep it analytics-free?

---

*This plan is a living document. Update it as decisions are made and phases are completed.*
