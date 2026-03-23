import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the per-device SQLCipher encryption key for the local database.
///
/// On first launch a 32-byte cryptographically random key is generated and
/// persisted in the OS-level secure storage (Android Keystore / iOS Keychain).
/// On every subsequent launch the same key is retrieved, so the database
/// remains readable across restarts without ever hard-coding a value.
class KeyService {
  static const String _keyRef = 'fearless_db_encryption_key_v1';

  static const _storage = FlutterSecureStorage(
    // Use encrypted shared preferences on Android (API 23+)
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Returns the database encryption key, creating and persisting it on the
  /// first call.  Subsequent calls return the same stored key.
  static Future<String> getOrCreateDatabaseKey() async {
    String? key = await _storage.read(key: _keyRef);

    if (key == null || key.isEmpty) {
      final random = Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await _storage.write(key: _keyRef, value: key);
    }

    return key;
  }
}
