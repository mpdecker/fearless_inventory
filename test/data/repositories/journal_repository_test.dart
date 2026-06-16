import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/data/repositories/journal_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('insert, watchAll, watchByStep, getById, update, delete', () async {
    final t = await openTempEncryptedDb('fi_journal_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(journalRepositoryProvider);

    final id = await repo.insert(
      content: 'First thought',
      title: 'T1',
      stepNumber: 4,
    );

    expect((await repo.watchAll().first).single.content, 'First thought');
    expect((await repo.watchByStep(4).first), hasLength(1));
    expect((await repo.watchByStep(5).first), isEmpty);

    final row = await repo.getById(id);
    expect(row?.title, 'T1');

    await repo.update(
      id: id,
      content: 'Updated',
      title: 'T2',
      stepNumber: 5,
    );

    expect((await repo.getById(id))?.content, 'Updated');
    expect((await repo.watchByStep(5).first), hasLength(1));

    await repo.delete(id);
    expect(await repo.watchAll().first, isEmpty);
  });
}
