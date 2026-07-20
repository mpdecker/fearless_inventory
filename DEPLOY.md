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
