import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/services/sobriety_service.dart';

/// Exercises the real v16 → v17 upgrade path (adds `user_settings`).
///
/// There is no historical v16 schema snapshot in the repo, so we synthesize a
/// faithful v16 database: build the full current schema, then rewind it by
/// dropping the one table v17 introduced and resetting `user_version` to 16.
/// Reopening lets Drift's [MigrationStrategy] run the actual 16→17 step.
///
/// The test is self-validating: if the version rewind didn't take, no migration
/// would run, the dropped table would stay gone, and the final insert would
/// throw — so a pass proves the migration executed.
void main() {
  test('v16 → v17 creates user_settings and preserves existing data',
      () async {
    final dir = await Directory.systemTemp.createTemp('fi_mig_v17_');
    final file = File('${dir.path}/mig.db');
    addTearDown(() async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    // 1. Fresh v17 database + a pre-existing row in an older table.
    final seed = AppDatabase.testing(NativeDatabase(file));
    await seed.into(seed.literatureBookmarks).insert(
          LiteratureBookmarksCompanion.insert(
            bookKey: 'bigbook',
            chapterKey: 'bb_ch5',
            chapterTitle: 'How It Works',
          ),
        );
    await seed.close();

    // 2. Rewind the file to a genuine v16 state.
    final rewind = AppDatabase.testing(NativeDatabase(file));
    await rewind.customStatement('DROP TABLE user_settings');
    await rewind.customStatement('PRAGMA user_version = 16');
    await rewind.close();

    // 3. Reopen → Drift runs onUpgrade(16, 17).
    final migrated = AppDatabase.testing(NativeDatabase(file));
    addTearDown(migrated.close);

    final version = await migrated
        .customSelect('PRAGMA user_version')
        .map((r) => r.read<int>('user_version'))
        .getSingle();
    expect(version, 17, reason: 'schema should be upgraded to v17');

    // Pre-existing data survived the upgrade.
    final bookmarks = await migrated.select(migrated.literatureBookmarks).get();
    expect(bookmarks, hasLength(1));
    expect(bookmarks.single.chapterTitle, 'How It Works');

    // The new table exists and is writable — only true if the migration ran.
    await SobrietyService.setSobrietyDate(migrated, DateTime(2025, 3, 1));
    expect(
      await SobrietyService.getSobrietyDate(migrated),
      DateTime(2025, 3, 1),
    );
  });
}
