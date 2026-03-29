# Runbook: Fearless Inventory — Release Deployment

**Owner:** Solo developer | **Frequency:** Per release (as needed)
**Last Updated:** 2026-03-26 | **Current Version:** 1.0.0+1

---

## Purpose

Step-by-step procedure for building and releasing a new version of **Fearless Inventory** to the Google Play Store (Android) and Apple App Store (iOS). Covers pre-flight checks, version bumping, optional schema migrations, build, signing, and submission.

---

## Prerequisites

- [ ] Flutter SDK installed and `flutter doctor` reports no critical issues
- [ ] Android: keystore file accessible and `key.properties` configured in `android/`
- [ ] iOS: valid provisioning profile and code signing certificate in Xcode
- [ ] Google Play Console access (app signing enabled)
- [ ] App Store Connect access + Apple Developer account active
- [ ] `CHANGELOG` or release notes drafted for this version
- [ ] All feature branches merged to `main`; CI passing

---

## Procedure

### Step 1: Pull Latest and Verify Clean State

```bash
git checkout main
git pull origin main
git status
```

**Expected result:** Working tree clean, on `main`, up to date with remote.
**If it fails:** Stash or commit any local changes before proceeding.

---

### Step 2: Run Tests and Lint

```bash
flutter pub get
flutter analyze
flutter test
```

**Expected result:** Zero lint errors, all tests pass.
**If it fails:** Fix failures before continuing. Do not ship a broken build.

---

### Step 3: Handle Database Schema Changes (if applicable)

> Skip this step if no table changes were made since the last release.

- [ ] Bump `schemaVersion` in `lib/core/database/database.dart` (e.g., 9 → 10)
- [ ] Add a corresponding `MigrationStrategy` step in the same file
- [ ] Regenerate Drift code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Expected result:** `database.g.dart` regenerated without errors.
**If it fails:** Check for conflicting generated files and re-run with `--delete-conflicting-outputs`.

---

### Step 4: Bump Version in `pubspec.yaml`

```yaml
# Format: version_name+version_code
# Example: 1.1.0+2
version: X.Y.Z+N
```

- **Version name** (`X.Y.Z`): Follow semver — patch for fixes, minor for features, major for breaking changes.
- **Version code** (`N`): Must be strictly incremented from the previous release on both stores.

**Expected result:** `pubspec.yaml` saved with the new version string.
**If it fails:** N/A — manual edit.

---

### Step 5: Commit the Version Bump

```bash
git add pubspec.yaml lib/core/database/database.dart lib/core/database/database.g.dart
git commit -m "chore: bump version to X.Y.Z+N"
git tag vX.Y.Z
git push origin main --tags
```

**Expected result:** Commit and tag pushed to remote.
**If it fails:** Resolve any push rejections; ensure no one has pushed to `main` in the interim.

---

### Step 6: Build Android App Bundle (Production)

```bash
flutter build appbundle --release
```

**Expected result:** Release AAB generated at `build/app/outputs/bundle/release/app-release.aab`.
**If it fails:** Check that `android/key.properties` exists and references a valid keystore. Confirm `android/app/build.gradle.kts` reads `key.properties` for signing config.

---

### Step 7: Build iOS Archive (Production)

```bash
flutter build ipa --release
```

**Expected result:** IPA generated at `build/ios/ipa/fearless_inventory.ipa`.
**If it fails:** Open `ios/Runner.xcworkspace` in Xcode, check signing & capabilities tab. Confirm provisioning profile matches bundle ID and is not expired.

---

### Step 8: Submit to Google Play Console

1. Navigate to Google Play Console → **Fearless Inventory** → **Production** → **Create new release**
2. Upload `app-release.aab`
3. Paste release notes (all supported languages)
4. Click **Review release** → confirm no warnings → **Start rollout to Production**

**Expected result:** Release moves to "In review" status (typically approved within a few hours to 1 day).
**If it fails:** Address any policy violations or metadata issues flagged in the console.

---

### Step 9: Submit to App Store Connect

1. Navigate to App Store Connect → **Fearless Inventory** → **+ Version or Platform**
2. Upload IPA via **Xcode → Organizer → Distribute App** or `xcrun altool`
3. Fill in "What's New" release notes
4. Select the uploaded build, confirm export compliance (encryption: Yes, exempt — standard HTTPS)
5. Click **Submit for Review**

**Expected result:** Build enters "Waiting for Review" state (typically 1–3 days).
**If it fails:** Check TestFlight processing status; re-upload if the build failed processing.

---

## Verification

- [ ] Google Play: build visible in Production track with correct version code
- [ ] App Store Connect: build status shows "Waiting for Review" or "Ready for Sale"
- [ ] Git tag `vX.Y.Z` exists on remote (`git tag --list` or check GitHub/GitLab)
- [ ] `pubspec.yaml` version matches both store submissions

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| `flutter analyze` reports errors | Uncommitted or unresolved code issues | Fix lint errors; run `dart fix --apply` for auto-fixable issues |
| `build_runner` fails with conflicts | Stale generated files | Re-run with `--delete-conflicting-outputs` |
| Android signing error | `key.properties` missing or path wrong | Verify file path and keystore password; never commit `key.properties` to git |
| iOS build fails — "No provisioning profile" | Cert expired or wrong bundle ID | Refresh profile in Apple Developer portal; re-download in Xcode |
| Play Console rejects AAB — version code conflict | Version code not incremented | Bump `+N` in `pubspec.yaml` and rebuild |
| App Store rejects — encryption question | Export compliance not answered | Select "Yes, exempt" for standard HTTPS (no custom encryption) |
| `flutter build ipa` — "No valid code signing identities" | Keychain locked or cert missing | Run `security unlock-keychain` or re-import certificate |

---

## Rollback

App stores do not support instant rollbacks, but you can mitigate a bad release:

**Google Play:** Use the **Halt rollout** button immediately in Play Console → Production → Release summary. Then publish the previous AAB as a new release with a higher version code.

**App Store:** Submit an expedited review request via App Store Connect if a critical bug slips through. Prepare a hotfix branch off the release tag: `git checkout -b hotfix/X.Y.Z+N vX.Y.Z`.

---

## Escalation

| Situation | Contact | Method |
|---|---|---|
| Apple review rejection (policy issue) | Apple Developer Support | https://developer.apple.com/contact/ |
| Google Play suspension | Google Play policy team | Reply to policy email in Play Console |
| Keystore lost or compromised | (self) | Initiate Play App Signing key reset — see Play Console > Setup > App Integrity |

---

## History

| Date | Version | Notes |
|---|---|---|
| 2026-03-26 | 1.0.0+1 | Runbook created; initial release procedure documented |
