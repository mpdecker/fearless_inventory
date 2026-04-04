import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/step12_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('insert, watchAll, watchMonth, update, delete', () async {
    final t = await openTempEncryptedDb('fi_step12_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(step12RepositoryProvider);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 10);

    final id = await repo.insert(
      StepTwelveEventsCompanion.insert(
        title: 'Service',
        startTime: start,
      ),
    );

    final all = await repo.watchAll().first;
    expect(all, hasLength(1));

    final month = DateTime(now.year, now.month);
    final inMonth = await repo.watchMonth(month).first;
    expect(inMonth, hasLength(1));

    await repo.update(all.single.copyWith(title: 'Updated'));
    expect((await repo.watchAll().first).single.title, 'Updated');

    await repo.delete(id);
    expect(await repo.watchAll().first, isEmpty);
  });
}
