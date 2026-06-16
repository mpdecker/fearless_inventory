import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/data/repositories/meditation_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('saveSession and getRecentReflectionKeys', () async {
    final t = await openTempEncryptedDb('fi_meditation_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(meditationRepositoryProvider);

    await repo.saveSession(
      sessionType: 'morning',
      reflectionTheme: 'courage',
      reflectionKey: 'key-a',
      durationSeconds: 120,
    );
    await repo.saveSession(
      sessionType: 'evening',
      reflectionTheme: 'acceptance',
      reflectionKey: 'key-b',
      durationSeconds: 60,
    );

    final recent = await repo.getRecentReflectionKeys(limit: 10);
    expect(recent.containsKey('key-a'), isTrue);
    expect(recent.containsKey('key-b'), isTrue);

    final week = await repo.getTotalSecondsThisWeek();
    expect(week, greaterThanOrEqualTo(180));
  });

  test('getThemeWeights is empty without review signals', () async {
    final t = await openTempEncryptedDb('fi_meditation_repo2_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final weights = await container.read(meditationRepositoryProvider).getThemeWeights();
    expect(weights, isEmpty);
  });
}
