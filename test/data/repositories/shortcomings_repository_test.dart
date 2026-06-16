import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/shortcomings_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('insert, watchByDefect, fetchStep4MyPartPhrases, delete', () async {
    final t = await openTempEncryptedDb('fi_shortcoming_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(shortcomingRepositoryProvider);
    final now = DateTime.now();

    await t.db.into(t.db.resentments).insert(
          ResentmentsCompanion.insert(
            person: 'p',
            cause: 'c',
            affects: 'a',
            myPart: '  my part phrase  ',
            createdAt: now,
          ),
        );

    final phrases = await repo.fetchStep4MyPartPhrases();
    expect(phrases, contains('my part phrase'));

    final defectId = await t.db.into(t.db.defects).insert(
          DefectsCompanion.insert(name: 'Selfish', createdAt: now),
        );

    final id = await repo.insert(
      ShortcomingLogsCompanion.insert(
        description: 'acted selfish',
        dateObserved: now,
        defectId: Value(defectId),
      ),
    );

    final byDefect = await repo.watchByDefect(defectId).first;
    expect(byDefect, hasLength(1));

    await repo.delete(id);
    expect(await repo.watchAll().first, isEmpty);
  });
}
