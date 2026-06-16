import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/data/repositories/literature_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bookmark, isBookmarked, watchForBook, removeBookmark', () async {
    final t = await openTempEncryptedDb('fi_lit_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(literatureRepositoryProvider);

    expect(
      await repo.isBookmarked(bookKey: 'bigbook', chapterKey: 'bb_ch1'),
      isFalse,
    );

    await repo.bookmark(
      bookKey: 'bigbook',
      chapterKey: 'bb_ch1',
      chapterTitle: "Bill's Story",
      note: 'n',
    );

    expect(
      await repo.isBookmarked(bookKey: 'bigbook', chapterKey: 'bb_ch1'),
      isTrue,
    );

    final bb = await repo.watchForBook('bigbook').first;
    expect(bb, hasLength(1));
    expect(bb.single.chapterTitle, "Bill's Story");

    await repo.removeBookmark(bookKey: 'bigbook', chapterKey: 'bb_ch1');
    expect(await repo.watchAll().first, isEmpty);
  });
}
