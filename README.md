# Fearless Inventory

A mobile app supporting the **12-step continuous recovery workflow** — working
inventories on an ongoing basis rather than as a one-off exercise, privately and
on your own device.

---

## Status

| | |
| --- | --- |
| Default branch | `master` |
| Remote | `mpdecker/fearless_inventory` (SSH) |
| Stack | Flutter / Dart |
| Platforms | iOS, Android, web |
| Backend | Firebase (`firebase.json`) |
| Tests | Flutter unit tests (`test/`) + `integration_test/` |
| CI | `.github/workflows/ci.yml` |

Bundle id is aligned across platforms as
`com.fearlessinventory.fearless_inventory`. The app includes a donation link.

---

## Layout

```
lib/
  features/   feature modules (the bulk of the app)
  core/       shared foundations
  data/       models and persistence
test/         unit tests mirroring core/data/features
integration_test/
android/  ios/  web/    platform shells
assets/branding/        brand assets
packages/flutter_contacts/   vendored dependency (local fork)
docs/                   launch and release documentation
```

> `packages/flutter_contacts` is a vendored copy of the contacts plugin and
> accounts for most of the repository's file count. It is excluded from analysis
> in `analysis_options.yaml`.

---

## Develop

```bash
flutter pub get
flutter run                 # device or emulator
flutter test                # unit tests
flutter test integration_test
flutter analyze
```

## Release

Store-readiness material lives in `docs/`:

- [`docs/LAUNCH_CHECKLIST.md`](docs/LAUNCH_CHECKLIST.md)
- [`docs/store-readiness-plan.md`](docs/store-readiness-plan.md)
- [`docs/runbook-release.md`](docs/runbook-release.md)
- [`docs/app-review-information-template.md`](docs/app-review-information-template.md)
- [`docs/ios-porting-plan.md`](docs/ios-porting-plan.md)

See also [`DEPLOY.md`](DEPLOY.md), [`READINESS.md`](READINESS.md), and
[`CLAUDE.md`](CLAUDE.md).
