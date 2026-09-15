# Web cloud backup/restore — design

Status: approved, not yet implemented
Date: 2026-09-13

## Problem

Signing in with a Firebase account currently buys the user nothing beyond
identity: `AccountScreen` is explicit that "recovery content is not uploaded
to our servers," and there is no mechanism anywhere in the codebase that
moves a user's recovery data (inventories, step work, journal, meetings,
etc.) between devices. For a returning user who switches from one browser/
computer to another, or reinstalls, their local data simply isn't there —
signing in again does not bring it back. That defeats the practical purpose
of having an account beyond the PIN/passphrase lock.

## Scope

**Web only**, for this spec. Native (iOS/Android) uses a fundamentally
different encryption scheme — a random per-device key generated once and
stored in the OS Keychain/Keystore (`lib/core/services/key_service.dart`),
never derived from anything the user knows. That key cannot decrypt data on
a different device, so native sync requires migrating existing users onto a
passphrase-derived key first: a separate, higher-risk crypto migration that
needs its own spec and, ideally, a real device to verify against. Explicitly
out of scope here.

Also explicitly out of scope for v1: real-time/simultaneous multi-device
sync. The confirmed usage pattern is "one device at a time, switching
occasionally" (e.g. new phone, or occasionally opening the web app on a
laptop) — not two devices being edited concurrently in the same sitting.
This is a backup/restore model, not a live-sync model.

## Why this is tractable on web

`lib/core/database/connection/connection_web.dart` already encrypts the
entire local SQLite file with a passphrase-derived key before persisting it
to IndexedDB: PBKDF2 (210k iterations, SHA-256) over a user-chosen
passphrase + a random salt, then AES-256-GCM. The result — salt, IV, and
ciphertext — is a small, self-contained, portable envelope. Any web session
that knows the same passphrase can decrypt it, on any device. All this
design does is give that existing envelope somewhere to go, plus a
reconciliation flow to decide which copy wins when local and cloud
disagree.

The passphrase is chosen locally (`WebPassphraseScreen`) and is **not**
tied to the Firebase account — nothing about it changes. A user syncing to
a second device for the first time must set that device's local passphrase
to the same value used elsewhere for the cloud envelope to decrypt; if it
doesn't, that's handled explicitly (see Error handling), never silently.

## Architecture

### Storage layout

One object per account in Firebase Storage: `users/{uid}/db_backup.enc`.
No history/versioning in v1 — each backup replaces the previous one.

The binary format is the existing local envelope, concatenated:

```
[1 byte version = 0x01][16 bytes salt][12 bytes IV][ciphertext...]
```

Storage's own object metadata (`updated` timestamp, an RFC 3339 string) is
the authoritative "when was this backup made" — no separate Firestore
document is needed for v1.

### Security rules

New `storage.rules`:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{uid}/db_backup.enc {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

`firebase.json` gets a `"storage": {"rules": "storage.rules"}` section
alongside the existing `flutter` config.

**Deployment dependency**: this session doesn't yet know whether it has
Firebase CLI auth for the `fearless-inventory` project (`npx firebase-tools`
itself works, v15.30.0, confirmed). Until `storage.rules` is deployed,
Storage denies all access by default, so the feature is inert regardless of
app code correctness. This is called out again in the implementation plan
as a blocking step to check/resolve before live verification.

### Local sync marker

Per `(device, uid)`, stored via the existing `appSecureStorage`
(`FlutterSecureStorage`, already used for onboarding/guest-mode flags — no
new dependency):

```
key:   fearless_cloud_sync_marker_v1_{uid}
value: "{backedUpAtIso}|{lastSeenCloudUpdatedIso}"
```

`backedUpAtIso` — when this device last successfully uploaded.
`lastSeenCloudUpdatedIso` — the cloud object's `updated` value this device
last observed (from its own upload, or from a completed restore/reconcile).

### Components

**`CloudBackupService`** (new, `lib/core/services/cloud_backup_service.dart`)

- `Future<DateTime?> remoteBackupUpdatedAt()` — `getMetadata()` on the
  Storage object; `null` if it doesn't exist.
- `Future<void> backup(Uint8List envelope)` — uploads, then updates the
  local marker with the new `updated` timestamp from the upload result.
- `Future<Uint8List> restore()` — downloads the raw object bytes.
- Envelope encode/decode helpers (version byte + salt + iv + ciphertext ↔
  parts), reusing the same PBKDF2/AES-GCM primitives already in
  `connection_web.dart` (extracted or duplicated locally — see plan).
- Local marker read/write via `appSecureStorage`.

This service only handles bytes in and out of Storage plus the local
marker. It does not know about Riverpod, dialogs, or the database
connection — those are wired in by the sync coordinator below.

**Sync coordinator** (new provider/notifier, e.g.
`lib/core/providers/cloud_sync_provider.dart`)

State machine per `(device, uid)`:

- **never-synced** — no local marker for this uid yet.
  - No remote object → nothing to reconcile; write an initial backup now,
    transition to **synced**.
  - Remote object exists → transition to **needs-reconciliation**.
- **needs-reconciliation** — show the reconciliation dialog (see below).
  Resolves to **synced** either way (see Error handling for the
  wrong-passphrase sub-case).
- **synced** — steady state. On each debounced local write, if the local
  marker's `backedUpAtIso` is behind the write, back up. Re-checked at
  sign-in and whenever the Account screen is opened while signed in (web
  has no meaningful background/foreground lifecycle the way native does, so
  these two points stand in for "app resume"): if `remoteBackupUpdatedAt()`
  is newer than the local marker's `lastSeenCloudUpdatedIso`, another
  device has backed up since — transition back to
  **needs-reconciliation**.

Listens to `firebaseUserProvider`: on a null→non-null transition, run the
never-synced/needs-reconciliation check described above.

**Debounced backup trigger**

`_PersistingInterceptor` in `connection_web.dart` already runs after every
committed write (autocommit statement or transaction commit) — this is the
single existing choke point for "the local DB just changed." Add a
debounced (~30s idle) callback from there into the sync coordinator's
"local write happened" signal, rather than duplicating write-tracking
elsewhere. The coordinator only acts on it while in the **synced** state
(never auto-uploads over an unresolved **needs-reconciliation**).

**Reconciliation dialog** (new widget, styled like the existing
`AlertDialog`s in `account_screen.dart`)

Shows both timestamps in human-readable form: "Cloud backup from [date] ·
This device's data from [date]". Two actions:

- **Use cloud backup** — attempt `restore()` + decrypt with the current
  local passphrase-derived key. On success, replace the local database file
  with the decrypted plaintext (mirrors the existing "wrong passphrase"
  decrypt-failure branch in `connection_web.dart`'s `openConnection`, but
  targeted at this envelope instead of the boot-time one), update the local
  marker, transition to **synced**. On decrypt failure, see Error handling.
- **Keep this device's data** — transition straight to **synced** with the
  local marker set to "now" for both fields, which means the *next*
  debounced write immediately overwrites the cloud object with this
  device's data.

If the dialog is dismissed without a choice (e.g. tapped outside it), the
state stays **needs-reconciliation** — no default is applied — and it
reappears at the next re-check point (sign-in, or opening the Account
screen) rather than being lost.

**Account screen**

Add a status line under the existing sign-in-methods section, signed-in
view only: "Last backed up: [relative time]" (or "Not backed up yet" /
"Backup pending" while never-synced). Read-only in v1 — no manual
"sync now" button, since the debounced auto-backup already covers the
target usage pattern and a manual trigger adds a second code path to keep
correct for little benefit.

## Error handling

- **Wrong passphrase on restore**: `restore()`'s decrypt throws (AES-GCM
  tag mismatch) — the existing, already-relied-upon signal for "wrong
  passphrase" elsewhere in this codebase. The reconciliation dialog then
  offers a passphrase field scoped to *this restore attempt only* (does not
  touch the device's local unlock passphrase). If the user provides a
  passphrase that decrypts successfully, proceed as a normal restore. If
  they cancel/give up, resolve as "keep this device's data" — explicit,
  informed data loss the user chose, not a silent overwrite. Auto-backup
  only resumes after this resolution, so an unreconciled remote backup is
  never clobbered by a background upload while the state is unresolved.
- **Offline / upload failure**: swallow and let the next debounced write
  retry; no user-facing error for a transient failure, matching how other
  background persistence in this app already behaves (e.g.
  `_PersistingInterceptor` itself has no user-visible failure path).
- **Storage rules not deployed yet**: uploads/downloads fail with a
  permission error. Treated the same as "offline" from the user's
  perspective (silent retry) — this is a deployment gap to close before
  shipping, not a runtime error state the user needs to see.

## Testing

- Unit tests for `CloudBackupService`: envelope encode/decode round-trip,
  marker comparison/state-transition logic — against a fake/in-memory
  Storage client, no real Firebase needed.
- Unit tests for the sync coordinator's state machine (never-synced →
  needs-reconciliation → synced → back to needs-reconciliation on a newer
  remote timestamp), with `CloudBackupService` mocked.
- Live verification in the browser against the real `fearless-inventory`
  Firebase project once `storage.rules` is deployed: back up on device A
  (a real browser profile), simulate device B (a second browser profile /
  incognito context with the same account + passphrase), confirm restore
  produces A's data, confirm the reconciliation dialog appears when
  expected and not otherwise, confirm a wrong-passphrase restore attempt
  surfaces the scoped re-entry prompt rather than crashing.

## Explicitly not in this pass

- Native (iOS/Android) sync — separate spec, blocked on a native key-scheme
  migration decision.
- Backup history/versioning (multiple snapshots, point-in-time restore).
- Real-time/simultaneous multi-device sync.
- A manual "sync now" button.
- Conflict resolution finer than whole-database (e.g. per-table or per-row
  merging).
