# Web Cloud Backup/Restore Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Signing in to a Firebase account on the web build backs up the encrypted local database to Firebase Storage and can restore it on another device/browser, with explicit user-driven conflict resolution whenever local and cloud data disagree.

**Architecture:** Reuse the existing passphrase-derived AES-256-GCM envelope already used for local IndexedDB persistence (`lib/core/database/connection/connection_web.dart`) as the exact thing that gets uploaded to `users/{uid}/db_backup.enc` in Firebase Storage. A Riverpod `Notifier` tracks a small per-(device, account) state machine (never-synced → needs-reconciliation → synced) driven by sign-in events and a debounced local-write signal; an `AlertDialog` handles reconciliation, never silently overwriting either side.

**Tech Stack:** Flutter/Dart, Riverpod (`Notifier`/`NotifierProvider`, no codegen), `firebase_storage`, `firebase_auth` (existing), `flutter_secure_storage` (existing), `mocktail` for tests.

**Spec:** `docs/superpowers/specs/2026-09-13-web-cloud-backup-design.md` — read it for the *why* behind every decision below; this plan covers the *how*.

## Global Constraints

- **Web-only.** Native (iOS/Android) is explicitly out of scope — do not touch `key_service.dart` or any native-only file.
- **`firebase_storage: ^12.4.10`** — this is the version `flutter pub add firebase_storage` resolves against this project's existing `firebase_core: ^3.1.0` / `firebase_auth: ^5.7.0`. Use it verbatim; do not hand-pick a different version.
- **Files that transitively import `package:web` cannot be part of a plain `flutter test` run** — confirmed empirically (see Task 2's note). Every task below is written to respect the abstract/concrete split this requires: pure logic and abstract interfaces are VM-testable; concrete web implementations are verified live in the browser only (Task 9), matching the existing, already-shipped `connection_web.dart`, which has zero unit tests today for the same reason.
- **Never silently overwrite data.** Every reconciliation path either gets explicit user input or leaves state as `needsReconciliation` — no code path may call `backup()` over an unresolved conflict or `restore` without the user having chosen it.
- Match existing codebase conventions exactly: `mocktail` (not `mockito`) for mocks, `Notifier`/`NotifierProvider` (not `StateNotifier`) for Riverpod state, optional-constructor dependency injection defaulting to the real singleton (see `FirebaseAuthService`), conditional-import trios (`*_stub.dart` / `*_web.dart` / `*_native.dart`) for any platform-specific top-level function.

---

## File Structure

**New files:**

| File | Responsibility | VM-testable? |
|---|---|---|
| `storage.rules` | Firebase Storage security rules | — (deployed, not compiled) |
| `lib/core/database/connection/web_crypto.dart` | PBKDF2 key derivation + AES-GCM encrypt/decrypt (extracted from `connection_web.dart`) | No (`package:web`) |
| `lib/core/database/connection/web_db_envelope.dart` | IndexedDB envelope read/write + `webDatabaseExists()` (extracted from `connection_web.dart`) | No (`package:web`) |
| `lib/core/services/cloud_backup_envelope.dart` | Pure binary envelope encode/decode (version byte + salt + iv + ciphertext) | **Yes** |
| `lib/core/services/cloud_backup_service.dart` | Abstract `CloudBackupService` interface + `CloudSyncMarker` data class | **Yes** |
| `lib/core/services/web_cloud_backup_service.dart` | Concrete `WebCloudBackupService implements CloudBackupService` (Firebase Storage + web crypto + IndexedDB + secure storage) | No (`package:web`) |
| `lib/core/services/cloud_backup_service_factory_stub.dart` / `_web.dart` / `_native.dart` | Conditional-import trio constructing the right `CloudBackupService` for the platform | Stub/native yes, web no |
| `lib/core/services/page_reload_stub.dart` / `_web.dart` / `_native.dart` | Conditional-import trio for `window.location.reload()` after a restore | Stub/native yes, web no |
| `lib/core/providers/cloud_sync_provider.dart` | `CloudSyncState`, `CloudSyncPhase`, `CloudSyncNotifier`, `cloudSyncProvider`, `cloudBackupServiceProvider` | **Yes** (depends only on the abstract interface + the two conditional-import aliases, which resolve to their native/stub variants under `flutter test`) |
| `lib/features/auth/widgets/reconciliation_dialog.dart` | The conflict-resolution `AlertDialog` | **Yes** (widget test) |
| `lib/features/auth/widgets/cloud_sync_gate.dart` | Watches `cloudSyncProvider`, shows the dialog, wraps `HomeScreen` | **Yes** (widget test) |
| `test/core/services/cloud_backup_envelope_test.dart` | Envelope codec round-trip tests | — |
| `test/core/providers/cloud_sync_provider_test.dart` | State-machine tests | — |
| `test/features/auth/widgets/reconciliation_dialog_test.dart` | Dialog widget test | — |
| `test/features/auth/widgets/cloud_sync_gate_test.dart` | Gate widget test | — |

**Modified files:**

| File | Change |
|---|---|
| `pubspec.yaml` | Add `firebase_storage: ^12.4.10` |
| `firebase.json` | Add `"storage": {"rules": "storage.rules"}` |
| `lib/core/database/connection/connection_web.dart` | Remove now-extracted crypto/envelope code; import from the two new files; add `onLocalDbPersisted` hook, call it after every persist; re-export `webDatabaseExists` |
| `lib/core/database/connection/connection_stub.dart` | Add matching `onLocalDbPersisted` no-op declaration |
| `lib/core/database/connection/connection_native.dart` | Add matching `onLocalDbPersisted` no-op declaration |
| `lib/core/navigation/bootstrap_shell.dart` | Wrap the web `HomeScreen()` return with `CloudSyncGate` |
| `lib/features/auth/screens/account_screen.dart` | Add a "Last backed up" status line to the signed-in view |

---

## Task 1: Add `firebase_storage` dependency and Storage security rules

**Files:**
- Modify: `pubspec.yaml`
- Create: `storage.rules`
- Modify: `firebase.json`

**Interfaces:**
- Produces: the `firebase_storage` package available to import as `package:firebase_storage/firebase_storage.dart` from Task 4 onward.

- [ ] **Step 1: Add the dependency**

```bash
cd D:/Development/fearless_inventory
flutter pub add firebase_storage
```

Expected: `pubspec.yaml` gains `firebase_storage: ^12.4.10` under `dependencies`; `pubspec.lock` updates; command exits 0.

- [ ] **Step 2: Verify it resolves cleanly**

```bash
flutter analyze --no-fatal-infos
```

Expected: no new errors/warnings beyond the pre-existing `info`-level lints already in this codebase (see `CLAUDE.md`/CI config — infos are non-fatal).

- [ ] **Step 3: Create `storage.rules`**

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

- [ ] **Step 4: Wire the rules file into `firebase.json`**

Current content (single line, minified):

```json
{"flutter":{"platforms":{"android":{"default":{"projectId":"fearless-inventory","appId":"1:510334238921:android:2fc2d88d1cac49b7be0d18","fileOutput":"android/app/google-services.json"}},"ios":{"default":{"projectId":"fearless-inventory","appId":"1:510334238921:ios:a85311d2bef79848be0d18","uploadDebugSymbols":false,"fileOutput":"ios/Runner/GoogleService-Info.plist"}},"dart":{"lib/firebase_options.dart":{"projectId":"fearless-inventory","configurations":{"android":"1:510334238921:android:2fc2d88d1cac49b7be0d18","ios":"1:510334238921:ios:a85311d2bef79848be0d18","web":"1:510334238921:web:dd91d38952066a91be0d18"}}}}}}
```

Replace it with (adds a top-level `"storage"` key, keeps every existing key byte-identical):

```json
{"storage":{"rules":"storage.rules"},"flutter":{"platforms":{"android":{"default":{"projectId":"fearless-inventory","appId":"1:510334238921:android:2fc2d88d1cac49b7be0d18","fileOutput":"android/app/google-services.json"}},"ios":{"default":{"projectId":"fearless-inventory","appId":"1:510334238921:ios:a85311d2bef79848be0d18","uploadDebugSymbols":false,"fileOutput":"ios/Runner/GoogleService-Info.plist"}},"dart":{"lib/firebase_options.dart":{"projectId":"fearless-inventory","configurations":{"android":"1:510334238921:android:2fc2d88d1cac49b7be0d18","ios":"1:510334238921:ios:a85311d2bef79848be0d18","web":"1:510334238921:web:dd91d38952066a91be0d18"}}}}}}
```

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock storage.rules firebase.json
git commit -m "feat: add firebase_storage dependency and Storage security rules"
```

---

## Task 2: Extract shared web crypto and IndexedDB envelope helpers

**Files:**
- Create: `lib/core/database/connection/web_crypto.dart`
- Create: `lib/core/database/connection/web_db_envelope.dart`
- Modify: `lib/core/database/connection/connection_web.dart`
- Modify: `lib/core/database/connection/connection_stub.dart`
- Modify: `lib/core/database/connection/connection_native.dart`

**Interfaces:**
- Produces (from `web_crypto.dart`): `Future<web.CryptoKey> deriveAesKey(String passphrase, Uint8List salt)`, `Future<Uint8List> encryptBytes(web.CryptoKey key, Uint8List iv, Uint8List plaintext)`, `Future<Uint8List> decryptBytes(web.CryptoKey key, Uint8List iv, Uint8List ciphertext)`, `Uint8List randomBytes(int length)`, `const int ivLength = 12`, `const int saltLength = 16`.
- Produces (from `web_db_envelope.dart`): `class DbEnvelope { final Uint8List salt, iv, ciphertext; }`, `Future<DbEnvelope?> loadDbEnvelope()`, `Future<void> saveDbEnvelope(Uint8List salt, Uint8List iv, Uint8List ciphertext)`, `Future<bool> webDatabaseExists()`.
- Produces (from `connection_web.dart`, `connection_stub.dart`, `connection_native.dart` — all three, matching signatures): `void Function()? onLocalDbPersisted` (a settable top-level hook; native/stub never call it, web calls it after every successful local persist).

**Empirically confirmed constraint** (do not skip re-verifying this if anything about the extraction changes): a file that imports `package:web` — even transitively — fails to *compile* under plain `flutter test` (VM target), not just fails at runtime. This was proven directly in this session:

```
import 'package:web/web.dart' as web;
```
alone, in an otherwise-trivial file, produces `Error: The getter 'toJS' isn't defined...` etc. under `flutter test`. This is why `web_crypto.dart` and `web_db_envelope.dart` are never imported by any test file directly — only by `connection_web.dart` and (starting in Task 4) `web_cloud_backup_service.dart`, both of which are themselves never imported by tests.

- [ ] **Step 1: Create `lib/core/database/connection/web_crypto.dart`**

```dart
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// PBKDF2 → AES-256-GCM primitives shared by the web database connection
/// (`connection_web.dart`) and cloud backup (`web_cloud_backup_service.dart`).
/// Extracted so both can encrypt/decrypt against the same passphrase-derived
/// key without duplicating this logic.
const int saltLength = 16;
const int ivLength = 12;
const int _pbkdf2Iterations = 210000;

web.Crypto get _crypto => web.window.crypto;

Uint8List randomBytes(int length) {
  final bytes = Uint8List(length);
  _crypto.getRandomValues(bytes.toJS);
  return bytes;
}

JSObject _pbkdf2Params(Uint8List salt) => JSObject()
  ..['name'] = 'PBKDF2'.toJS
  ..['salt'] = salt.toJS
  ..['iterations'] = _pbkdf2Iterations.toJS
  ..['hash'] = 'SHA-256'.toJS;

JSObject _aesKeyGenParams() => JSObject()
  ..['name'] = 'AES-GCM'.toJS
  ..['length'] = 256.toJS;

JSObject _aesGcmParams(Uint8List iv) => JSObject()
  ..['name'] = 'AES-GCM'.toJS
  ..['iv'] = iv.toJS;

Future<web.CryptoKey> deriveAesKey(String passphrase, Uint8List salt) async {
  final baseKey = await _crypto.subtle.importKey(
    'raw',
    Uint8List.fromList(utf8.encode(passphrase)).toJS,
    'PBKDF2'.toJS,
    false,
    <JSString>['deriveKey'.toJS].toJS,
  ).toDart;

  final derived = await _crypto.subtle.deriveKey(
    _pbkdf2Params(salt),
    baseKey,
    _aesKeyGenParams(),
    false,
    <JSString>['encrypt'.toJS, 'decrypt'.toJS].toJS,
  ).toDart;

  return derived as web.CryptoKey;
}

Future<Uint8List> encryptBytes(web.CryptoKey key, Uint8List iv, Uint8List plaintext) async {
  final result = await _crypto.subtle.encrypt(
    _aesGcmParams(iv),
    key,
    plaintext.toJS,
  ).toDart;
  return (result as JSArrayBuffer).toDart.asUint8List();
}

/// Throws (AES-GCM tag verification failure) if [key] is derived from the
/// wrong passphrase — that failure *is* the "incorrect passphrase" signal,
/// relied on by both `WebPassphraseScreen` and the cloud-restore flow.
Future<Uint8List> decryptBytes(web.CryptoKey key, Uint8List iv, Uint8List ciphertext) async {
  final result = await _crypto.subtle.decrypt(
    _aesGcmParams(iv),
    key,
    ciphertext.toJS,
  ).toDart;
  return (result as JSArrayBuffer).toDart.asUint8List();
}
```

- [ ] **Step 2: Create `lib/core/database/connection/web_db_envelope.dart`**

```dart
import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// The encrypted local database, as three parts, persisted in IndexedDB.
/// Extracted from `connection_web.dart` so `web_cloud_backup_service.dart`
/// can read/write the same envelope without duplicating the IndexedDB code.
const _idbName = 'fearless_inventory_web_kv';
const _idbStoreName = 'encrypted_db';
const _idbEnvelopeKey = 'db_envelope_v1';

class DbEnvelope {
  final Uint8List salt;
  final Uint8List iv;
  final Uint8List ciphertext;
  DbEnvelope({required this.salt, required this.iv, required this.ciphertext});
}

Future<web.IDBDatabase> _openIdb() {
  final completer = Completer<web.IDBDatabase>();
  final request = web.window.indexedDB.open(_idbName, 1);
  request.onupgradeneeded = ((web.Event _) {
    (request.result as web.IDBDatabase).createObjectStore(_idbStoreName);
  }).toJS;
  request.onsuccess = ((web.Event _) {
    completer.complete(request.result as web.IDBDatabase);
  }).toJS;
  request.onerror = ((web.Event _) {
    completer.completeError(
      request.error ?? StateError('IndexedDB open failed'),
    );
  }).toJS;
  return completer.future;
}

Future<DbEnvelope?> loadDbEnvelope() async {
  final db = await _openIdb();
  final completer = Completer<DbEnvelope?>();
  final store = db.transaction(_idbStoreName.toJS, 'readonly').objectStore(_idbStoreName);
  final request = store.get(_idbEnvelopeKey.toJS);
  request.onsuccess = ((web.Event _) {
    final result = request.result;
    if (result == null) {
      completer.complete(null);
      return;
    }
    final obj = result as JSObject;
    completer.complete(DbEnvelope(
      salt: (obj['salt'] as JSUint8Array).toDart,
      iv: (obj['iv'] as JSUint8Array).toDart,
      ciphertext: (obj['data'] as JSUint8Array).toDart,
    ));
  }).toJS;
  request.onerror = ((web.Event _) {
    completer.completeError(request.error ?? StateError('IndexedDB read failed'));
  }).toJS;
  final envelope = await completer.future;
  db.close();
  return envelope;
}

Future<void> saveDbEnvelope(Uint8List salt, Uint8List iv, Uint8List ciphertext) async {
  final db = await _openIdb();
  final completer = Completer<void>();
  final tx = db.transaction(_idbStoreName.toJS, 'readwrite');
  final store = tx.objectStore(_idbStoreName);
  final value = JSObject()
    ..['salt'] = salt.toJS
    ..['iv'] = iv.toJS
    ..['data'] = ciphertext.toJS;
  store.put(value, _idbEnvelopeKey.toJS);
  tx.oncomplete = ((web.Event _) => completer.complete()).toJS;
  tx.onerror = ((web.Event _) {
    completer.completeError(tx.error ?? StateError('IndexedDB write failed'));
  }).toJS;
  await completer.future;
  db.close();
}

/// Whether an encrypted database already exists in this browser profile —
/// used by `WebPassphraseScreen` to decide "create a passphrase" vs
/// "enter your passphrase".
Future<bool> webDatabaseExists() async {
  return (await loadDbEnvelope()) != null;
}
```

- [ ] **Step 3: Rewrite `connection_web.dart` to use the extracted files**

Replace the file's full content with:

```dart
import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';
import 'package:typed_data/typed_buffers.dart';

import 'web_crypto.dart';
import 'web_db_envelope.dart';

export 'web_db_envelope.dart' show webDatabaseExists;

// ─────────────────────────────────────────────────────────────────────────
// Web encryption strategy
//
// sqlite3mc's own encryption (used natively — see connection_native.dart)
// turned out to require its database be opened against a VFS that its C
// code specifically recognizes (wraps at module init); a Dart-registered
// custom VFS like InMemoryFileSystem isn't one, so PRAGMA key fails with
// "Encryption is not supported by the VFS." regardless of which VFS API is
// used. Rather than fight sqlite3mc's internals, the web build runs a
// *plain* (unencrypted-by-SQLite) in-memory database, and encrypts the
// raw file bytes ourselves with WebCrypto (PBKDF2 → AES-GCM, in
// `web_crypto.dart`) before every persist to IndexedDB (`web_db_envelope.dart`).
// Same guarantee (data at rest is unreadable without the passphrase),
// simpler and more auditable implementation.
// ─────────────────────────────────────────────────────────────────────────

const _dbPath = '/fearless_inventory.db';

/// Called after every local write is persisted to IndexedDB. Set by
/// `CloudSyncNotifier` (see `lib/core/providers/cloud_sync_provider.dart`)
/// to debounce a cloud backup off real local activity. `null` (the default)
/// means nothing is listening — a normal no-op until cloud sync is wired up.
void Function()? onLocalDbPersisted;

/// Encrypts and persists the in-memory database file to IndexedDB after
/// every write that actually commits — autocommit statements immediately,
/// explicit transactions only once they commit (never mid-transaction, so a
/// persisted snapshot is always a consistent one). A fresh random IV is used
/// for every encryption (required for AES-GCM); the salt stays fixed for
/// the life of this passphrase so key derivation is reproducible.
class _PersistingInterceptor extends QueryInterceptor {
  final InMemoryFileSystem fs;
  final dynamic key; // web.CryptoKey — untyped here to avoid a second import
  final Uint8List salt;
  _PersistingInterceptor(this.fs, this.key, this.salt);

  bool _isAutocommit(QueryExecutor executor) => executor is! TransactionExecutor;

  Future<void> _persist() async {
    final data = fs.fileData[_dbPath];
    if (data == null) return;
    final plaintext = data.buffer.asUint8List(0, data.length);
    final iv = randomBytes(ivLength);
    final ciphertext = await encryptBytes(key, iv, plaintext);
    await saveDbEnvelope(salt, iv, ciphertext);
    onLocalDbPersisted?.call();
  }

  @override
  Future<void> runBatched(
    QueryExecutor executor,
    BatchedStatements statements,
  ) async {
    await super.runBatched(executor, statements);
    if (_isAutocommit(executor)) await _persist();
  }

  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    await super.runCustom(executor, statement, args);
    if (_isAutocommit(executor)) await _persist();
  }

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    final result = await super.runInsert(executor, statement, args);
    if (_isAutocommit(executor)) await _persist();
    return result;
  }

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    final result = await super.runUpdate(executor, statement, args);
    if (_isAutocommit(executor)) await _persist();
    return result;
  }

  @override
  Future<int> runDelete(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    final result = await super.runDelete(executor, statement, args);
    if (_isAutocommit(executor)) await _persist();
    return result;
  }

  @override
  Future<void> commitTransaction(TransactionExecutor inner) async {
    await super.commitTransaction(inner);
    await _persist();
  }
}

QueryExecutor openConnectionAt(String path, String encryptionKey) {
  throw UnsupportedError('openConnectionAt is only supported on native platforms.');
}

QueryExecutor openConnection(String encryptionKey) {
  return LazyDatabase(() async {
    final sqlite3 = await WasmSqlite3.loadFromUrlString('sqlite3mc.wasm');
    final fs = InMemoryFileSystem();
    sqlite3.registerVirtualFileSystem(fs, makeDefault: true);

    final envelope = await loadDbEnvelope();
    final Uint8List salt;
    final dynamic key;

    if (envelope != null) {
      salt = envelope.salt;
      key = await deriveAesKey(encryptionKey, salt);
      // A wrong passphrase makes this throw (AES-GCM tag mismatch) — that
      // propagates out of this LazyDatabase's opening future, which is what
      // WebPassphraseScreen's verification query is waiting to catch.
      final plaintext = await decryptBytes(key, envelope.iv, envelope.ciphertext);
      fs.fileData[_dbPath] = Uint8Buffer()..addAll(plaintext);
    } else {
      salt = randomBytes(saltLength);
      key = await deriveAesKey(encryptionKey, salt);
    }

    final database = sqlite3.open(_dbPath);
    return WasmDatabase.opened(database)
        .interceptWith(_PersistingInterceptor(fs, key, salt));
  });
}
```

Note: `key` and the `_PersistingInterceptor.key` field are typed `dynamic` rather than `web.CryptoKey` here specifically so `connection_web.dart` itself no longer needs `import 'package:web/web.dart'` directly — it only needs the functions `web_crypto.dart` already exports, which internally handle the real `web.CryptoKey` type. This keeps the import list in this file minimal; `web_crypto.dart` is still the one true place `package:web` is imported for crypto.

- [ ] **Step 4: Add the matching hook to `connection_stub.dart`**

Add this line (anywhere at top level, e.g. right after the existing `webDatabaseExists` stub):

```dart
/// Web-only in practice — see connection_web.dart. Declared here too so
/// code that references it (via the conditional import) compiles on every
/// platform; never actually called outside web.
void Function()? onLocalDbPersisted;
```

- [ ] **Step 5: Add the matching hook to `connection_native.dart`**

Add the same declaration (identical doc comment and line) at top level in `connection_native.dart`, near its own `webDatabaseExists` stub.

- [ ] **Step 6: Verify the refactor compiles and analyzes clean**

```bash
flutter analyze --no-fatal-infos
```

Expected: no new errors/warnings.

- [ ] **Step 7: Verify a full web build still succeeds**

```bash
flutter build web --release
```

Expected: `√ Built build\web` (or equivalent success line), no compile errors.

- [ ] **Step 8: Live regression check — passphrase create/unlock still works**

This file has no automated tests (see Global Constraints), and it gates every web user's access to their data, so verify it live before moving on:

```bash
flutter run -d chrome
```

In the launched browser: create a passphrase for a **fresh** profile (use a private/incognito window so this doesn't touch a profile with real data), confirm the app reaches the dashboard, close and reopen the tab, confirm "Enter your passphrase" appears and the same passphrase unlocks it again. If either step fails, the extraction introduced a behavior change — stop and fix before continuing to Task 3.

- [ ] **Step 9: Commit**

```bash
git add lib/core/database/connection/web_crypto.dart lib/core/database/connection/web_db_envelope.dart lib/core/database/connection/connection_web.dart lib/core/database/connection/connection_stub.dart lib/core/database/connection/connection_native.dart
git commit -m "refactor: extract web crypto and IndexedDB envelope helpers for reuse"
```

---

## Task 3: Pure envelope codec and abstract `CloudBackupService` interface

**Files:**
- Create: `lib/core/services/cloud_backup_envelope.dart`
- Create: `lib/core/services/cloud_backup_service.dart`
- Test: `test/core/services/cloud_backup_envelope_test.dart`

**Interfaces:**
- Produces: `Uint8List encodeBackupEnvelope({required Uint8List salt, required Uint8List iv, required Uint8List ciphertext})`, `DecodedBackupEnvelope decodeBackupEnvelope(Uint8List bytes)` where `DecodedBackupEnvelope` has fields `salt`, `iv`, `ciphertext` (all `Uint8List`).
- Produces: `abstract class CloudBackupService` with methods `Future<DateTime?> remoteBackupUpdatedAt(String uid)`, `Future<DateTime> backup(String uid)`, `Future<DateTime> restoreVerifyingPassphrase(String uid, String passphrase)`, `Future<CloudSyncMarker?> readMarker(String uid)`, `Future<void> markResolvedKeepingLocal(String uid, DateTime remoteUpdatedAt)`.
- Produces: `class CloudSyncMarker { final DateTime backedUpAt; final DateTime lastSeenCloudUpdatedAt; }`.
- Consumes: nothing (this is the bottom of the dependency graph for the new feature — pure Dart only).

- [ ] **Step 1: Write the failing envelope codec test**

Create `test/core/services/cloud_backup_envelope_test.dart`:

```dart
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/services/cloud_backup_envelope.dart';

void main() {
  group('encodeBackupEnvelope / decodeBackupEnvelope', () {
    test('round-trips salt, iv, and ciphertext', () {
      final salt = Uint8List.fromList(List.generate(16, (i) => i));
      final iv = Uint8List.fromList(List.generate(12, (i) => i + 100));
      final ciphertext = Uint8List.fromList(List.generate(40, (i) => i + 200));

      final encoded = encodeBackupEnvelope(salt: salt, iv: iv, ciphertext: ciphertext);
      final decoded = decodeBackupEnvelope(encoded);

      expect(decoded.salt, equals(salt));
      expect(decoded.iv, equals(iv));
      expect(decoded.ciphertext, equals(ciphertext));
    });

    test('encoded bytes start with version byte 1', () {
      final encoded = encodeBackupEnvelope(
        salt: Uint8List(16),
        iv: Uint8List(12),
        ciphertext: Uint8List(4),
      );
      expect(encoded[0], 1);
    });

    test('decodeBackupEnvelope throws FormatException on an unsupported version byte', () {
      final bytes = Uint8List.fromList([99, ...List.filled(28, 0)]);
      expect(() => decodeBackupEnvelope(bytes), throwsFormatException);
    });

    test('decodeBackupEnvelope throws FormatException on input too short to contain a header', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      expect(() => decodeBackupEnvelope(bytes), throwsFormatException);
    });

    test('handles an empty ciphertext', () {
      final salt = Uint8List.fromList(List.generate(16, (i) => i));
      final iv = Uint8List.fromList(List.generate(12, (i) => i));
      final encoded = encodeBackupEnvelope(salt: salt, iv: iv, ciphertext: Uint8List(0));
      final decoded = decodeBackupEnvelope(encoded);
      expect(decoded.ciphertext, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails (the source file doesn't exist yet)**

```bash
flutter test test/core/services/cloud_backup_envelope_test.dart
```

Expected: FAIL — `Error: Error when reading 'lib/core/services/cloud_backup_envelope.dart': No such file or directory.`

- [ ] **Step 3: Create `lib/core/services/cloud_backup_envelope.dart`**

```dart
import 'dart:typed_data';

/// Binary format for the object uploaded to Firebase Storage at
/// `users/{uid}/db_backup.enc`: the exact same salt/iv/ciphertext the local
/// IndexedDB envelope already stores (see `web_db_envelope.dart`), just
/// concatenated with a leading version byte so the format can evolve later.
///
/// ```
/// [1 byte version = 0x01][16 bytes salt][12 bytes IV][ciphertext...]
/// ```
const int _currentVersion = 1;
const int _saltLength = 16;
const int _ivLength = 12;
const int _headerLength = 1 + _saltLength + _ivLength;

class DecodedBackupEnvelope {
  final Uint8List salt;
  final Uint8List iv;
  final Uint8List ciphertext;
  const DecodedBackupEnvelope({
    required this.salt,
    required this.iv,
    required this.ciphertext,
  });
}

Uint8List encodeBackupEnvelope({
  required Uint8List salt,
  required Uint8List iv,
  required Uint8List ciphertext,
}) {
  final out = BytesBuilder();
  out.addByte(_currentVersion);
  out.add(salt);
  out.add(iv);
  out.add(ciphertext);
  return out.toBytes();
}

DecodedBackupEnvelope decodeBackupEnvelope(Uint8List bytes) {
  if (bytes.length < _headerLength) {
    throw FormatException(
      'Backup envelope too short: expected at least $_headerLength bytes, got ${bytes.length}',
    );
  }
  if (bytes[0] != _currentVersion) {
    throw FormatException('Unsupported backup envelope version: ${bytes[0]}');
  }
  final salt = bytes.sublist(1, 1 + _saltLength);
  final iv = bytes.sublist(1 + _saltLength, _headerLength);
  final ciphertext = bytes.sublist(_headerLength);
  return DecodedBackupEnvelope(salt: salt, iv: iv, ciphertext: ciphertext);
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
flutter test test/core/services/cloud_backup_envelope_test.dart
```

Expected: `+5: All tests passed!`

- [ ] **Step 5: Create `lib/core/services/cloud_backup_service.dart`**

```dart
/// Where this device last stood relative to the cloud backup for one
/// (device, account) pair — persisted locally via `appSecureStorage`.
class CloudSyncMarker {
  /// When this device last successfully uploaded a backup, or (for the
  /// "keep this device's data" resolution) when that resolution was made.
  final DateTime backedUpAt;

  /// The cloud object's `updated` timestamp this device last observed —
  /// from its own upload, or from a completed restore/reconcile. Compared
  /// against the cloud's *current* `updated` time to detect "another device
  /// backed up since I last checked."
  final DateTime lastSeenCloudUpdatedAt;

  const CloudSyncMarker({
    required this.backedUpAt,
    required this.lastSeenCloudUpdatedAt,
  });
}

/// Encrypted whole-database backup/restore for one Firebase account, backed
/// by Firebase Storage. Abstract so `CloudSyncNotifier` and its tests never
/// need to import the concrete `WebCloudBackupService` (which pulls in
/// `package:web` and cannot compile under a plain `flutter test` run — see
/// Task 2's note). The real implementation is `WebCloudBackupService`
/// (Task 4); it's the only thing that ever needs a passphrase, an
/// `AesGcm` key, or IndexedDB.
abstract class CloudBackupService {
  /// The cloud backup object's `updated` timestamp, or `null` if no backup
  /// exists yet for this account.
  Future<DateTime?> remoteBackupUpdatedAt(String uid);

  /// Uploads this device's current local database envelope as-is (it's
  /// already encrypted — this never decrypts or re-encrypts anything).
  /// Updates the local marker. Returns the backup's new `updated` timestamp.
  Future<DateTime> backup(String uid);

  /// Downloads the cloud backup, verifies [passphrase] can decrypt it, and
  /// — only on success — overwrites the local IndexedDB envelope with the
  /// cloud's salt/iv/ciphertext and updates the local marker. Throws if no
  /// backup exists, or if [passphrase] is wrong (an AES-GCM tag mismatch,
  /// the same signal `WebPassphraseScreen` already relies on). The caller
  /// is responsible for reloading the page after a successful call — the
  /// currently-running app instance still has the *old* local data loaded
  /// in memory.
  Future<DateTime> restoreVerifyingPassphrase(String uid, String passphrase);

  /// This device's locally stored marker for [uid], or `null` if this
  /// device has never synced with this account before.
  Future<CloudSyncMarker?> readMarker(String uid);

  /// Records that the user chose to keep this device's data rather than
  /// restore [remoteUpdatedAt] — does not touch local data or the cloud
  /// object. The next debounced local write will naturally overwrite the
  /// cloud backup via [backup].
  Future<void> markResolvedKeepingLocal(String uid, DateTime remoteUpdatedAt);
}
```

- [ ] **Step 6: Verify everything still analyzes and tests pass**

```bash
flutter analyze --no-fatal-infos
flutter test test/core/services/cloud_backup_envelope_test.dart
```

Expected: analyze clean, test `+5: All tests passed!`.

- [ ] **Step 7: Commit**

```bash
git add lib/core/services/cloud_backup_envelope.dart lib/core/services/cloud_backup_service.dart test/core/services/cloud_backup_envelope_test.dart
git commit -m "feat: add pure backup envelope codec and abstract CloudBackupService"
```

---

## Task 4: Concrete `WebCloudBackupService` and its factory

**Files:**
- Create: `lib/core/services/web_cloud_backup_service.dart`
- Create: `lib/core/services/cloud_backup_service_factory_stub.dart`
- Create: `lib/core/services/cloud_backup_service_factory_web.dart`
- Create: `lib/core/services/cloud_backup_service_factory_native.dart`

**Interfaces:**
- Consumes: `CloudBackupService`, `CloudSyncMarker` (Task 3); `encodeBackupEnvelope`, `decodeBackupEnvelope`, `DecodedBackupEnvelope` (Task 3); `deriveAesKey`, `decryptBytes` (Task 2's `web_crypto.dart`); `DbEnvelope`, `loadDbEnvelope`, `saveDbEnvelope` (Task 2's `web_db_envelope.dart`); `appSecureStorage` (existing, `lib/core/services/app_secure_storage.dart`).
- Produces: `class WebCloudBackupService implements CloudBackupService`; `CloudBackupService createCloudBackupService()` (one implementation per conditional-import target).

No unit tests in this task — `WebCloudBackupService` transitively imports `package:web` (via `web_crypto.dart`/`web_db_envelope.dart`) and cannot compile under `flutter test`. It's verified live in Task 9. This is the same testing gap `connection_web.dart` already has today, for the same reason.

- [ ] **Step 1: Create `lib/core/services/web_cloud_backup_service.dart`**

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/connection/web_crypto.dart';
import '../database/connection/web_db_envelope.dart';
import 'app_secure_storage.dart';
import 'cloud_backup_envelope.dart';
import 'cloud_backup_service.dart';

/// Real [CloudBackupService] for the web build. Inject custom instances in
/// tests that run under `flutter test -d chrome` (not the default VM
/// runner — see Task 2's note on why this file can't be imported there).
class WebCloudBackupService implements CloudBackupService {
  final FirebaseStorage _storage;
  final FlutterSecureStorage _secureStorage;

  WebCloudBackupService({
    FirebaseStorage? storage,
    FlutterSecureStorage? secureStorage,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _secureStorage = secureStorage ?? appSecureStorage;

  /// Generous enough for a real, actively-used recovery journal — SQLite
  /// page preallocation means even one entry can already be multi-MB (see
  /// the comment in `connection_web.dart`'s original design notes).
  static const int _maxBackupBytes = 100 * 1024 * 1024;
  static const String _markerKeyPrefix = 'fearless_cloud_sync_marker_v1_';

  Reference _ref(String uid) => _storage.ref('users/$uid/db_backup.enc');

  @override
  Future<DateTime?> remoteBackupUpdatedAt(String uid) async {
    try {
      final meta = await _ref(uid).getMetadata();
      return meta.updated;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return null;
      rethrow;
    }
  }

  @override
  Future<DateTime> backup(String uid) async {
    final envelope = await loadDbEnvelope();
    if (envelope == null) {
      throw StateError('No local database envelope to back up.');
    }
    final bytes = encodeBackupEnvelope(
      salt: envelope.salt,
      iv: envelope.iv,
      ciphertext: envelope.ciphertext,
    );
    final snapshot = await _ref(uid).putData(
      bytes,
      SettableMetadata(contentType: 'application/octet-stream'),
    );
    final updatedAt = snapshot.metadata?.updated ?? DateTime.now().toUtc();
    await _writeMarker(
      uid,
      CloudSyncMarker(backedUpAt: updatedAt, lastSeenCloudUpdatedAt: updatedAt),
    );
    return updatedAt;
  }

  @override
  Future<DateTime> restoreVerifyingPassphrase(String uid, String passphrase) async {
    final bytes = await _ref(uid).getData(_maxBackupBytes);
    if (bytes == null) {
      throw StateError('No cloud backup found for this account.');
    }
    final decoded = decodeBackupEnvelope(bytes);
    final key = await deriveAesKey(passphrase, decoded.salt);
    // Throws (AES-GCM tag mismatch) on a wrong passphrase — deliberately
    // not caught here, so the caller sees the failure and can prompt again
    // without this device's local data having been touched.
    await decryptBytes(key, decoded.iv, decoded.ciphertext);

    await saveDbEnvelope(decoded.salt, decoded.iv, decoded.ciphertext);
    final updatedAt = await remoteBackupUpdatedAt(uid) ?? DateTime.now().toUtc();
    await _writeMarker(
      uid,
      CloudSyncMarker(backedUpAt: updatedAt, lastSeenCloudUpdatedAt: updatedAt),
    );
    return updatedAt;
  }

  @override
  Future<CloudSyncMarker?> readMarker(String uid) async {
    final raw = await _secureStorage.read(key: '$_markerKeyPrefix$uid');
    if (raw == null) return null;
    final parts = raw.split('|');
    if (parts.length != 2) return null;
    final backedUpAt = DateTime.tryParse(parts[0]);
    final lastSeenCloudUpdatedAt = DateTime.tryParse(parts[1]);
    if (backedUpAt == null || lastSeenCloudUpdatedAt == null) return null;
    return CloudSyncMarker(
      backedUpAt: backedUpAt,
      lastSeenCloudUpdatedAt: lastSeenCloudUpdatedAt,
    );
  }

  @override
  Future<void> markResolvedKeepingLocal(String uid, DateTime remoteUpdatedAt) => _writeMarker(
        uid,
        CloudSyncMarker(
          backedUpAt: DateTime.now().toUtc(),
          lastSeenCloudUpdatedAt: remoteUpdatedAt,
        ),
      );

  Future<void> _writeMarker(String uid, CloudSyncMarker marker) => _secureStorage.write(
        key: '$_markerKeyPrefix$uid',
        value:
            '${marker.backedUpAt.toIso8601String()}|${marker.lastSeenCloudUpdatedAt.toIso8601String()}',
      );
}
```

- [ ] **Step 2: Create the factory conditional-import trio**

`lib/core/services/cloud_backup_service_factory_stub.dart`:

```dart
import 'cloud_backup_service.dart';

/// Replaced by `cloud_backup_service_factory_web.dart` or
/// `cloud_backup_service_factory_native.dart` via the conditional import in
/// `cloud_sync_provider.dart`. Never actually reached.
CloudBackupService createCloudBackupService() {
  throw UnsupportedError('No CloudBackupService implementation for this platform.');
}
```

`lib/core/services/cloud_backup_service_factory_native.dart`:

```dart
import 'cloud_backup_service.dart';

/// Cloud sync is web-only (see the design spec) — `CloudSyncGate` never
/// mounts on native, so this is never actually called, but the symbol must
/// exist so native builds compile.
CloudBackupService createCloudBackupService() {
  throw UnsupportedError('Cloud backup is only supported on the web build.');
}
```

`lib/core/services/cloud_backup_service_factory_web.dart`:

```dart
import 'cloud_backup_service.dart';
import 'web_cloud_backup_service.dart';

CloudBackupService createCloudBackupService() => WebCloudBackupService();
```

- [ ] **Step 3: Verify it analyzes and the web build still succeeds**

```bash
flutter analyze --no-fatal-infos
flutter build web --release
```

Expected: both succeed with no new errors.

- [ ] **Step 4: Commit**

```bash
git add lib/core/services/web_cloud_backup_service.dart lib/core/services/cloud_backup_service_factory_stub.dart lib/core/services/cloud_backup_service_factory_web.dart lib/core/services/cloud_backup_service_factory_native.dart
git commit -m "feat: add WebCloudBackupService and its platform factory"
```

---

## Task 5: `CloudSyncNotifier` state machine

**Files:**
- Create: `lib/core/services/page_reload_stub.dart`
- Create: `lib/core/services/page_reload_web.dart`
- Create: `lib/core/services/page_reload_native.dart`
- Create: `lib/core/providers/cloud_sync_provider.dart`
- Test: `test/core/providers/cloud_sync_provider_test.dart`

**Interfaces:**
- Consumes: `CloudBackupService`, `CloudSyncMarker` (Task 3); `firebaseUserProvider` (existing, `lib/core/providers/auth_provider.dart`); `onLocalDbPersisted` via the existing `connection_stub`/`connection_web`/`connection_native` conditional-import trio (Task 2).
- Produces: `enum CloudSyncPhase { idle, needsReconciliation, synced }`; `class CloudSyncState { final CloudSyncPhase phase; final DateTime? localBackedUpAt; final DateTime? remoteUpdatedAt; }`; `class CloudSyncNotifier extends Notifier<CloudSyncState>` with methods `Future<void> useCloudBackup(String passphrase)` and `Future<void> keepLocalData()`; `final cloudBackupServiceProvider = Provider<CloudBackupService>(...)`; `final cloudSyncProvider = NotifierProvider<CloudSyncNotifier, CloudSyncState>(CloudSyncNotifier.new)`.

- [ ] **Step 1: Create the page-reload conditional-import trio**

`lib/core/services/page_reload_stub.dart`:

```dart
/// Replaced by `page_reload_web.dart` or `page_reload_native.dart` via the
/// conditional import in `cloud_sync_provider.dart`. Never actually reached.
void reloadPage() {
  throw UnsupportedError('reloadPage is only supported on the web build.');
}
```

`lib/core/services/page_reload_native.dart`:

```dart
/// Never called on native — cloud sync (and therefore a restore that needs
/// a reload) is web-only. Present so native builds compile.
void reloadPage() {
  throw UnsupportedError('reloadPage is only supported on the web build.');
}
```

`lib/core/services/page_reload_web.dart`:

```dart
import 'package:web/web.dart' as web;

/// After a successful cloud restore, the currently-running app instance
/// still has the *old* local database loaded in memory — a full reload
/// re-runs `main()`, which re-reads the just-overwritten IndexedDB envelope
/// from scratch via the normal `WebPassphraseScreen` boot path.
void reloadPage() => web.window.location.reload();
```

- [ ] **Step 2: Write the failing state-machine tests**

Create `test/core/providers/cloud_sync_provider_test.dart`:

```dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fearless_inventory/core/providers/auth_provider.dart';
import 'package:fearless_inventory/core/providers/cloud_sync_provider.dart';
import 'package:fearless_inventory/core/services/cloud_backup_service.dart';
import 'package:fearless_inventory/core/services/firebase_auth_service.dart';

class MockCloudBackupService extends Mock implements CloudBackupService {}

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class MockUser extends Mock implements User {}

void main() {
  late StreamController<User?> authController;
  late MockFirebaseAuthService mockAuth;
  late MockCloudBackupService mockBackup;
  late ProviderContainer container;

  const uid = 'test-uid';

  setUp(() {
    authController = StreamController<User?>.broadcast();
    mockAuth = MockFirebaseAuthService();
    when(() => mockAuth.userChanges).thenAnswer((_) => authController.stream);
    mockBackup = MockCloudBackupService();

    container = ProviderContainer(
      overrides: [
        firebaseAuthServiceProvider.overrideWithValue(mockAuth),
        cloudBackupServiceProvider.overrideWithValue(mockBackup),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(authController.close);
  });

  MockUser signedInUser() {
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    return user;
  }

  test('starts idle before any sign-in', () {
    final state = container.read(cloudSyncProvider);
    expect(state.phase, CloudSyncPhase.idle);
  });

  test('seeds a backup and becomes synced when no remote backup exists yet', () async {
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => null);
    final seededAt = DateTime.utc(2026, 1, 1);
    when(() => mockBackup.backup(uid)).thenAnswer((_) async => seededAt);

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.synced);
    verify(() => mockBackup.backup(uid)).called(1);
  });

  test('enters needsReconciliation when the cloud has no local marker but does have a backup', () async {
    final remoteUpdatedAt = DateTime.utc(2026, 2, 1);
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => remoteUpdatedAt);

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    final state = container.read(cloudSyncProvider);
    expect(state.phase, CloudSyncPhase.needsReconciliation);
    expect(state.remoteUpdatedAt, remoteUpdatedAt);
    verifyNever(() => mockBackup.backup(uid));
  });

  test('enters needsReconciliation when the cloud is newer than this device\'s marker', () async {
    final localMarker = CloudSyncMarker(
      backedUpAt: DateTime.utc(2026, 1, 1),
      lastSeenCloudUpdatedAt: DateTime.utc(2026, 1, 1),
    );
    final remoteUpdatedAt = DateTime.utc(2026, 2, 1); // newer
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => localMarker);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => remoteUpdatedAt);

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.needsReconciliation);
  });

  test('goes straight to synced when this device\'s marker already matches the cloud', () async {
    final sameTime = DateTime.utc(2026, 1, 1);
    final localMarker = CloudSyncMarker(backedUpAt: sameTime, lastSeenCloudUpdatedAt: sameTime);
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => localMarker);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => sameTime);

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.synced);
    verifyNever(() => mockBackup.backup(uid));
  });

  test('resets to idle on sign-out', () async {
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.backup(uid)).thenAnswer((_) async => DateTime.utc(2026, 1, 1));

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();
    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.synced);

    authController.add(null);
    await pumpEventQueue();
    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.idle);
  });

  test('useCloudBackup restores and transitions to synced', () async {
    final remoteUpdatedAt = DateTime.utc(2026, 2, 1);
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => remoteUpdatedAt);
    when(() => mockBackup.restoreVerifyingPassphrase(uid, 'correct-passphrase'))
        .thenAnswer((_) async => remoteUpdatedAt);

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();
    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.needsReconciliation);

    await container.read(cloudSyncProvider.notifier).useCloudBackup('correct-passphrase');

    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.synced);
    verify(() => mockBackup.restoreVerifyingPassphrase(uid, 'correct-passphrase')).called(1);
  });

  test('useCloudBackup with a wrong passphrase propagates the error and stays in needsReconciliation', () async {
    final remoteUpdatedAt = DateTime.utc(2026, 2, 1);
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => remoteUpdatedAt);
    when(() => mockBackup.restoreVerifyingPassphrase(uid, 'wrong'))
        .thenThrow(Exception('bad passphrase'));

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    await expectLater(
      container.read(cloudSyncProvider.notifier).useCloudBackup('wrong'),
      throwsException,
    );
    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.needsReconciliation);
  });

  test('keepLocalData records the resolution and transitions to synced', () async {
    final remoteUpdatedAt = DateTime.utc(2026, 2, 1);
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => remoteUpdatedAt);
    when(() => mockBackup.markResolvedKeepingLocal(uid, remoteUpdatedAt))
        .thenAnswer((_) async {});

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    await container.read(cloudSyncProvider.notifier).keepLocalData();

    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.synced);
    verify(() => mockBackup.markResolvedKeepingLocal(uid, remoteUpdatedAt)).called(1);
  });
}
```

- [ ] **Step 3: Run the tests to verify they fail (the provider file doesn't exist yet)**

```bash
flutter test test/core/providers/cloud_sync_provider_test.dart
```

Expected: FAIL — `Error: Error when reading 'lib/core/providers/cloud_sync_provider.dart': No such file or directory.`

- [ ] **Step 4: Create `lib/core/providers/cloud_sync_provider.dart`**

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/connection/connection_stub.dart'
    if (dart.library.html) '../database/connection/connection_web.dart'
    if (dart.library.io) '../database/connection/connection_native.dart'
    as conn;
import '../services/cloud_backup_service.dart';
import '../services/cloud_backup_service_factory_stub.dart'
    if (dart.library.html) '../services/cloud_backup_service_factory_web.dart'
    if (dart.library.io) '../services/cloud_backup_service_factory_native.dart'
    as backup_factory;
import '../services/page_reload_stub.dart'
    if (dart.library.html) '../services/page_reload_web.dart'
    if (dart.library.io) '../services/page_reload_native.dart'
    as page_reload;
import 'auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service provider
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton [CloudBackupService] — override in tests to inject a mock.
/// Resolves to a real [WebCloudBackupService] on web, and throws if
/// anything on native ever actually calls it (it shouldn't — see the
/// design spec's "Scope" section).
final cloudBackupServiceProvider = Provider<CloudBackupService>(
  (_) => backup_factory.createCloudBackupService(),
);

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

enum CloudSyncPhase {
  /// No account signed in, or sign-in status not yet resolved.
  idle,

  /// A cloud backup exists that this device hasn't reconciled with — the
  /// reconciliation dialog should be shown.
  needsReconciliation,

  /// Normal steady state: local writes are debounced into cloud backups.
  synced,
}

class CloudSyncState {
  final CloudSyncPhase phase;

  /// This device's local marker timestamp — "This device's data from
  /// [date]" in the reconciliation dialog. `null` if this device has never
  /// synced with the current account before.
  final DateTime? localBackedUpAt;

  /// The cloud backup's `updated` timestamp — "Cloud backup from [date]"
  /// in the reconciliation dialog. `null` before the first check completes.
  final DateTime? remoteUpdatedAt;

  const CloudSyncState({
    this.phase = CloudSyncPhase.idle,
    this.localBackedUpAt,
    this.remoteUpdatedAt,
  });

  CloudSyncState copyWith({
    CloudSyncPhase? phase,
    DateTime? localBackedUpAt,
    DateTime? remoteUpdatedAt,
  }) =>
      CloudSyncState(
        phase: phase ?? this.phase,
        localBackedUpAt: localBackedUpAt ?? this.localBackedUpAt,
        remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class CloudSyncNotifier extends Notifier<CloudSyncState> {
  Timer? _debounce;
  String? _uid;

  static const _debounceDelay = Duration(seconds: 30);

  @override
  CloudSyncState build() {
    conn.onLocalDbPersisted = _onLocalWrite;

    ref.listen(firebaseUserProvider, (previous, next) {
      final user = next.valueOrNull;
      _uid = user?.uid;
      if (user == null) {
        _debounce?.cancel();
        state = const CloudSyncState();
        return;
      }
      unawaited(_checkOnSignIn(user.uid));
    });

    ref.onDispose(() {
      _debounce?.cancel();
      conn.onLocalDbPersisted = null;
    });

    return const CloudSyncState();
  }

  CloudBackupService get _service => ref.read(cloudBackupServiceProvider);

  Future<void> _checkOnSignIn(String uid) async {
    final marker = await _service.readMarker(uid);
    final remoteUpdatedAt = await _service.remoteBackupUpdatedAt(uid);

    if (remoteUpdatedAt == null) {
      // Nothing in the cloud yet for this account — this device's data
      // becomes the seed.
      final backedUpAt = await _service.backup(uid);
      state = CloudSyncState(
        phase: CloudSyncPhase.synced,
        localBackedUpAt: backedUpAt,
        remoteUpdatedAt: backedUpAt,
      );
      return;
    }

    final needsReconciliation =
        marker == null || marker.lastSeenCloudUpdatedAt.isBefore(remoteUpdatedAt);

    state = CloudSyncState(
      phase: needsReconciliation ? CloudSyncPhase.needsReconciliation : CloudSyncPhase.synced,
      localBackedUpAt: marker?.backedUpAt,
      remoteUpdatedAt: remoteUpdatedAt,
    );
  }

  void _onLocalWrite() {
    if (state.phase != CloudSyncPhase.synced) return;
    final uid = _uid;
    if (uid == null) return;
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => unawaited(_backupNow(uid)));
  }

  Future<void> _backupNow(String uid) async {
    final updatedAt = await _service.backup(uid);
    state = state.copyWith(
      phase: CloudSyncPhase.synced,
      localBackedUpAt: updatedAt,
      remoteUpdatedAt: updatedAt,
    );
  }

  // ── Called by the reconciliation dialog ──────────────────────────────────

  /// Restores the cloud backup after verifying [passphrase] decrypts it.
  /// Rethrows on a wrong passphrase — the dialog stays open and shows an
  /// error rather than this device's data being touched. On success,
  /// reloads the page so the app re-boots against the just-restored data.
  Future<void> useCloudBackup(String passphrase) async {
    final uid = _uid;
    if (uid == null) return;
    final updatedAt = await _service.restoreVerifyingPassphrase(uid, passphrase);
    state = CloudSyncState(
      phase: CloudSyncPhase.synced,
      localBackedUpAt: updatedAt,
      remoteUpdatedAt: updatedAt,
    );
    page_reload.reloadPage();
  }

  Future<void> keepLocalData() async {
    final uid = _uid;
    final remoteUpdatedAt = state.remoteUpdatedAt;
    if (uid == null || remoteUpdatedAt == null) return;
    await _service.markResolvedKeepingLocal(uid, remoteUpdatedAt);
    state = state.copyWith(phase: CloudSyncPhase.synced);
  }
}

final cloudSyncProvider = NotifierProvider<CloudSyncNotifier, CloudSyncState>(
  CloudSyncNotifier.new,
);
```

- [ ] **Step 5: Run the tests to verify they pass**

```bash
flutter test test/core/providers/cloud_sync_provider_test.dart
```

Expected: `+9: All tests passed!`

- [ ] **Step 6: Verify the full suite and analyzer are still clean**

```bash
flutter analyze --no-fatal-infos
flutter test
```

Expected: analyze clean; test suite passes except the one pre-existing, environment-only failure already documented in this repo (`test/tool/render_privacy_policy_test.dart`, missing local Python — unrelated to this change, confirmed via `git stash` earlier this session).

- [ ] **Step 7: Commit**

```bash
git add lib/core/services/page_reload_stub.dart lib/core/services/page_reload_web.dart lib/core/services/page_reload_native.dart lib/core/providers/cloud_sync_provider.dart test/core/providers/cloud_sync_provider_test.dart
git commit -m "feat: add CloudSyncNotifier state machine with tests"
```

---

## Task 6: Reconciliation dialog

**Files:**
- Create: `lib/features/auth/widgets/reconciliation_dialog.dart`
- Test: `test/features/auth/widgets/reconciliation_dialog_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks except plain Dart types (`DateTime`) — deliberately decoupled from Riverpod/`CloudSyncNotifier` so it's a pure, easily-testable presentation widget. Wired to the notifier in Task 7.
- Produces: `class ReconciliationDialog extends StatefulWidget` with constructor params `remoteUpdatedAt` (`DateTime`, required), `localBackedUpAt` (`DateTime?`), `onUseCloudBackup` (`Future<void> Function(String passphrase)`, required), `onKeepLocalData` (`VoidCallback`, required).

Note on scope vs. the spec: the spec described a two-step flow (try the device's current passphrase automatically first, only ask for one on failure). Building that requires exposing the in-memory `web.CryptoKey` the app derived when the user unlocked this session — not currently reachable from outside `connection_web.dart`'s `LazyDatabase` closure, and caching key material somewhere more global is a worse security trade for a rare (reconciliation-only) code path. This implementation always asks for the passphrase up front instead — same product guarantees (never silently overwrites, always shows both dates, wrong passphrase never touches local data), one screen instead of two.

- [ ] **Step 1: Write the failing widget test**

Create `test/features/auth/widgets/reconciliation_dialog_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/features/auth/widgets/reconciliation_dialog.dart';

void main() {
  Future<void> pumpDialog(
    WidgetTester tester, {
    required DateTime remoteUpdatedAt,
    DateTime? localBackedUpAt,
    Future<void> Function(String)? onUseCloudBackup,
    VoidCallback? onKeepLocalData,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => ReconciliationDialog(
                remoteUpdatedAt: remoteUpdatedAt,
                localBackedUpAt: localBackedUpAt,
                onUseCloudBackup: onUseCloudBackup ?? (_) async {},
                onKeepLocalData: onKeepLocalData ?? () {},
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows both the cloud and local dates', (tester) async {
    await pumpDialog(
      tester,
      remoteUpdatedAt: DateTime.utc(2026, 2, 15, 10, 30),
      localBackedUpAt: DateTime.utc(2026, 1, 1, 9),
    );

    expect(find.textContaining('Cloud backup'), findsOneWidget);
    expect(find.textContaining("This device's data"), findsOneWidget);
  });

  testWidgets('shows a fallback when this device has no earlier backup', (tester) async {
    await pumpDialog(
      tester,
      remoteUpdatedAt: DateTime.utc(2026, 2, 15, 10, 30),
      localBackedUpAt: null,
    );

    expect(find.textContaining('no earlier backup'), findsOneWidget);
  });

  testWidgets("Keep this device's data calls onKeepLocalData and closes the dialog", (tester) async {
    var called = false;
    await pumpDialog(
      tester,
      remoteUpdatedAt: DateTime.utc(2026, 2, 15),
      onKeepLocalData: () => called = true,
    );

    await tester.tap(find.text("Keep this device's data"));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    expect(find.byType(ReconciliationDialog), findsNothing);
  });

  testWidgets('Use cloud backup requires a non-empty passphrase', (tester) async {
    var called = false;
    await pumpDialog(
      tester,
      remoteUpdatedAt: DateTime.utc(2026, 2, 15),
      onUseCloudBackup: (_) async => called = true,
    );

    await tester.tap(find.text('Use cloud backup'));
    await tester.pumpAndSettle();

    expect(called, isFalse);
    expect(find.textContaining('Enter the passphrase'), findsOneWidget);
  });

  testWidgets('Use cloud backup calls onUseCloudBackup with the entered passphrase', (tester) async {
    String? received;
    await pumpDialog(
      tester,
      remoteUpdatedAt: DateTime.utc(2026, 2, 15),
      onUseCloudBackup: (p) async => received = p,
    );

    await tester.enterText(find.byType(TextField), 'my-passphrase');
    await tester.tap(find.text('Use cloud backup'));
    await tester.pumpAndSettle();

    expect(received, 'my-passphrase');
  });

  testWidgets('shows an error and stays open when onUseCloudBackup throws', (tester) async {
    await pumpDialog(
      tester,
      remoteUpdatedAt: DateTime.utc(2026, 2, 15),
      onUseCloudBackup: (_) async => throw Exception('wrong passphrase'),
    );

    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.tap(find.text('Use cloud backup'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not decrypt'), findsOneWidget);
    expect(find.byType(ReconciliationDialog), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

```bash
flutter test test/features/auth/widgets/reconciliation_dialog_test.dart
```

Expected: FAIL — source file doesn't exist yet.

- [ ] **Step 3: Create `lib/features/auth/widgets/reconciliation_dialog.dart`**

```dart
import 'package:flutter/material.dart';

/// Shown whenever `CloudSyncNotifier` detects that the cloud backup and
/// this device's data disagree. Never silently resolves either way — one
/// of the two buttons must be tapped for anything to change; dismissing
/// the dialog (tap outside, back button) leaves the conflict unresolved
/// and it reappears at the next check (sign-in, or opening Account).
class ReconciliationDialog extends StatefulWidget {
  final DateTime remoteUpdatedAt;
  final DateTime? localBackedUpAt;
  final Future<void> Function(String passphrase) onUseCloudBackup;
  final VoidCallback onKeepLocalData;

  const ReconciliationDialog({
    super.key,
    required this.remoteUpdatedAt,
    required this.localBackedUpAt,
    required this.onUseCloudBackup,
    required this.onKeepLocalData,
  });

  @override
  State<ReconciliationDialog> createState() => _ReconciliationDialogState();
}

class _ReconciliationDialogState extends State<ReconciliationDialog> {
  final _passphraseController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }

  Future<void> _submit() async {
    final passphrase = _passphraseController.text;
    if (passphrase.isEmpty) {
      setState(() => _error = 'Enter the passphrase used for that backup.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.onUseCloudBackup(passphrase);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = 'Could not decrypt with that passphrase.';
      });
    }
  }

  void _keepLocal() {
    widget.onKeepLocalData();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final localLabel = widget.localBackedUpAt == null
        ? 'This device has no earlier backup'
        : "This device's data from ${_formatDate(widget.localBackedUpAt!)}";

    return AlertDialog(
      title: const Text('Cloud backup found'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cloud backup from ${_formatDate(widget.remoteUpdatedAt)}'),
          const SizedBox(height: 4),
          Text(localLabel),
          const SizedBox(height: 16),
          TextField(
            controller: _passphraseController,
            obscureText: true,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: 'Passphrase for the cloud backup',
            ),
            onSubmitted: (_) => _isSubmitting ? null : _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : _keepLocal,
          child: const Text("Keep this device's data"),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Use cloud backup'),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

```bash
flutter test test/features/auth/widgets/reconciliation_dialog_test.dart
```

Expected: `+6: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/widgets/reconciliation_dialog.dart test/features/auth/widgets/reconciliation_dialog_test.dart
git commit -m "feat: add ReconciliationDialog widget with tests"
```

---

## Task 7: `CloudSyncGate` and bootstrap wiring

**Files:**
- Create: `lib/features/auth/widgets/cloud_sync_gate.dart`
- Modify: `lib/core/navigation/bootstrap_shell.dart`
- Test: `test/features/auth/widgets/cloud_sync_gate_test.dart`

**Interfaces:**
- Consumes: `cloudSyncProvider`, `CloudSyncPhase`, `CloudSyncState` (Task 5); `ReconciliationDialog` (Task 6).
- Produces: `class CloudSyncGate extends ConsumerStatefulWidget` with a required `child` widget param.

- [ ] **Step 1: Write the failing widget test**

Create `test/features/auth/widgets/cloud_sync_gate_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/providers/cloud_sync_provider.dart';
import 'package:fearless_inventory/features/auth/widgets/cloud_sync_gate.dart';
import 'package:fearless_inventory/features/auth/widgets/reconciliation_dialog.dart';

class _FakeCloudSyncNotifier extends CloudSyncNotifier {
  final CloudSyncState initial;
  _FakeCloudSyncNotifier(this.initial);

  @override
  CloudSyncState build() => initial;
}

Future<void> pumpGate(WidgetTester tester, CloudSyncState state) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cloudSyncProvider.overrideWith(() => _FakeCloudSyncNotifier(state)),
      ],
      child: const MaterialApp(
        home: CloudSyncGate(child: Text('home content')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the child and no dialog when synced', (tester) async {
    await pumpGate(tester, const CloudSyncState(phase: CloudSyncPhase.synced));

    expect(find.text('home content'), findsOneWidget);
    expect(find.byType(ReconciliationDialog), findsNothing);
  });

  testWidgets('renders the child and no dialog when idle', (tester) async {
    await pumpGate(tester, const CloudSyncState(phase: CloudSyncPhase.idle));

    expect(find.text('home content'), findsOneWidget);
    expect(find.byType(ReconciliationDialog), findsNothing);
  });

  testWidgets('always renders the child even under the dialog', (tester) async {
    await pumpGate(
      tester,
      CloudSyncState(
        phase: CloudSyncPhase.needsReconciliation,
        remoteUpdatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    expect(find.text('home content'), findsOneWidget);
  });
}
```

Note: this test only covers phases whose dialog behavior doesn't depend on a state *transition* (Riverpod's `ref.listen` fires on change, not on the initial `build()` value, so starting a test already in `needsReconciliation` does not by itself trigger the dialog — that's exercised live in Task 9, where a real sign-in drives a real `idle → needsReconciliation` transition). The three cases above cover what's mechanically testable here: the gate always renders its child, and doesn't spuriously show a dialog in the steady-state phases.

- [ ] **Step 2: Run the tests to verify they fail**

```bash
flutter test test/features/auth/widgets/cloud_sync_gate_test.dart
```

Expected: FAIL — source file doesn't exist yet.

- [ ] **Step 3: Create `lib/features/auth/widgets/cloud_sync_gate.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/cloud_sync_provider.dart';
import 'reconciliation_dialog.dart';

/// Wraps the signed-in web app shell. Watches [cloudSyncProvider] and shows
/// [ReconciliationDialog] whenever a conflict is detected, without ever
/// blocking or replacing [child] — the dialog floats above it.
class CloudSyncGate extends ConsumerStatefulWidget {
  final Widget child;
  const CloudSyncGate({super.key, required this.child});

  @override
  ConsumerState<CloudSyncGate> createState() => _CloudSyncGateState();
}

class _CloudSyncGateState extends ConsumerState<CloudSyncGate> {
  bool _dialogShowing = false;

  void _maybeShowDialog(CloudSyncState state) {
    if (state.phase != CloudSyncPhase.needsReconciliation) return;
    if (_dialogShowing) return;
    final remoteUpdatedAt = state.remoteUpdatedAt;
    if (remoteUpdatedAt == null) return;

    _dialogShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final notifier = ref.read(cloudSyncProvider.notifier);
      await showDialog<void>(
        context: context,
        builder: (_) => ReconciliationDialog(
          remoteUpdatedAt: remoteUpdatedAt,
          localBackedUpAt: state.localBackedUpAt,
          onUseCloudBackup: notifier.useCloudBackup,
          onKeepLocalData: () => notifier.keepLocalData(),
        ),
      );
      _dialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CloudSyncState>(cloudSyncProvider, (previous, next) {
      _maybeShowDialog(next);
    });
    return widget.child;
  }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

```bash
flutter test test/features/auth/widgets/cloud_sync_gate_test.dart
```

Expected: `+3: All tests passed!`

- [ ] **Step 5: Wire `CloudSyncGate` into `bootstrap_shell.dart`**

In `lib/core/navigation/bootstrap_shell.dart`, add the import:

```dart
import '../../features/auth/widgets/cloud_sync_gate.dart';
```

Then change:

```dart
            if (kIsWeb) {
              return const HomeScreen();
            }
```

to:

```dart
            if (kIsWeb) {
              return const CloudSyncGate(child: HomeScreen());
            }
```

- [ ] **Step 6: Verify the full suite and analyzer are still clean**

```bash
flutter analyze --no-fatal-infos
flutter test
```

Expected: analyze clean; same pre-existing single failure as Task 5's Step 6, nothing new.

- [ ] **Step 7: Commit**

```bash
git add lib/features/auth/widgets/cloud_sync_gate.dart lib/core/navigation/bootstrap_shell.dart test/features/auth/widgets/cloud_sync_gate_test.dart
git commit -m "feat: wire CloudSyncGate into the web bootstrap flow"
```

---

## Task 8: Account screen status line

**Files:**
- Modify: `lib/features/auth/screens/account_screen.dart`

**Interfaces:**
- Consumes: `cloudSyncProvider`, `CloudSyncState`, `CloudSyncPhase` (Task 5).

`account_screen.dart` has no existing test file (confirmed: `find test -iname "*account_screen*"` returns nothing) — this task follows that existing precedent and is verified live in Task 9 rather than adding a new widget test for a screen that has none today.

- [ ] **Step 1: Add the import**

In `lib/features/auth/screens/account_screen.dart`, add:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/cloud_sync_provider.dart';
```

(The `flutter_riverpod` import may already be present via another path — check before adding a duplicate; `ConsumerWidget` is already used in this file per its `class AccountScreen extends ConsumerWidget` declaration, so the package import should already exist. Only add the `cloud_sync_provider.dart` import.)

- [ ] **Step 2: Add the status line to `_SignedInView`**

Change `_SignedInView` from a `ConsumerStatefulWidget` (it already is one) to read the sync state, and insert a status row. Find this existing block (the sign-in-methods section):

```dart
        // ── Sign-in methods ───────────────────────────────────────────────
        if (providers.isNotEmpty) ...[
          const Divider(height: 32, color: Colors.white12),
          _SectionHeader('Sign-in Methods'),
          const SizedBox(height: 8),
          ...providers.map((pid) => _ProviderChip(providerId: pid)),
          const SizedBox(height: 4),
        ],
```

Add immediately after it (still inside the `ListView`'s `children`):

```dart
        // ── Cloud backup status ─────────────────────────────────────────
        Builder(builder: (context) {
          final syncState = ref.watch(cloudSyncProvider);
          final label = switch (syncState.phase) {
            CloudSyncPhase.synced when syncState.localBackedUpAt != null =>
              'Last backed up: ${_formatRelative(syncState.localBackedUpAt!)}',
            CloudSyncPhase.needsReconciliation => 'Backup needs your attention',
            _ => 'Not backed up yet',
          };
          return Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.cloud_done_outlined, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              ],
            ),
          );
        }),
```

- [ ] **Step 3: Add the `_formatRelative` helper**

Add this private top-level function near the other helper widgets at the bottom of the file (next to `_SectionHeader`, `_PrivacyPoint`, `_ProviderChip`):

```dart
String _formatRelative(DateTime dt) {
  final diff = DateTime.now().toUtc().difference(dt.toUtc());
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
```

- [ ] **Step 4: Verify it analyzes clean**

```bash
flutter analyze --no-fatal-infos
```

Expected: no new errors/warnings. If the `ConsumerWidget`/`ref` access inside `_SignedInViewState` needs adjustment (it's already a `ConsumerState`, so `ref` is already available directly — the `Builder` wrapper above is not required for `ref` access, only kept for locality of the `switch` expression; if the analyzer flags the `Builder` as unnecessary, remove it and inline the `final syncState = ref.watch(cloudSyncProvider);` line directly in `build()` instead), fix and re-run this step.

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/screens/account_screen.dart
git commit -m "feat: show cloud backup status on the account screen"
```

---

## Task 9: Deploy Storage rules and live end-to-end verification

**Files:** none (deployment + manual verification only)

This is the task that actually proves the feature works — every prior task was either pure-logic-tested or (for the `package:web`-dependent pieces) only analyzer/build-verified. Do not consider this feature done until every step here passes for real, against the real `fearless-inventory` Firebase project, matching how Task 2's Step 8 already required a live check for the underlying crypto refactor.

- [ ] **Step 1: Confirm Firebase CLI auth for this project**

```bash
npx firebase-tools projects:list
```

Expected: exits 0 and lists `fearless-inventory` (or the account is already logged in — the design spec noted `npx firebase-tools --version` resolved fine this session, but login status was unconfirmed). If this fails with an auth error, stop and tell the user — deploying rules needs either an interactive `firebase login` or a CI token (`FIREBASE_TOKEN`) this session doesn't have; don't attempt to work around it.

- [ ] **Step 2: Deploy the Storage rules**

```bash
npx firebase-tools deploy --only storage:rules --project fearless-inventory
```

Expected: exits 0, output confirms `storage: released rules storage.rules to firebase.storage`.

- [ ] **Step 3: Build and deploy the web app**

```bash
flutter build web --release
```

Then deploy via whichever mechanism this project already uses for its web hosting (check `wrangler.jsonc` / prior deploy commands used elsewhere in this session's history for this repo — Cloudflare Pages/Workers, consistent with the rest of this portfolio). Confirm the deploy actually completed (a URL or success message, not just a local build).

- [ ] **Step 4: Live verification — first device seeds a backup**

In the Browser pane, open the deployed URL in a **fresh** browser profile/incognito context (call this "Device A"). Create a passphrase, sign in with a real test account (email/password via the existing `RegisterScreen`/`LoginScreen`), add at least one piece of real content (e.g. a Step 10 review entry) so there's something to distinguish devices by.

Check Account screen: confirm the "Last backed up" line appears (may say "Not backed up yet" briefly, then update — the debounce is 30s, or immediate if this was the "seed" path with no prior remote backup).

Confirm via the browser's network inspector (or `read_network_requests` if using the agent browser tools) that a `PUT`/upload request to `firebasestorage.googleapis.com` for `users/{uid}/db_backup.enc` actually happened and returned success.

- [ ] **Step 5: Live verification — second device restores**

Open the same deployed URL in a **different** fresh profile/incognito context ("Device B"). Create a passphrase using the **exact same passphrase** as Device A (required — see the design spec's "Why this is tractable on web" section). Sign in with the **same account** used on Device A.

Expected: the reconciliation dialog appears (Device B has no local marker for this account, and a cloud backup exists — this is the `needsReconciliation` branch, not the "seed" branch). Verify both dates render sensibly. Enter the same passphrase used on Device A and tap "Use cloud backup."

Expected: the page reloads, `WebPassphraseScreen` shows "Enter your passphrase" (since an envelope now exists locally on Device B), the same passphrase unlocks it, and the content added on Device A (the Step 10 review entry from Step 4) is now visible on Device B.

- [ ] **Step 6: Live verification — wrong passphrase on restore**

Repeat Step 5 in a third fresh profile ("Device C"), but when the reconciliation dialog appears, enter an intentionally wrong passphrase.

Expected: the dialog shows "Could not decrypt with that passphrase," stays open, and Device C's local state is untouched (it never had any local data to lose in this case, but confirm no crash and no page reload happened). Then enter the correct passphrase and confirm it succeeds, matching Step 5.

- [ ] **Step 7: Live verification — "keep this device's data"**

On Device C (now synced from Step 6), add a new, different piece of content, then wait for it to back up (30s debounce, or check the Account screen's "Last backed up" line updates). Meanwhile add different new content on Device A and let it back up too, so Device A's cloud backup is now newer than what Device C last saw.

On Device C, reopen the Account screen (this re-checks against the cloud per the design). Expected: the reconciliation dialog reappears (Device C's marker is now behind the cloud). Tap "Keep this device's data" this time.

Expected: the dialog closes, no page reload, Device C's own newly-added content is still present and unchanged, and the Account screen's status updates without error.

- [ ] **Step 8: Clean up test accounts**

Delete the test Firebase account(s) used for this verification via each device's Account screen "Delete Account" action (already-shipped functionality, App-Store-required — see `account_screen.dart`), so no test artifacts are left in the production Firebase project.

- [ ] **Step 9: Final commit (if Steps 1-8 required any fixes)**

If live verification surfaced any bugs requiring code changes, fix them, re-run the relevant unit/widget tests plus `flutter analyze --no-fatal-infos`, then:

```bash
git add -A
git commit -m "fix: address issues found in live cloud-backup verification"
```

If no fixes were needed, there is nothing to commit for this task — the feature branch is done as of Task 8's commit.

---

## Self-Review Notes

**Spec coverage:** every section of `2026-09-13-web-cloud-backup-design.md` maps to a task — Storage layout/rules → Task 1; the "why tractable" crypto reuse → Task 2's extraction; `CloudBackupService`/envelope format → Tasks 3-4; local sync marker → Task 4 (folded into `WebCloudBackupService`, per the spec's own note that it's "stored via the existing `appSecureStorage`"); sync coordinator state machine → Task 5; debounced backup trigger → Task 5 (`onLocalDbPersisted` hook, Task 2); reconciliation dialog → Task 6; Account screen status line → Task 8; error handling (wrong passphrase, offline, rules-not-deployed) → covered in Tasks 4-6's implementations and Task 9's live checks; testing section → Tasks 3, 5, 6, 7 (unit/widget) + Task 9 (live). One deliberate, called-out deviation: the dialog's passphrase entry is a single step rather than the spec's "try automatically, then ask" two-step flow (see Task 6's note) — a "how" refinement discovered during planning, not a change to any product-level guarantee the spec made.

**Placeholder scan:** none found — every step has complete, concrete code or an exact command with expected output.

**Type consistency:** `CloudBackupService` (Task 3) methods match exactly between the abstract declaration, `WebCloudBackupService`'s implementation (Task 4), and every mock/call site in Task 5's tests and `CloudSyncNotifier`. `CloudSyncState`/`CloudSyncPhase` field names (`phase`, `localBackedUpAt`, `remoteUpdatedAt`) are consistent across Task 5's notifier, Task 6's dialog params, Task 7's gate, and Task 8's status line.
