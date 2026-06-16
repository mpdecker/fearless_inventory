import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/defect_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('insert, findOrCreateByName, updateDefect, delete', () async {
    final t = await openTempEncryptedDb('fi_defect_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(defectRepositoryProvider);
    final now = DateTime.now();

    final id1 = await repo.insert(
      DefectsCompanion.insert(name: 'Pride', createdAt: now),
    );

    final id2 = await repo.findOrCreateByName('PRIDE ');
    expect(id2, id1);

    final id3 = await repo.findOrCreateByName('Fear');
    expect(id3, isNot(id1));

    final row = (await repo.watchAll().first).firstWhere((d) => d.id == id1);
    await repo.updateDefect(row.copyWith(isReady: true));

    expect(
      (await repo.watchAll().first).firstWhere((d) => d.id == id1).isReady,
      isTrue,
    );

    await repo.delete(id3);
    await repo.delete(id1);
    expect(await repo.watchAll().first, isEmpty);
  });
}
