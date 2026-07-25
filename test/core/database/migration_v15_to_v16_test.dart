import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/literature_annotation_repository.dart';

/// Exercises the real v15 → v16 upgrade path (adds `literature_annotations`).
///
/// There is no historical v15 schema snapshot in the repo, so we synthesize a
/// faithful v15 database: build the full current schema, then rewind it by
/// dropping the one table v16 introduced and resetting `user_version` to 15.
/// Reopening lets Drift's [MigrationStrategy] run the actual 15→16 step.
///
/// The test is self-validating: if the version rewind didn't take, no migration
/// would run, the dropped table would stay gone, and the final insert would
/// throw — so a pass proves the migration executed.
void main() {
  test('v15 → v16 creates literature_annotations and preserves existing data',
      () async {
    final dir = await Directory.systemTemp.createTemp('fi_mig_v16_');
    final file = File('${dir.path}/mig.db');
    addTearDown(() async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    // 1. Fresh v16 database + a pre-existing row in an older table.
    final seed = AppDatabase.testing(NativeDatabase(file));
    await seed.into(seed.literatureBookmarks).insert(
          LiteratureBookmarksCompanion.insert(
            bookKey: 'bigbook',
            chapterKey: 'bb_ch5',
            chapterTitle: 'How It Works',
          ),
        );
    await seed.close();

    // 2. Rewind the file to a genuine v15 state.
    final rewind = AppDatabase.testing(NativeDatabase(file));
    await rewind.customStatement('DROP TABLE literature_annotations');
    await rewind.customStatement('PRAGMA user_version = 15');
    await rewind.close();

    // 3. Reopen → Drift runs onUpgrade(15, 16).
    final migrated = AppDatabase.testing(NativeDatabase(file));
    addTearDown(migrated.close);

    final version = await migrated
        .customSelect('PRAGMA user_version')
        .map((r) => r.read<int>('user_version'))
        .getSingle();
    expect(version, 16, reason: 'schema should be upgraded to v16');

    // Pre-existing data survived the upgrade.
    final bookmarks = await migrated.select(migrated.literatureBookmarks).get();
    expect(bookmarks, hasLength(1));
    expect(bookmarks.single.chapterTitle, 'How It Works');

    // The new table exists and is writable — only true if the migration ran.
    final id = await LiteratureAnnotationRepository(migrated).add(
      bookKey: 'bigbook',
      startPage: 1,
      endPage: 2,
      sectionTitle: 'How It Works',
      selectionStart: 0,
      selectionEnd: 5,
      selectedText: 'Rarel',
    );
    final annotations =
        await migrated.select(migrated.literatureAnnotations).get();
    expect(annotations, hasLength(1));
    expect(annotations.single.id, id);
    expect(annotations.single.selectedText, 'Rarel');
  });
}
