import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/service_commitments_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('commitments and twelfth-step calls', () async {
    final t = await openTempEncryptedDb('fi_service_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(serviceCommitmentsRepositoryProvider);
    final now = DateTime.now();

    final cid = await repo.insertCommitment(
      ServiceCommitmentsCompanion.insert(
        title: 'GSR',
        startDate: now,
      ),
    );

    expect((await repo.watchActive().first), hasLength(1));

    await repo.setActive(cid, value: false);
    expect((await repo.watchHistory().first), hasLength(1));

    final callId = await repo.insertCall(
      TwelfthStepCallsCompanion.insert(
        description: 'Reached out',
        occurredAt: now,
        scheduledAt: Value(now.add(const Duration(days: 1))),
      ),
    );

    final scheduled = await repo.watchScheduledCalls().first;
    expect(scheduled, isNotEmpty);

    await repo.completeScheduledCall(callId);
    final past = await repo.watchPastCalls().first;
    expect(past.any((c) => c.id == callId), isTrue);

    await repo.deleteCall(callId);
    await repo.deleteCommitment(cid);
    expect(await repo.watchAll().first, isEmpty);
  });
}
