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
