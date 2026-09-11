import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';
import 'package:typed_data/typed_buffers.dart';
import 'package:web/web.dart' as web;

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
// raw file bytes ourselves with WebCrypto (PBKDF2 → AES-GCM) before every
// persist to IndexedDB. Same guarantee (data at rest is unreadable without
// the passphrase), simpler and more auditable implementation.
//
// IndexedDB (not localStorage) because the encrypted blob easily exceeds
// localStorage's ~5-10MB per-origin cap on some browsers — a single journal
// entry already produces a multi-MB SQLite file (page preallocation), and
// IndexedDB stores the binary envelope directly instead of paying a ~33%
// base64 tax on top.
// ─────────────────────────────────────────────────────────────────────────

const _dbPath = '/fearless_inventory.db';
const _idbName = 'fearless_inventory_web_kv';
const _idbStoreName = 'encrypted_db';
const _idbEnvelopeKey = 'db_envelope_v1';
const _pbkdf2Iterations = 210000;
const _saltLength = 16;
const _ivLength = 12;

web.Crypto get _crypto => web.window.crypto;

Uint8List _randomBytes(int length) {
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

Future<web.CryptoKey> _deriveAesKey(String passphrase, Uint8List salt) async {
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

Future<Uint8List> _encrypt(web.CryptoKey key, Uint8List iv, Uint8List plaintext) async {
  final result = await _crypto.subtle.encrypt(
    _aesGcmParams(iv),
    key,
    plaintext.toJS,
  ).toDart;
  return (result as JSArrayBuffer).toDart.asUint8List();
}

/// Throws (AES-GCM tag verification failure) if [key] is derived from the
/// wrong passphrase — that failure *is* our "incorrect passphrase" signal.
Future<Uint8List> _decrypt(web.CryptoKey key, Uint8List iv, Uint8List ciphertext) async {
  final result = await _crypto.subtle.decrypt(
    _aesGcmParams(iv),
    key,
    ciphertext.toJS,
  ).toDart;
  return (result as JSArrayBuffer).toDart.asUint8List();
}

class _Envelope {
  final Uint8List salt;
  final Uint8List iv;
  final Uint8List ciphertext;
  _Envelope({required this.salt, required this.iv, required this.ciphertext});
}

// ─────────────────────────────────────────────────────────────────────────
// IndexedDB key-value store for the encrypted envelope
//
// A single object store holding one record (key [_idbEnvelopeKey]) whose
// value is a plain JS object of three Uint8Arrays — IndexedDB's structured
// clone stores binary data natively, no base64 needed.
// ─────────────────────────────────────────────────────────────────────────

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

Future<_Envelope?> _loadEnvelope() async {
  final db = await _openIdb();
  final completer = Completer<_Envelope?>();
  final store = db.transaction(_idbStoreName.toJS, 'readonly').objectStore(_idbStoreName);
  final request = store.get(_idbEnvelopeKey.toJS);
  request.onsuccess = ((web.Event _) {
    final result = request.result;
    if (result == null) {
      completer.complete(null);
      return;
    }
    final obj = result as JSObject;
    completer.complete(_Envelope(
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

Future<void> _saveEnvelope(Uint8List salt, Uint8List iv, Uint8List ciphertext) async {
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

/// Encrypts and persists the in-memory database file to localStorage after
/// every write that actually commits — autocommit statements immediately,
/// explicit transactions only once they commit (never mid-transaction, so a
/// persisted snapshot is always a consistent one). A fresh random IV is used
/// for every encryption (required for AES-GCM); the salt stays fixed for
/// the life of this passphrase so key derivation is reproducible.
class _PersistingInterceptor extends QueryInterceptor {
  final InMemoryFileSystem fs;
  final web.CryptoKey key;
  final Uint8List salt;
  _PersistingInterceptor(this.fs, this.key, this.salt);

  bool _isAutocommit(QueryExecutor executor) => executor is! TransactionExecutor;

  Future<void> _persist() async {
    final data = fs.fileData[_dbPath];
    if (data == null) return;
    final plaintext = data.buffer.asUint8List(0, data.length);
    final iv = _randomBytes(_ivLength);
    final ciphertext = await _encrypt(key, iv, plaintext);
    await _saveEnvelope(salt, iv, ciphertext);
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

    final envelope = await _loadEnvelope();
    final Uint8List salt;
    web.CryptoKey key;

    if (envelope != null) {
      salt = envelope.salt;
      key = await _deriveAesKey(encryptionKey, salt);
      // A wrong passphrase makes this throw (AES-GCM tag mismatch) — that
      // propagates out of this LazyDatabase's opening future, which is what
      // WebPassphraseScreen's verification query is waiting to catch.
      final plaintext = await _decrypt(key, envelope.iv, envelope.ciphertext);
      fs.fileData[_dbPath] = Uint8Buffer()..addAll(plaintext);
    } else {
      salt = _randomBytes(_saltLength);
      key = await _deriveAesKey(encryptionKey, salt);
    }

    final database = sqlite3.open(_dbPath);
    return WasmDatabase.opened(database)
        .interceptWith(_PersistingInterceptor(fs, key, salt));
  });
}

/// Whether an encrypted database already exists in this browser profile —
/// used by [WebPassphraseScreen] to decide "create a passphrase" vs
/// "enter your passphrase".
Future<bool> webDatabaseExists() async {
  return (await _loadEnvelope()) != null;
}
