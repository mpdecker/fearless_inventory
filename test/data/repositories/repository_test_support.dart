import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:fearless_inventory/core/database/database.dart';

/// 32-byte hex key for encrypted test databases.
const kTestDatabaseKey =
    '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

Future<({Directory dir, File dbFile, AppDatabase db})> openTempEncryptedDb(
  String tempPrefix,
) async {
  final dir = await Directory.systemTemp.createTemp(tempPrefix);
  final dbFile = File(p.join(dir.path, 'test.db'));
  final db = AppDatabase.forTesting(dbFile, kTestDatabaseKey);
  return (dir: dir, dbFile: dbFile, db: db);
}

Future<void> disposeTempDb({
  required AppDatabase db,
  required Directory dir,
  required File dbFile,
}) async {
  try {
    await db.close();
  } catch (_) {}
  try {
    if (await dbFile.exists()) await dbFile.delete();
  } catch (_) {}
  try {
    await dir.delete(recursive: true);
  } catch (_) {}
}

/// Riverpod container with [databaseProvider] bound to [db].
ProviderContainer containerWithDatabase(AppDatabase db) {
  return ProviderContainer(
    overrides: [
      databaseProvider.overrideWith((ref) {
        ref.onDispose(() {});
        return db;
      }),
    ],
  );
}
