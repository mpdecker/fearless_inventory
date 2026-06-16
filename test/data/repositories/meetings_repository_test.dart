import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/features/meetings/adapters/meeting_source_adapter.dart';
import 'package:fearless_inventory/data/repositories/meetings_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('upsertMeetings, watchAll, toggleBookmark, attendance, source meta',
      () async {
    final t = await openTempEncryptedDb('fi_meetings_repo_');
    addTearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    final container = containerWithDatabase(t.db);
    addTearDown(container.dispose);

    final repo = container.read(meetingsRepositoryProvider);

    final dto = MeetingDto(
      externalId: 'm1',
      name: 'Unity Group',
      city: 'Boston',
      state: 'MA',
      weekday: 3,
      startTime: '19:30',
    );

    final counts = await repo.upsertMeetings('test-src', [dto]);
    expect(counts.$1, 1);
    expect(counts.$2, 0);

    final list = await repo.watchAll().first;
    expect(list, hasLength(1));
    final m = list.single;
    expect(m.name, 'Unity Group');
    expect(m.isBookmarked, isFalse);

    await repo.toggleBookmark(m);
    final bookmarked = await repo.watchBookmarked().first;
    expect(bookmarked, hasLength(1));

    final now = DateTime.now();
    await repo.logAttendance(
      AttendanceLogsCompanion.insert(
        meetingId: Value(m.id),
        meetingName: m.name,
        attendedAt: now,
      ),
    );

    final logs = await repo.watchAttendance().first;
    expect(logs, hasLength(1));

    await repo.saveSourceMeta(
      SyncMetasCompanion.insert(
        sourceId: 'test-src',
        displayName: 'Test',
      ),
    );

    final meta = await repo.getSourceMeta('test-src');
    expect(meta?.displayName, 'Test');
  });
}
