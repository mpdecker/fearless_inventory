import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/harm_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('insert, watch, update, delete', () async {
    final t = await openTempEncryptedDb('fi_harm_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(harmRepositoryProvider);
    final now = DateTime.now();

    final id = await repo.insertHarm(
      HarmsCompanion.insert(
        person: 'Pat',
        conduct: 'c',
        myPart: 'm',
        createdAt: now,
      ),
    );

    expect((await repo.watchAllHarms().first).single.person, 'Pat');

    final row = (await repo.watchAllHarms().first).single;
    await repo.updateHarm(row.copyWith(person: 'Jordan'));

    expect((await repo.watchAllHarms().first).single.person, 'Jordan');

    await repo.deleteHarm(id);
    expect(await repo.watchAllHarms().first, isEmpty);
  });
}
