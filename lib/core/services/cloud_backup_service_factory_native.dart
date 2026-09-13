import 'cloud_backup_service.dart';

/// Cloud sync is web-only (see the design spec) — `CloudSyncGate` never
/// mounts on native, so this is never actually called, but the symbol must
/// exist so native builds compile.
CloudBackupService createCloudBackupService() {
  throw UnsupportedError('Cloud backup is only supported on the web build.');
}
