import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/amends_type.dart';

part 'database.g.dart';

// ─────────────────────────────────────────────
// TABLE DEFINITIONS
// ─────────────────────────────────────────────

class Resentments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get person => text().withLength(min: 1, max: 200)();
  TextColumn get cause => text()();
  TextColumn get affects => text()();
  TextColumn get myPart => text()();
  // Sponsor workflow fields (schema v2)
  TextColumn get sponsorNote => text().nullable()();
  BoolColumn get flagForReview =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class Fears extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get subject => text().withLength(min: 1, max: 200)();
  TextColumn get why => text()();
  TextColumn get myPart => text()();
  // Sponsor workflow fields (schema v2)
  TextColumn get sponsorNote => text().nullable()();
  BoolColumn get flagForReview =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class Harms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get person => text().withLength(min: 1, max: 200)();
  TextColumn get conduct => text()();
  TextColumn get myPart => text()();
  TextColumn get amendsPlan => text().nullable()();
  BoolColumn get isAmendsDone =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get dateAmendsDone => dateTime().nullable()();
  // Sponsor workflow fields (schema v2)
  TextColumn get sponsorNote => text().nullable()();
  BoolColumn get flagForReview =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class DailyReviews extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get wasResentful =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get wasSelfish => boolean().withDefault(const Constant(false))();
  BoolColumn get wasDishonest =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get wasAfraid => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get gratitude => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class Amends extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get harmId => integer()
      .nullable()
      .references(Harms, #id, onDelete: KeyAction.cascade)();
  TextColumn get person => text().withLength(min: 1, max: 200)();
  IntColumn get amendsType => intEnum<AmendsType>().nullable()();
  TextColumn get plan => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(2))();
  // Standardised status values: 'step8' | 'pending' | 'completed'
  TextColumn get status => text().withDefault(const Constant('step8'))();
  // v4: general timeframe label — 'asap' | 'days' | 'weeks' | 'months' | 'years'
  // Mutually exclusive with datePlanned: if timeframe is set, datePlanned is null.
  TextColumn get timeframe => text().nullable()();
  DateTimeColumn get datePlanned => dateTime().nullable()();
  DateTimeColumn get dateCompleted => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Defects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get category => text().nullable()();
  BoolColumn get isReady => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class ShortcomingLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  DateTimeColumn get dateObserved => dateTime()();
  IntColumn get relatedReviewId =>
      integer().nullable().references(DailyReviews, #id)();
  // v4: optional link back to a Step 6 character defect
  IntColumn get defectId =>
      integer().nullable().references(Defects, #id, onDelete: KeyAction.setNull)();
}

// ─────────────────────────────────────────────
// MEETINGS SCHEMA (v7)
// ─────────────────────────────────────────────

/// One meeting from any source (AA Meeting Guide, NA, etc.).
/// typeCodes is stored as a JSON-encoded list, e.g. '["O","BB"]'.
class Meetings extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// Stable adapter identifier — e.g. 'meeting-guide', 'na-api'
  TextColumn get sourceId => text()();
  /// Stable meeting ID from the upstream source (used for upsert dedup)
  TextColumn get externalId => text()();
  TextColumn get name => text()();
  TextColumn get fellowship => text().withDefault(const Constant('AA'))();
  TextColumn get locationName => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text()();
  TextColumn get state => text()();
  TextColumn get country => text().withDefault(const Constant('US'))();
  /// 0 = Sunday … 6 = Saturday
  IntColumn get weekday => integer()();
  /// Wall-clock start in "HH:mm" 24-h format
  TextColumn get startTime => text()();
  IntColumn get durationMinutes => integer().nullable()();
  /// JSON-encoded list of type codes: '["O","BB","ST"]'
  TextColumn get typeCodes => text().withDefault(const Constant('[]'))();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
  TextColumn get conferenceUrl => text().nullable()();
  TextColumn get conferencePhone => text().nullable()();
  /// 'zoom' | 'phone' | 'teams' | null
  TextColumn get onlinePlatform => text().nullable()();
  BoolColumn get isHybrid => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();
  BoolColumn get isHomeGroup => boolean().withDefault(const Constant(false))();
  BoolColumn get isTemporarilyClosed =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Prevent duplicate imports of the same meeting from the same source
  @override
  List<Set<Column>> get uniqueKeys => [
        {sourceId, externalId}
      ];
}

/// Records each time the user attended a meeting.
/// meetingName is denormalised — kept even if the meeting row is later deleted.
class AttendanceLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get meetingId => integer()
      .nullable()
      .references(Meetings, #id, onDelete: KeyAction.setNull)();
  /// Denormalized: preserve the name even after meeting deletion
  TextColumn get meetingName => text()();
  DateTimeColumn get attendedAt => dateTime()();
  TextColumn get notes => text().nullable()();
  BoolColumn get sharedAtMeeting =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get hasSponsorContact =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get hasServiceWork =>
      boolean().withDefault(const Constant(false))();
}

/// Per-source sync state (last sync time, error message, meeting count).
@DataClassName('SourceMeta')
class SyncMetas extends Table {
  /// Matches MeetingSourceAdapter.sourceId
  TextColumn get sourceId => text()();
  TextColumn get displayName => text()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  IntColumn get totalMeetings => integer().withDefault(const Constant(0))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {sourceId};
}

/// Records each completed meditation session (morning or evening Step 11).
/// Used for recency-based reflection weighting and meditation-time insights.
class MeditationSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  // 'morning' | 'evening'
  TextColumn get sessionType => text()();
  // Theme that was surfaced — e.g. 'acceptance', 'courage'
  TextColumn get reflectionTheme => text()();
  // First 80 chars of the quote, used as a stable fingerprint for recency
  TextColumn get reflectionKey => text()();
  // Seconds actually spent meditating (0 if user did not use the timer)
  IntColumn get durationSeconds =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime()();
}

// ─────────────────────────────────────────────
// SERVICE COMMITMENTS SCHEMA (v8)
// ─────────────────────────────────────────────

/// A single service commitment — a role, speaking engagement, or ongoing
/// piece of service work within AA / NA / OA.
class ServiceCommitments extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'position'  — home-group or intergroup role (GSR, Secretary, etc.)
  /// 'speaking'  — speaking or sharing commitment at a specific meeting
  /// 'general'   — any other service work
  TextColumn get type => text().withDefault(const Constant('general'))();

  /// Short description, e.g. "GSR", "Coffee Maker", "Speaker at Unity Group"
  TextColumn get title => text()();

  /// Group, intergroup, district, or event name.
  TextColumn get organization => text().nullable()();

  DateTimeColumn get startDate => dateTime()();

  /// null = open-ended / ongoing
  DateTimeColumn get endDate => dateTime().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // ── Recurring schedule ──────────────────────────────────────────────────
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  /// 0 = Sunday … 6 = Saturday; null when not recurring.
  IntColumn get recurringWeekday => integer().nullable()();

  /// Wall-clock time in "HH:mm" 24-h format; null when not recurring.
  TextColumn get recurringTime => text().nullable()();

  // ── Reminders ───────────────────────────────────────────────────────────
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Minutes before the commitment time to fire the reminder.
  IntColumn get reminderMinutesBefore => integer().nullable()();

  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

// ─────────────────────────────────────────────
// SPONSEE TRACKING SCHEMA (v9)
// ─────────────────────────────────────────────

/// A person being guided through the 12 steps by this user.
class Sponsees extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  /// The sponsee's own sobriety start date (for milestone tracking).
  DateTimeColumn get sobrietyDate => dateTime().nullable()();
  /// When this sponsoring relationship began.
  DateTimeColumn get startedSponsoringDate => dateTime().nullable()();
  /// Current active step (1–12), null if not yet started.
  IntColumn get currentStep => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Per-sponsee step-by-step progress (one row per step number per sponsee).
@DataClassName('SponseeStepEntry')
class SponseeStepProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sponseeId => integer()
      .references(Sponsees, #id, onDelete: KeyAction.cascade)();
  /// 1 through 12.
  IntColumn get stepNumber => integer()();
  /// 'not_started' | 'in_progress' | 'completed'
  TextColumn get status =>
      text().withDefault(const Constant('not_started'))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
}

/// A scheduled or completed check-in session with a sponsee.
class SponseeCheckIns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sponseeId => integer()
      .references(Sponsees, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// A single logged piece of 12th-step work — a call, visit, or sponsee
/// interaction that the user wants to record.
class TwelfthStepCalls extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'call'        — phone / text outreach
  /// 'visit'       — in-person 12th-step visit
  /// 'sponsorship' — sponsee-related interaction
  /// 'general'     — other 12th-step work
  TextColumn get callType => text().withDefault(const Constant('call'))();

  /// First name only (or null) — preserved for the user's own reference,
  /// never required.
  TextColumn get person => text().nullable()();

  /// Brief description of the work done.
  TextColumn get description => text()();

  /// What happened / how it went.
  TextColumn get outcome => text().nullable()();

  /// When the call took place (or is planned to take place).
  DateTimeColumn get occurredAt => dateTime()();

  /// Non-null = this is a future planned call (not yet completed).
  /// The calendar event is created at save-time; null = already logged.
  DateTimeColumn get scheduledAt => dateTime().nullable()();

  /// Optional link to a sponsee record.
  IntColumn get sponseeId => integer()
      .nullable()
      .references(Sponsees, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Step 12 calendar events — meetings, service commitments, sponsee check-ins.
class StepTwelveEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  // 'general' | 'meeting' | 'service' | 'sponsee'
  TextColumn get eventType =>
      text().withDefault(const Constant('general'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Records each time a Step 5 ceremony is completed.
/// Multiple completions are allowed (e.g. re-working the step).
class Step5Completions extends Table {
  IntColumn get id => integer().autoIncrement()();
  // The three admissions from the Big Book (pages 72–75)
  BoolColumn get admittedToSelf =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get admittedToHigherPower =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get admittedToSponsor =>
      boolean().withDefault(const Constant(false))();
  // Optional personal reflection written at completion
  TextColumn get reflection => text().nullable()();
  // Snapshot of inventory size at time of completion
  IntColumn get resentmentCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get fearCount => integer().withDefault(const Constant(0))();
  IntColumn get harmCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime()();
}

// ─────────────────────────────────────────────
// DATABASE CLASS
// ─────────────────────────────────────────────

@DriftDatabase(tables: [
  Resentments,
  Fears,
  Harms,
  DailyReviews,
  Amends,
  Defects,
  ShortcomingLogs,
  Step5Completions,
  MeditationSessions,
  StepTwelveEvents,
  // v7 — Meeting Finder
  Meetings,
  AttendanceLogs,
  SyncMetas,
  // v8 — Service Commitments
  ServiceCommitments,
  TwelfthStepCalls,
  // v9 — Sponsee Tracking
  Sponsees,
  SponseeStepProgress,
  SponseeCheckIns,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String encryptionKey) : super(_openConnection(encryptionKey));

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 → v2: sponsor workflow columns on Step 4 tables
          if (from < 2) {
            await m.addColumn(resentments, resentments.sponsorNote);
            await m.addColumn(resentments, resentments.flagForReview);
            await m.addColumn(fears, fears.sponsorNote);
            await m.addColumn(fears, fears.flagForReview);
            await m.addColumn(harms, harms.sponsorNote);
            await m.addColumn(harms, harms.flagForReview);
          }
          // v2 → v3: Step 5 ceremony completion records
          if (from < 3) {
            await m.createTable(step5Completions);
          }
          // v3 → v4: amends timeframe label + shortcoming-to-defect link
          if (from < 4) {
            await m.addColumn(amends, amends.timeframe);
            await m.addColumn(shortcomingLogs, shortcomingLogs.defectId);
          }
          // v4 → v5: meditation session tracking
          if (from < 5) {
            await m.createTable(meditationSessions);
          }
          // v5 → v6: Step 12 calendar events
          if (from < 6) {
            await m.createTable(stepTwelveEvents);
          }
          // v6 → v7: Meeting Finder — meetings, attendance, sync meta
          if (from < 7) {
            await m.createTable(meetings);
            await m.createTable(attendanceLogs);
            await m.createTable(syncMetas);
          }
          // v7 → v8: Service Commitments & 12th-step call log
          if (from < 8) {
            await m.createTable(serviceCommitments);
            await m.createTable(twelfthStepCalls);
          }
          // v8 → v9: Sponsee tracking + scheduled call fields
          if (from < 9) {
            await m.addColumn(twelfthStepCalls, twelfthStepCalls.scheduledAt);
            await m.createTable(sponsees);
            await m.addColumn(twelfthStepCalls, twelfthStepCalls.sponseeId);
            await m.createTable(sponseeStepProgress);
            await m.createTable(sponseeCheckIns);
          }
        },
      );

  // ── Convenience: destroy all local data (Privacy screen) ──────────────────
  Future<void> wipeAllData() => transaction(() async {
        // Delete in foreign-key-safe order
        await delete(amends).go();
        await delete(shortcomingLogs).go();
        await delete(harms).go();
        await delete(fears).go();
        await delete(resentments).go();
        await delete(defects).go();
        await delete(dailyReviews).go();
        await delete(stepTwelveEvents).go();
        await delete(attendanceLogs).go();
        await delete(meetings).go();
        await delete(syncMetas).go();
        await delete(serviceCommitments).go();
        await delete(twelfthStepCalls).go();
        await delete(sponseeCheckIns).go();
        await delete(sponseeStepProgress).go();
        await delete(sponsees).go();
      });
}

// ─────────────────────────────────────────────
// CONNECTION FACTORY
// ─────────────────────────────────────────────

QueryExecutor _openConnection(String encryptionKey) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fearless_inventory.db'));
    return NativeDatabase.createInBackground(file, setup: (db) {
      // Use the per-device key rather than a hard-coded value
      db.execute("PRAGMA key = '$encryptionKey';");
      db.execute('PRAGMA cipher = "sqlcipher";');
      db.execute('PRAGMA legacy = 4;');
    });
  });
}

// ─────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────

/// This provider is overridden in main.dart with the per-device encryption key
/// before the app widget tree is built.  Accessing it before that override is
/// in place will throw to surface the misconfiguration clearly.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw StateError(
    'databaseProvider was accessed before it was initialised. '
    'Ensure ProviderScope overrides the provider in main.dart.',
  );
});
