import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
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
