import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../features/meetings/adapters/meeting_source_adapter.dart';

final meetingsRepositoryProvider = Provider<MeetingsRepository>((ref) {
  return MeetingsRepository(ref.watch(databaseProvider));
});

class MeetingsRepository {
  final AppDatabase _db;
  MeetingsRepository(this._db);

  // ── Meetings ──────────────────────────────────────────────────────────────

  /// All meetings ordered by weekday then start time.
  Stream<List<Meeting>> watchAll() => (_db.select(_db.meetings)
        ..orderBy([
          (t) => OrderingTerm.asc(t.weekday),
          (t) => OrderingTerm.asc(t.startTime),
        ]))
      .watch();

  /// Only bookmarked meetings.
  Stream<List<Meeting>> watchBookmarked() => (_db.select(_db.meetings)
        ..where((t) => t.isBookmarked.equals(true))
        ..orderBy([
          (t) => OrderingTerm.asc(t.weekday),
          (t) => OrderingTerm.asc(t.startTime),
        ]))
      .watch();

  /// Toggle bookmarked state.  If [asHomeGroup] is true the home-group flag
  /// mirrors the new bookmarked value.
  Future<void> toggleBookmark(Meeting m, {bool asHomeGroup = false}) async {
    final nowBookmarked = !m.isBookmarked;
    await (_db.update(_db.meetings)..where((t) => t.id.equals(m.id))).write(
      MeetingsCompanion(
        isBookmarked: Value(nowBookmarked),
        isHomeGroup: asHomeGroup ? Value(nowBookmarked) : const Value.absent(),
      ),
    );
  }

  /// Explicitly set the home-group flag (independent of bookmark state).
  Future<void> setHomeGroup(int meetingId, {required bool value}) async {
    await (_db.update(_db.meetings)..where((t) => t.id.equals(meetingId)))
        .write(MeetingsCompanion(isHomeGroup: Value(value)));
  }

  /// All meetings the user has marked for planned attendance.
  /// Ordered by weekday then start time so the Step 12 calendar can
  /// expand them into recurring events across the displayed month.
  Stream<List<Meeting>> watchPlannedMeetings() =>
      (_db.select(_db.meetings)
            ..where((t) => t.isPlannedAttendance.equals(true))
            ..orderBy([
              (t) => OrderingTerm.asc(t.weekday),
              (t) => OrderingTerm.asc(t.startTime),
            ]))
          .watch();

  /// Toggle planned-attendance flag for a single meeting.
  Future<void> togglePlannedAttendance(Meeting m) async {
    await (_db.update(_db.meetings)..where((t) => t.id.equals(m.id))).write(
      MeetingsCompanion(
        isPlannedAttendance: Value(!m.isPlannedAttendance),
      ),
    );
  }

  /// Explicitly set the planned-attendance flag (independent of current value).
  Future<void> setPlannedAttendance(int meetingId,
      {required bool value}) async {
    await (_db.update(_db.meetings)..where((t) => t.id.equals(meetingId)))
        .write(MeetingsCompanion(isPlannedAttendance: Value(value)));
  }

  /// Upsert a batch of DTOs from one adapter.
  /// Returns (added, updated) counts.
  Future<(int, int)> upsertMeetings(
    String sourceId,
    List<MeetingDto> dtos,
  ) async {
    int added = 0;
    int updated = 0;

    await _db.transaction(() async {
      for (final dto in dtos) {
        final companion = _dtoToCompanion(sourceId, dto);

        // Try to find existing row by (sourceId, externalId)
        final existing = await (_db.select(_db.meetings)
              ..where((t) =>
                  t.sourceId.equals(sourceId) &
                  t.externalId.equals(dto.externalId)))
            .getSingleOrNull();

        if (existing == null) {
          await _db.into(_db.meetings).insert(companion);
          added++;
        } else {
          await (_db.update(_db.meetings)
                ..where((t) => t.id.equals(existing.id)))
              .write(companion);
          updated++;
        }
      }
    });

    return (added, updated);
  }

  MeetingsCompanion _dtoToCompanion(String sourceId, MeetingDto dto) {
    // Detect Zoom from conference URL
    String? platform = dto.onlinePlatform;
    if (platform == null && dto.conferenceUrl != null) {
      if (dto.conferenceUrl!.contains('zoom.us')) platform = 'zoom';
    }

    return MeetingsCompanion(
      sourceId: Value(sourceId),
      externalId: Value(dto.externalId),
      name: Value(dto.name),
      fellowship: Value(dto.fellowship),
      locationName: Value(dto.locationName),
      latitude: Value(dto.latitude),
      longitude: Value(dto.longitude),
      address: Value(dto.address),
      city: Value(dto.city),
      state: Value(dto.state),
      country: Value(dto.country),
      weekday: Value(dto.weekday),
      startTime: Value(dto.startTime),
      durationMinutes: Value(dto.durationMinutes),
      typeCodes: Value(jsonEncode(dto.typeCodes)),
      isOnline: Value(dto.isOnline),
      isHybrid: Value(dto.isHybrid),
      conferenceUrl: Value(dto.conferenceUrl),
      conferencePhone: Value(dto.conferencePhone),
      onlinePlatform: Value(platform),
      notes: Value(dto.notes),
      language: Value(dto.language),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  // ── Attendance ────────────────────────────────────────────────────────────

  /// All attendance logs, newest first.
  Stream<List<AttendanceLog>> watchAttendance() =>
      (_db.select(_db.attendanceLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.attendedAt)]))
          .watch();

  /// Attendance logs from the last [days] days.
  Stream<List<AttendanceLog>> watchRecentAttendance({int days = 30}) {
    final since = DateTime.now().subtract(Duration(days: days));
    return (_db.select(_db.attendanceLogs)
          ..where((t) => t.attendedAt.isBiggerOrEqualValue(since))
          ..orderBy([(t) => OrderingTerm.desc(t.attendedAt)]))
        .watch();
  }

  /// Total number of meetings attended (for insights).
  Stream<int> watchAttendanceCount() =>
      _db.attendanceLogs.count().watchSingle();

  Future<void> logAttendance(AttendanceLogsCompanion entry) =>
      _db.into(_db.attendanceLogs).insert(entry);

  Future<void> deleteAttendance(int id) =>
      (_db.delete(_db.attendanceLogs)..where((t) => t.id.equals(id))).go();

  // ── Source meta ───────────────────────────────────────────────────────────

  Future<SourceMeta?> getSourceMeta(String sourceId) =>
      (_db.select(_db.syncMetas)
            ..where((t) => t.sourceId.equals(sourceId)))
          .getSingleOrNull();

  Future<void> saveSourceMeta(SyncMetasCompanion companion) =>
      _db.into(_db.syncMetas).insertOnConflictUpdate(companion);

  Future<void> recordSyncError(
      String sourceId, String displayName, String error) =>
      _db.into(_db.syncMetas).insertOnConflictUpdate(SyncMetasCompanion(
            sourceId: Value(sourceId),
            displayName: Value(displayName),
            syncError: Value(error),
          ));
}
