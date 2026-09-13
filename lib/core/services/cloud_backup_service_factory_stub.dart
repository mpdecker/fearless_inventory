import 'cloud_backup_service.dart';

/// Replaced by `cloud_backup_service_factory_web.dart` or
/// `cloud_backup_service_factory_native.dart` via the conditional import in
/// `cloud_sync_provider.dart`. Never actually reached.
CloudBackupService createCloudBackupService() {
  throw UnsupportedError('No CloudBackupService implementation for this platform.');
}
