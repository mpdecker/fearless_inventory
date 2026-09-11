import 'package:drift/drift.dart';

/// Replaced by connection_native.dart or connection_web.dart via the
/// conditional import in database.dart. Never actually reached.
QueryExecutor openConnection(String encryptionKey) {
  throw UnsupportedError('No database connection implementation for this platform.');
}

/// Native-only: opens a connection at an explicit file path (used by
/// [AppDatabase.forTesting]). Unsupported on web.
QueryExecutor openConnectionAt(String path, String encryptionKey) {
  throw UnsupportedError('openConnectionAt is only supported on native platforms.');
}

/// Web-only: whether an encrypted database already exists in this browser
/// profile (used to decide "create a passphrase" vs "enter your passphrase").
/// Always false on native — the passphrase gate never runs there.
Future<bool> webDatabaseExists() async => false;
