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
