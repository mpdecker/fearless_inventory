import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
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
