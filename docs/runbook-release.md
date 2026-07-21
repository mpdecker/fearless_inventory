# Runbook: Fearless Inventory — Release Deployment

**Owner:** Solo developer | **Frequency:** Per release (as needed)  
**Last updated:** 2026-04-12 | **App version (pubspec):** 1.0.0+1

---

## Purpose

Step-by-step procedure for building and releasing **Fearless Inventory** to the **Google Play Store** (Android) and **Apple App Store** (iOS). Covers the **current repo configuration**, pre-flight checks, version bumping, Drift migrations, production builds, signing, and store submission (including **first-time** app setup on each platform).

---

## Current configuration (snapshot)

| Area | Detail |
|------|--------|
| **Framework** | Flutter (`pubspec.yaml` SDK `>=3.10.0 <4.0.0`) |
| **State** | Riverpod (`hooks_riverpod`) |
| **Database** | Drift + encrypted SQLite; **`schemaVersion`** in `lib/core/database/database.dart` (currently **15** — always confirm in file before release) |
| **SQLite native** | `pubspec.yaml` hooks: `sqlite3` with **`source: sqlite3mc`** (SQLCipher-compatible builds via the Flutter build hook) |
| **Firebase** | Initialized in `lib/main.dart` via `Firebase.initializeApp` + `lib/firebase_options.dart`. **Android:** `com.google.gms.google-services` in `android/app/build.gradle.kts`, config `android/app/google-services.json`. **iOS:** `ios/Runner/GoogleService-Info.plist` in the Xcode project. **`firebase.json`** records FlutterFire outputs. |
| **Android application ID** | `com.fearlessinventory.fearless_inventory` (`android/app/build.gradle.kts`) |
| **iOS bundle ID** | `com.fearlessinventory.fearless_inventory` (`ios/Runner.xcodeproj/project.pbxproj` — `PRODUCT_BUNDLE_IDENTIFIER`) |
| **Icons** | `flutter_launcher_icons` in `pubspec.yaml` (`assets/branding/…`) |

### Android release signing (important)

As of this writing, `android/app/build.gradle.kts` sets **`release` to use the debug signing config** so local `--release` runs work. **Google Play production uploads require an upload key** (and typically Play App Signing). Before shipping to Play, add a **release keystore**, create **`android/key.properties`** (not committed to git), and point `buildTypes.release` at a `signingConfigs.release` block. Until that is done, treat Play uploads as **blocked**.

---

## Prerequisites

### Machine & repo

- [ ] Flutter SDK installed; `flutter doctor` shows no blocking issues for Android and iOS (Xcode on macOS for iOS).
- [ ] `flutter pub get` succeeds.
- [ ] Firebase config files present where your Firebase project expects them: `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and generated `lib/firebase_options.dart` (regenerate with `flutterfire configure` if the Firebase project or bundle IDs change).

### Android (Play Store)

- [ ] **Google Play Console** access (one-time **$25** registration for a developer account).
- [ ] **Upload keystore** created and backed up securely; **`key.properties`** configured (after you add release signing to Gradle).
- [ ] **Play App Signing** understood: Play can hold the app signing key; you keep an upload key.

### iOS (App Store)

- [ ] **Apple Developer Program** membership (paid).
- [ ] **Bundle ID** in [Apple Developer → Identifiers](https://developer.apple.com/account/resources/identifiers/list) matches **`com.fearlessinventory.fearless_inventory`** (or change the Xcode project and Firebase iOS app to a single consistent ID).
- [ ] **Distribution certificate** + **App Store provisioning profile** (or automatic signing in Xcode with the correct team).
- [ ] If you ship **Google Sign-In**, App Store review typically expects **Sign in with Apple** for the same account features — the app already depends on `sign_in_with_apple`; ensure capability and App Store Connect configuration match.

### Release hygiene

- [ ] Release notes drafted.
- [ ] Main branch clean and merged; `flutter analyze` and `flutter test` green.

---

## Part A — Build procedure (every release)

### A1. Pull latest and verify clean state

```bash
git checkout main
git pull origin main
git status
```

**Expected:** Clean tree on `main`.

### A2. Tests and lint

```bash
flutter pub get
flutter analyze
flutter test
```

**Expected:** No analyzer errors; tests pass.

### A3. Database schema changes (if any)

> Skip if no Drift schema changes since last release.

- [ ] Bump `schemaVersion` in `lib/core/database/database.dart`.
- [ ] Add the matching `MigrationStrategy` step.
- [ ] Regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### A4. Bump version in `pubspec.yaml`

```yaml
# version_name+build_number — build number must increase for each store upload
version: X.Y.Z+N
```

- **Play:** `versionCode` comes from **`+N`** (Flutter `versionCode`).
- **App Store:** **`+N`** is the build number; **`X.Y.Z`** is the marketing version.

### A5. Commit and tag (optional but recommended)

```bash
git add pubspec.yaml lib/core/database/database.dart lib/core/database/database.g.dart
git commit -m "chore: bump version to X.Y.Z+N"
git tag vX.Y.Z
git push origin main --tags
```

### A6. Android — production app bundle

**After release signing is configured:**

```bash
flutter build appbundle --release
```

**Artifact:** `build/app/outputs/bundle/release/app-release.aab`

### A7. iOS — production IPA

From macOS:

```bash
cd ios && pod install && cd ..
flutter build ipa --release
```

**Artifact:** under `build/ios/ipa/` (e.g. `fearless_inventory.ipa` — exact name follows the Xcode product).

**Alternative:** Open `ios/Runner.xcworkspace` in Xcode → **Product → Archive** → **Distribute App** → App Store Connect.

---

## Part B — Google Play Store (step by step)

### B0. One-time: Play Console app creation

1. Go to [Google Play Console](https://play.google.com/console) and sign in with your developer account.
2. **Create app** → enter default language, app name (**Fearless Inventory**), app type (app/game), free/paid.
3. Complete the initial **Dashboard** tasks: **App access**, **Ads declaration**, **Content rating questionnaire**, **Target audience**, **News apps** (if applicable), **COVID-19** contact declaration (if applicable), **Data safety** form (Firebase/Auth, analytics, device IDs, etc. — answer truthfully from your actual SDK use).
4. **Store listing:** short/full description, screenshots (phone required; tablet/TV if you claim those form factors), feature graphic, icon.
5. **Privacy policy URL** — required if you collect personal or sensitive data (email auth, crash data, etc. counts for many apps).

### B1. One-time: Upload key and Play App Signing

1. In Play Console: **Setup → App integrity** (or **Release → Setup → App signing**).
2. If prompted, enroll in **Play App Signing**.
3. Create an **upload keystore** locally (if you have not):

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

4. Add **`android/key.properties`** (do not commit):

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<absolute-or-relative-path-to-upload-keystore.jks>
```

5. Update **`android/app/build.gradle.kts`**: define `signingConfigs.release` from `key.properties` and set `buildTypes.release.signingConfig` to that release config (remove reliance on debug for release builds intended for Play).

6. Rebuild the AAB (**A6**).

### B2. Internal / closed testing (strongly recommended before production)

1. Play Console → **Testing** → **Internal testing** (or Closed testing).
2. Create a release → upload **`app-release.aab`** → add release notes → save → **Review release** → roll out.
3. Add tester emails or use a **temporary internal test link**; install from Play and smoke-test (auth, lock, notifications, meeting finder, etc.).

### B3. Production release

1. Play Console → **Production** → **Create new release**.
2. Upload the **same or newer** AAB (version code must be **greater** than any previous upload).
3. Enter **release notes** per locale.
4. **Review release** → resolve any policy or **Data safety** warnings → **Start rollout to Production**.

### B4. After submission

- Status moves to **In review**, then **Available** (timing varies).
- Monitor **Policy status** and **User feedback** in Console.

---

## Part C — Apple App Store (step by step)

### C0. One-time: Identifiers and capabilities

1. [Apple Developer](https://developer.apple.com/account) → **Certificates, Identifiers & Profiles** → **Identifiers**.
2. Register an **App ID** matching **`com.fearlessinventory.fearless_inventory`** (or your chosen bundle ID if you change Xcode).
3. Enable required **capabilities** (e.g. **Sign In with Apple**, **Push Notifications** if you use APNs with Firebase, **Associated Domains** if needed for OAuth redirects — match what Xcode **Signing & Capabilities** shows).

### C1. One-time: App Store Connect app record

1. Open [App Store Connect](https://appstoreconnect.apple.com/) → **My Apps** → **+** → **New App**.
2. Set **platforms** (iOS), **name**, **primary language**, **bundle ID** (select the App ID above), **SKU** (internal string), **user access** (full/limited).
3. Fill **App Privacy** (data collection types — align with Firebase/Auth and any analytics).
4. Add **screenshots** and metadata (subtitle, description, keywords, support URL, marketing URL optional).
5. **App Review information:** contact, demo account if login is required (Firebase email user or test path).

### C2. Version record

1. In the app → **App Store** tab → **+ Version** (e.g. `1.0.0`).
2. Enter **What’s New** text.
3. Later you will attach the **build** here after upload.

### C3. Upload build

**Option A — Flutter:**

```bash
flutter build ipa --release
```

Then use **Transporter** (Mac App) or **Xcode Organizer** to upload the `.ipa`, or follow the CLI output for recommended upload steps.

**Option B — Xcode:**

1. Open **`ios/Runner.xcworkspace`**.
2. Select **Any iOS Device (arm64)** → **Product → Archive**.
3. **Organizer → Distribute App → App Store Connect → Upload**.

Wait until App Store Connect shows the build **Processing**, then **Ready to Submit**.

### C4. Encryption / export compliance

- In App Store Connect, when you select the build, answer **export compliance** (encryption).
- For standard TLS and OS-provided crypto (typical Flutter/Firebase apps), you usually qualify for **exempt** / **standard encryption** per Apple’s questionnaire — answer based on your actual use (on-device SQLCipher-style encryption may require careful reading of the questions; when in doubt, use Apple’s documentation for the current year).

### C5. Submit for review

1. Attach the processed **build** to the version.
2. Complete any remaining **required** fields (screenshots per size class, age rating, etc.).
3. **Add for Review** → **Submit to App Review**.

### C6. After submission

- **Waiting for Review** → **In Review** → **Pending Developer Release** or **Ready for Sale** (depending on release timing).
- If **Rejected**, read Resolution Center notes, fix, bump **build number** (`+N`), upload a new build, and resubmit.

---

## Verification checklist

- [ ] **Play:** Production (or test track) shows the new **version code** and correct **version name**.
- [ ] **App Store Connect:** Build attached to the version; status appropriate for your release strategy.
- [ ] **Git:** Tag `vX.Y.Z` on remote if you use tags.
- [ ] **`pubspec.yaml`** version matches what you submitted.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|--------|----------------|-----|
| `flutter analyze` errors | Lint or type issues | Fix; try `dart fix --apply` for safe auto-fixes |
| `build_runner` conflicts | Stale `*.g.dart` | `dart run build_runner build --delete-conflicting-outputs` |
| Play: upload rejected | Wrong signing or lower `versionCode` | Use upload key; bump `+N` |
| Play: missing **Data safety** | Form incomplete | Complete Data safety; match declared data to SDK behavior |
| iOS: **No signing identity** | Cert/profile missing | Xcode → Settings → Accounts; download profiles; enable **Automatically manage signing** or install distribution profile |
| iOS: Firebase / OAuth mismatch | Bundle ID ≠ Firebase iOS app | `flutterfire configure` or add iOS app with correct bundle ID in Firebase console |
| iOS: **Missing compliance** | Encryption questions unanswered | Complete export compliance in App Store Connect |

---

## Rollback

**Google Play:** **Halt rollout** on the bad release; prepare a **previous good AAB** (or hotfix) with a **new higher version code** and publish.

**App Store:** Submit a fixed build with a **new build number**; use **Expedited Review** only for critical issues per Apple’s rules.

---

## Escalation

| Situation | Resource |
|-----------|----------|
| Apple review / policy | [Apple Developer Contact](https://developer.apple.com/contact/) |
| Play policy / appeal | Play Console policy messages and appeal flow |
| Lost upload keystore | Play Console **App integrity** — follow **reset upload key** flow (requires account access) |

---

## History

| Date | Notes |
|------|--------|
| 2026-03-26 | Initial runbook |
| 2026-04-12 | Aligned with Firebase + Google services plugin, sqlite3mc hook, Android/iOS IDs, schema/migration pointers, Android signing reality check, expanded first-time Play/App Store steps |
