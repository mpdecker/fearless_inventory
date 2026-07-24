import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/data/repositories/literature_annotation_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('add, watchForSection, setNote, setColor, delete', () async {
    final t = await openTempEncryptedDb('fi_lit_anno_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(literatureAnnotationRepositoryProvider);

    // Empty to start.
    expect(
      await repo
          .watchForSection(bookKey: 'bigbook', startPage: 58, endPage: 60)
          .first,
      isEmpty,
    );

    // Create a highlight (no note) and a note in the same section.
    final id1 = await repo.add(
      bookKey: 'bigbook',
      startPage: 58,
      endPage: 60,
      sectionTitle: 'How It Works',
      selectionStart: 120,
      selectionEnd: 140,
      selectedText: 'Rarely have we seen',
    );
    await repo.add(
      bookKey: 'bigbook',
      startPage: 58,
      endPage: 60,
      sectionTitle: 'How It Works',
      selectionStart: 10,
      selectionEnd: 30,
      selectedText: 'a person fail',
      color: 'green',
      note: 'core promise',
    );

    // Ordered by position in the text (selectionStart asc).
    final section = await repo
        .watchForSection(bookKey: 'bigbook', startPage: 58, endPage: 60)
        .first;
    expect(section, hasLength(2));
    expect(section.first.selectionStart, 10);
    expect(section.first.note, 'core promise');
    expect(section.first.color, 'green');
    expect(section.last.note, isNull);
    expect(section.last.color, 'yellow'); // default

    // A different section is isolated.
    expect(
      await repo
          .watchForSection(bookKey: 'bigbook', startPage: 1, endPage: 5)
          .first,
      isEmpty,
    );

    // Attach a note and change colour on the first highlight.
    await repo.setNote(id1, '  remember this  ');
    await repo.setColor(id1, 'blue');
    final updated = (await repo
            .watchForSection(bookKey: 'bigbook', startPage: 58, endPage: 60)
            .first)
        .firstWhere((a) => a.id == id1);
    expect(updated.note, 'remember this'); // trimmed
    expect(updated.color, 'blue');

    // Clearing a note (empty string) nulls it.
    await repo.setNote(id1, '   ');
    final cleared = (await repo
            .watchForSection(bookKey: 'bigbook', startPage: 58, endPage: 60)
            .first)
        .firstWhere((a) => a.id == id1);
    expect(cleared.note, isNull);

    // Delete removes just that row.
    await repo.delete(id1);
    final remaining = await repo
        .watchForSection(bookKey: 'bigbook', startPage: 58, endPage: 60)
        .first;
    expect(remaining, hasLength(1));
    expect(remaining.single.selectedText, 'a person fail');

    // watchForBook / watchAll see the survivor.
    expect(await repo.watchForBook('bigbook').first, hasLength(1));
    expect(await repo.watchAll().first, hasLength(1));
  });
}
