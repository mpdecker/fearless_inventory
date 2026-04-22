# Store readiness plan

**Goal:** Close all gaps identified in the pre-submission codebase review so Android and iOS builds are technically correct, policy-aligned, and review-friendly.

**How to use this doc:** Work phases in order unless noted. Check boxes as you complete items. Re-run the verification section before each store upload.

---

## Phase 1 — iOS authentication & biometrics (blockers)

**Repo status (2026-04-12):** `Runner.entitlements` includes **Sign in with Apple**; `**NSFaceIDUsageDescription`** is set; `**CFBundleURLTypes**` uses `**$(GOOGLE_REVERSED_CLIENT_ID)**` from `ios/Flutter/AppSecrets.xcconfig`; `**GoogleService-Info.plist**` includes `**CLIENT_ID**` / `**REVERSED_CLIENT_ID**` placeholders that must be replaced with real values from Firebase (see below).


| #   | Gap                                        | Actions                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | Verification                                                                                              |
| --- | ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| 1.1 | **Sign in with Apple** entitlement missing | **Portal (still required):** In [Apple Developer → Identifiers](https://developer.apple.com/account/resources/identifiers/list), enable **Sign In with Apple** for App ID `com.happydestiny.happydestiny`. In Xcode: **Runner** → **Signing & Capabilities** → confirm **Sign In with Apple** appears (entitlements file already has `com.apple.developer.applesignin` / `Default`).                                                                                                                                                                                       | Archive build; entitlements show Apple Sign In. Device: Apple sign-in completes and Firebase user exists. |
| 1.2 | **Face ID** purpose string missing         | **Done:** `NSFaceIDUsageDescription` in `Info.plist`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | Device with Face ID: biometric prompt OK; no missing-usage-string rejection.                              |
| 1.3 | **Google Sign-In iOS** config incomplete   | **Firebase / plist (required):** Create the **iOS OAuth client** (Firebase Console / Google Cloud), then either run `**flutterfire configure`** or re-download `**GoogleService-Info.plist**`. Replace placeholder `**REPLACE_WITH_IOS_CLIENT_ID**` in that plist (or use the downloaded file’s real `CLIENT_ID` / `REVERSED_CLIENT_ID`). Set `**GOOGLE_REVERSED_CLIENT_ID**` in `**ios/Flutter/AppSecrets.xcconfig**` to the **same** value as `**REVERSED_CLIENT_ID`** in the plist (after `flutterfire`, copy from the new plist so URL scheme and plist stay in sync). | Google sign-in on a physical iOS device returns to the app; Firebase session established.                 |


---

## Phase 2 — Android Google Sign-In (blocker)


| #   | Gap                                                | Actions                                                                                                                                                                                                                                                                                                         | Verification                                                                             |
| --- | -------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| 2.1 | `**oauth_client` empty** in `google-services.json` | In Firebase Console → Project settings → Android app `com.fearlessinventory.fearless_inventory`: add **SHA-1** and **SHA-256** for **debug** keystore (local testing) and **release/upload** keystore (Play uploads). Download fresh `**google-services.json`** and replace `android/app/google-services.json`. | `oauth_client` array non-empty in JSON. Release APK/AAB: Google sign-in works on device. |
| 2.2 | **Optional:** `GoogleSignIn` server client ID      | If you see **null `idToken`** on Android, set `GoogleSignIn(serverClientId: '…')` to the **Web client** OAuth client ID from Firebase (per Firebase + `google_sign_in` docs). Only add if testing proves it’s required.                                                                                         | Email/password unaffected; Google path returns valid Firebase credential.                |


---

## Phase 3 — Push entitlements vs actual behavior (blocker / clarity)

**Repo status (2026-04-12):** `**aps-environment`**, `**com.apple.developer.background-modes**`, and `**UIBackgroundModes**` were removed. The app uses **local notifications** only (`flutter_local_notifications`); no FCM/APNs remote push is configured.


| #   | Gap                                                         | Actions                                                                                                                                                                                                            | Verification                                                                     |
| --- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------- |
| 3.1 | `**aps-environment: development`** in `Runner.entitlements` | **Done** for local-only notifications. **If you add FCM later:** Re-enable push capability, configure APNs in Firebase, and use `**aps-environment: production`** for App Store archives (or Debug/Release split). | Archive has no `aps-environment` unless you intentionally add remote push again. |


---

## Phase 4 — Mandatory Firebase account & review UX (strongly recommended)

**Repo status (2026-04-12):** Onboarding page 4 and `**WelcomeAuthScreen`** state that a **free account is required** and that data stays on-device. `**AccountScreen`** handles `**requires-recent-login**` with password re-auth, **Google** / **Apple** re-authentication via `**FirebaseAuthService`**, or a **Sign out** fallback. Template for App Review notes: `**docs/app-review-information-template.md`**.


| #   | Gap                                    | Actions                                                                                                                                      | Verification                                              |
| --- | -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| 4.1 | **Mandatory sign-in** after onboarding | **Done** in copy; tweak tone if needed after UX review.                                                                                      | Wording is clear without feeling like hidden requirement. |
| 4.2 | **App Review demo account**            | Create Firebase test user; fill `**docs/app-review-information-template.md`** and paste into **App Store Connect → App Review Information**. | Cold install works using only review notes.               |
| 4.3 | `**requires-recent-login` on delete**  | **Done:** password prompt + snackbar; OAuth providers get **Continue with Google / Apple**; edge case **Sign out** fallback.                 | Delete after stale session completes or guides user.      |


---

## Phase 5 — Store policy questionnaires (strongly recommended)


| #   | Gap                            | Actions                                                                                                                                                                                                                                                                                                   | Verification                                                                                            |
| --- | ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| 5.1 | **Google Play — Data safety**  | Declare data collected/shared: account info (email, name, IDs via Firebase Auth), **location** (approx/precise for meetings), **contacts** (if Rolodex import reads contacts), **app activity** if any analytics; encryption in transit; optional account deletion support. Match **Privacy policy** URL. | Form submitted; no contradictions with actual SDK use.                                                  |
| 5.2 | **Google Play — Exact alarms** | If you keep `SCHEDULE_EXACT_ALARM`, complete any **exact alarm** / special access declarations Play Console requests; justify against scheduled local notifications.                                                                                                                                      | Console shows compliant declaration; no policy surprises on review.                                     |
| 5.3 | **App Store — App Privacy**    | Mirror the same reality: **Contact Info**, **Location**, **Identifiers** (user ID), etc., as collected or linked to the user. **Encryption** / export compliance answered consistently with Firebase + HTTPS + on-device DB encryption.                                                                   | App Privacy labels match app behavior; no post-upload compliance warnings.                              |
| 5.4 | **Hosted privacy policy**      | Publish a **Privacy policy** (and terms if you use them) at a stable HTTPS URL. Add the URL to **both** store listings.                                                                                                                                                                                   | URL loads; content mentions Firebase Auth, local storage, encryption, location, contacts as applicable. |


---

## Phase 6 — In-app trust & polish (recommended)


| #   | Gap                            | Actions                                                                                                                                     | Verification                                           |
| --- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| 6.1 | **Privacy policy link in app** | In **Settings** (e.g. under Privacy or Account), add a **ListTile** that opens the same privacy URL via `url_launcher` (or in-app WebView). | Tappable from shipped build; works on iOS and Android. |


---

## Phase 7 — Apple privacy manifest & SDK follow-up (after TestFlight)


| #   | Gap                                   | Actions                                                                                                                                                                                                                                                                           | Verification                                                           |
| --- | ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| 7.1 | **Third-party SDK privacy manifests** | Upload a build to **TestFlight**. In Xcode **Organizer** / App Store Connect, note any **Privacy manifest** or **missing API** warnings. Add or merge `**PrivacyInfo.xcprivacy`** on the Runner target only if Apple/tools require **your** declarations beyond what pods supply. | No blocking upload warnings; address any email from App Store Connect. |


---

## Phase 8 — Repository & CI hygiene

**Repo status (2026-04-12):** `**android/.gitignore`** includes `**/.kotlin/**`. `**analysis_options.yaml**` excludes `**packages/flutter_contacts/example_full/****`. `**CLAUDE.md**` documents default `**flutter analyze**` scope. If `**android/.kotlin/sessions/*.salive**` was ever committed, run `**git rm -r --cached android/.kotlin**` once and commit.


| #   | Gap                         | Actions                                                                                  | Verification                             |
| --- | --------------------------- | ---------------------------------------------------------------------------------------- | ---------------------------------------- |
| 8.1 | **Tracked `.salive` file**  | **Done:** ignore `android/.kotlin/`. Remove from index if still tracked (command above). | `git ls-files android/.kotlin` is empty. |
| 8.2 | `**flutter analyze` scope** | **Done:** analyzer `exclude` + **CLAUDE.md** note.                                       | `flutter analyze` exits 0 at repo root.  |


---

## Phase 9 — Final pre-upload verification

Run these on **release** builds (physical devices preferred):

- Email: register → verify email → PIN → home.
- Email: sign in → **change password** → **delete account** (including re-auth path if triggered).
- **Google** sign-in and sign-out on **Android** and **iOS**.
- **Apple** sign-in and sign-out on **iOS**.
- **Face ID / Touch ID** unlock when enabled.
- **Location** permission flow for meetings; **Contacts** permission for Rolodex (if used).
- **Notifications** permission and scheduled reminders still fire after permission grant.
- `**flutter test`** (and your CI analyze command) green.
- `**key.properties**` present on release machine; `**flutter build appbundle**` signed with upload key; `**flutter build ipa**` or Xcode Archive succeeds with **distribution** profile.

---

## Dependency graph (short)

```text
Phase 1 (iOS auth + Face ID)     ─┐
Phase 2 (Android Google JSON)    ─┼─► Phase 9 (device QA)
Phase 3 (APS / background modes) ─┘
Phase 4–6 (review + policy + URL) ───► store submissions
Phase 7 after first TestFlight upload
Phase 8 anytime (parallel)
```

---

## History


| Date       | Notes                                       |
| ---------- | ------------------------------------------- |
| 2026-04-12 | Initial plan from pre-submission gap review |


