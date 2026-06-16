import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/sponsee_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sponsee CRUD, step progress, check-in', () async {
    final t = await openTempEncryptedDb('fi_sponsee_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(sponseeRepositoryProvider);
    final now = DateTime.now();

    final sid = await repo.insertSponsee(SponseesCompanion.insert(name: 'Chris'));

    expect((await repo.watchAll().first).single.name, 'Chris');

    await repo.setActive(sid, value: false);
    expect((await repo.watchActive().first), isEmpty);

    await repo.setActive(sid, value: true);
    await repo.setCurrentStep(sid, 4);

    await repo.updateStepStatus(sid, 4, 'in_progress');
    await repo.updateStepStatus(sid, 4, 'completed', completedAt: now);

    final steps = await repo.watchStepProgress(sid).first;
    expect(steps, hasLength(1));
    expect(steps.single.status, 'completed');

    final cid = await repo.insertCheckIn(
      SponseeCheckInsCompanion.insert(
        sponseeId: sid,
        scheduledAt: now.add(const Duration(days: 1)),
      ),
    );

    expect((await repo.watchCheckIns(sid).first), hasLength(1));

    await repo.completeCheckIn(cid, notes: 'done');
    final after = (await repo.watchCheckIns(sid).first).single;
    expect(after.completedAt, isNotNull);

    await repo.deleteCheckIn(cid);
    await repo.deleteSponsee(sid);
    expect(await repo.watchAll().first, isEmpty);
  });
}
