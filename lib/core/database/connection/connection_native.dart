import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../services/key_service.dart';

void _configureEncryptedConnection(Database db, String encryptionKey) {
  // SQLite3MultipleCiphers (bundled via pubspec `hooks` → sqlite3: source: sqlite3mc).
  // SQLCipher-compatible settings for existing installs that used PRAGMA key + legacy.
  db.execute("PRAGMA key = '$encryptionKey';");
  db.execute('PRAGMA cipher = "sqlcipher";');
  db.execute('PRAGMA legacy = 4;');
  db.execute('PRAGMA foreign_keys = ON;');
}

QueryExecutor openConnectionAt(String path, String encryptionKey) {
  return LazyDatabase(() async {
    // [AppDatabase.forTesting] only: keep SQLite on the main isolate. Using
    // [NativeDatabase.createInBackground] under [testWidgets] + an early
    // [WidgetTester.pump] can stall indefinitely waiting on the isolate port
    // (e.g. notification_navigation_test.dart).
    return NativeDatabase(
      File(path),
      setup: (db) => _configureEncryptedConnection(db, encryptionKey),
    );
  });
}

QueryExecutor openConnection(String encryptionKey) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(
      p.join(dbFolder.path, KeyService.productionDatabaseFileName),
    );
    return NativeDatabase.createInBackground(
      file,
      setup: (db) => _configureEncryptedConnection(db, encryptionKey),
    );
  });
}

/// The web-only passphrase gate never runs on native.
Future<bool> webDatabaseExists() async => false;

/// Web-only in practice — see connection_web.dart. Declared here too so
/// code that references it (via the conditional import) compiles on every
/// platform; never actually called outside web.
void Function()? onLocalDbPersisted;
