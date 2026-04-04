import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/data/repositories/step5_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('recordCompletion, watchAll, latestCompletion', () async {
    final t = await openTempEncryptedDb('fi_step5_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(step5RepositoryProvider);

    await repo.recordCompletion(
      admittedToSelf: true,
      admittedToHigherPower: true,
      admittedToSponsor: false,
      reflection: 'ok',
      resentmentCount: 3,
      fearCount: 2,
      harmCount: 1,
    );

    final latest = await repo.latestCompletion();
    expect(latest, isNotNull);
    expect(latest!.resentmentCount, 3);
    expect(latest.reflection, 'ok');

    final all = await repo.watchAll().first;
    expect(all, hasLength(1));
  });
}
