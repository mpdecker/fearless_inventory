import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/fear_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('insert, watch, update, delete', () async {
    final t = await openTempEncryptedDb('fi_fear_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(fearRepositoryProvider);
    final now = DateTime.now();

    final id = await repo.insertFear(
      FearsCompanion.insert(
        subject: 'Spiders',
        why: 'w',
        myPart: 'm',
        createdAt: now,
      ),
    );

    expect((await repo.watchAllFears().first).single.subject, 'Spiders');

    final row = (await repo.watchAllFears().first).single;
    await repo.updateFear(row.copyWith(subject: 'Heights'));

    expect((await repo.watchAllFears().first).single.subject, 'Heights');

    await repo.deleteFear(id);
    expect(await repo.watchAllFears().first, isEmpty);
  });
}
