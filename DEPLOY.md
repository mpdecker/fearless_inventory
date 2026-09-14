# fearless_inventory â€” deployment

_Last updated: 2026-07-01 (Phase 2 readiness pass)_

## Stack

flutter project under `C:\Development\fearless_inventory`

## Prerequisites

- CI workflow: `.github/workflows/ci.yml` (if present)
- Copy `.env.example` â†’ `.env.local` / host secrets

## Environment

_See .env.example (comments only)._ 

## Local dev

```bash
cd C:\Development\fearless_inventory
npm ci
# no dev script â€” see README
```

## Build & test

```bash
# no test script
# no build script
```

## Host

Flutter release build + store submission (see docs/LAUNCH_CHECKLIST.md if present)

## Smoke check

- [ ] Local dev server starts without env errors
- [ ] Test command exits 0 (or documented skip reason in READINESS.md)
- [ ] Production URL / store build succeeds

## Rollback

Redeploy the previous host build (Vercel promotion rollback, EAS prior build, or Docker image tag).

## Web build (Cloudflare + Firebase)

The web build is deployed to Cloudflare Workers static assets and talks to
Firebase (Auth + Storage) for the optional cloud backup/restore feature.

```bash
flutter build web --release --pwa-strategy=none
npx wrangler deploy
```

Firebase Storage security rules (`storage.rules`) and the CORS policy
(`cors.json`) are separate from the Wrangler deploy above and must be
applied to the Firebase project directly — neither is picked up
automatically by `wrangler deploy` or by editing the files in this repo:

```bash
npx firebase-tools deploy --only storage --project fearless-inventory
gcloud storage buckets update gs://fearless-inventory.firebasestorage.app --cors-file=cors.json
```

**Why CORS matters:** without it, the browser's `getData()` call used by
*restore* fails with a CORS error that the app cannot distinguish from
"wrong passphrase" — backup (upload) and the "does a backup exist" check
use different Storage sub-resources and keep working even when restore is
completely broken by a missing/wrong CORS policy. If restore starts
failing for everyone after a bucket change, check this first.

If `gcloud` isn't installed, the same policy can be applied via the GCS
JSON API (`PATCH https://storage.googleapis.com/storage/v1/b/<bucket>`
with `{"cors": [...]}` from `cors.json`) using any OAuth token with
`storage.buckets.update` on the project — for example the token already
held by an authenticated `firebase-tools` CLI session
(`~/.config/configstore/firebase-tools.json`).
