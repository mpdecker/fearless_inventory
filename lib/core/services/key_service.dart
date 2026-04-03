import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_secure_storage.dart';

/// Manages the per-device SQLCipher encryption key for the local database.
///
/// On first launch a 32-byte cryptographically random key is generated and
/// persisted in the OS-level secure storage (Android Keystore / iOS Keychain).
/// On every subsequent launch the same key is retrieved, so the database
/// remains readable across restarts without ever hard-coding a value.
///
/// iOS Keychain entries can survive app deletion while the sandbox database
/// file does not. Call [clearStaleEncryptionKeyIfDatabaseMissing] before
/// [getOrCreateDatabaseKey] on startup when using the production DB path.
class KeyService {
  static const String storageKey = 'fearless_db_encryption_key_v1';

  /// Same basename as [AppDatabase] default connection — keep in sync with
  /// `lib/core/database/database.dart` (`fearless_inventory.db`).
  static const String productionDatabaseFileName = 'fearless_inventory.db';

  /// Production DB file under the app documents directory.
  static Future<File> productionDatabaseFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, productionDatabaseFileName));
  }

  /// If no database file exists but a key is still in secure storage (e.g. iOS
  /// Keychain survived reinstall), remove the stale key so the next
  /// [getOrCreateDatabaseKey] generates a fresh one.
  static Future<void> clearStaleEncryptionKeyIfDatabaseMissing(
    File databaseFile,
  ) async {
    if (await databaseFile.exists()) return;
    final existing = await appSecureStorage.read(key: storageKey);
    if (existing != null && existing.isNotEmpty) {
      await appSecureStorage.delete(key: storageKey);
    }
  }

  /// Returns the database encryption key, creating and persisting it on the
  /// first call. Subsequent calls return the same stored key.
  static Future<String> getOrCreateDatabaseKey() async {
    String? key = await appSecureStorage.read(key: storageKey);

    if (key == null || key.isEmpty) {
      final random = Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await appSecureStorage.write(key: storageKey, value: key);
    }

    return key;
  }
}
