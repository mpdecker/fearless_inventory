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
// persist to localStorage. Same guarantee (data at rest is unreadable
// without the passphrase), simpler and more auditable implementation.
// ─────────────────────────────────────────────────────────────────────────

const _dbPath = '/fearless_inventory.db';
const _storageKey = 'fearless_inventory_encrypted_db_v1';
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

_Envelope? _loadEnvelope() {
  final raw = web.window.localStorage.getItem(_storageKey);
  if (raw == null) return null;
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return _Envelope(
    salt: base64Decode(json['salt'] as String),
    iv: base64Decode(json['iv'] as String),
    ciphertext: base64Decode(json['data'] as String),
  );
}

void _saveEnvelope(Uint8List salt, Uint8List iv, Uint8List ciphertext) {
  web.window.localStorage.setItem(
    _storageKey,
    jsonEncode({
      'salt': base64Encode(salt),
      'iv': base64Encode(iv),
      'data': base64Encode(ciphertext),
    }),
  );
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
    _saveEnvelope(salt, iv, ciphertext);
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

    final envelope = _loadEnvelope();
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
  return web.window.localStorage.getItem(_storageKey) != null;
}
