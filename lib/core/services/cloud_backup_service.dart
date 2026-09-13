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
