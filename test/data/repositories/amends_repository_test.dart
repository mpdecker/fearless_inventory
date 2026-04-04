import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/models/amends_type.dart';
import 'package:fearless_inventory/data/repositories/amends_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('insert, watchByStatus, update, toggleCompleted, delete', () async {
    final t = await openTempEncryptedDb('fi_amends_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(amendsRepositoryProvider);

    final id = await repo.insert(
      AmendsCompanion.insert(
        person: 'Alex',
        amendsType: const Value(AmendsType.personal),
      ),
    );

    final step8 = await repo.watchByStatus('step8').first;
    final pending = await repo.watchByStatus('pending').first;
    expect(step8, hasLength(1));
    expect(step8.single.person, 'Alex');
    expect(pending, isEmpty);

    final row = step8.single;
    await repo.update(row.copyWith(person: 'Alex B.'));

    expect((await repo.watchAll().first).single.person, 'Alex B.');

    await repo.toggleCompleted(id, true);
    expect((await repo.watchByStatus('completed').first), hasLength(1));

    await repo.delete(id);
    expect(await repo.watchAll().first, isEmpty);
  });
}
