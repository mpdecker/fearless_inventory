import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/inventory_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('watchResentments, watchFears, watchHarms mirror table streams',
      () async {
    final t = await openTempEncryptedDb('fi_inventory_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(inventoryRepositoryProvider);
    final now = DateTime.now();

    await t.db.into(t.db.resentments).insert(
          ResentmentsCompanion.insert(
            person: 'R',
            cause: 'c',
            affects: 'a',
            myPart: 'm',
            createdAt: now,
          ),
        );
    await t.db.into(t.db.fears).insert(
          FearsCompanion.insert(
            subject: 'F',
            why: 'w',
            myPart: 'm',
            createdAt: now,
          ),
        );
    await t.db.into(t.db.harms).insert(
          HarmsCompanion.insert(
            person: 'H',
            conduct: 'c',
            myPart: 'm',
            createdAt: now,
          ),
        );

    expect((await repo.watchResentments().first).single.person, 'R');
    expect((await repo.watchFears().first).single.subject, 'F');
    expect((await repo.watchHarms().first).single.person, 'H');
  });
}
