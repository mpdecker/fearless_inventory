import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/resentment_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('insert, watch stream, update, delete', () async {
    final t = await openTempEncryptedDb('fi_resentment_repo_');
    addTearDown(() => disposeTempDb(
          db: t.db,
          dir: t.dir,
          dbFile: t.dbFile,
        ));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(resentmentRepositoryProvider);
    final now = DateTime.now();

    final id = await repo.insertResentment(
      ResentmentsCompanion.insert(
        person: 'Alice',
        cause: 'c',
        affects: 'a',
        myPart: 'm',
        createdAt: now,
      ),
    );

    expect(
      await repo.watchAllResentments().first,
      isA<List<Resentment>>()
          .having((l) => l.length, 'length', 1)
          .having((l) => l.single.person, 'person', 'Alice'),
    );

    final row = (await repo.watchAllResentments().first).single;
    await repo.updateResentment(row.copyWith(person: 'Bob'));

    expect((await repo.watchAllResentments().first).single.person, 'Bob');

    await repo.deleteResentment(id);
    expect(await repo.watchAllResentments().first, isEmpty);
  });
}
