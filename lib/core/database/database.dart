import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/amends_type.dart';
import '../services/key_service.dart';

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
  // v15 — which context this review was logged in: 'morning' | 'spot_check' | 'nightly'
  TextColumn get reviewType =>
      text().withDefault(const Constant('nightly'))();
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
  /// When true, this meeting appears on the Step 12 calendar every week
  /// on its [weekday].  Added in schema v12.
  BoolColumn get isPlannedAttendance =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isTemporarilyClosed =>
      boolean().withDefault(const Constant(false))();
  /// BCP-47 language code: 'en', 'es', 'fr', etc.  Default 'en' (English).
  /// Added in schema v10.
  TextColumn get language => text().withDefault(const Constant('en'))();
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
// JOURNAL SCHEMA (v11)
// ─────────────────────────────────────────────

/// A personal journal entry associated with a specific step (1–12)
/// or tradition (1–12).  Exactly one of [stepNumber] / [traditionNumber]
/// should be non-null for categorised entries; both may be null for
/// a free-form entry written outside a specific step/tradition context.
///
/// Bot-readiness: [promptId] is intentionally nullable.  When the AI
/// recovery-bot feature ships, it will populate this column with a stable
/// prompt identifier so entries can be traced back to the prompt that
/// inspired them.  [tags] and [mood] are similarly reserved for future
/// enrichment without requiring another migration.
class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The user's written reflection.  Required — never empty.
  TextColumn get content => text()();

  /// Optional user-supplied headline for the entry.
  TextColumn get title => text().nullable()();

  /// Which step (1–12) this entry is associated with.
  /// Null when the entry is tradition-related or uncategorised.
  IntColumn get stepNumber => integer().nullable()();

  /// Which tradition (1–12) this entry is associated with.
  /// Null when the entry is step-related or uncategorised.
  IntColumn get traditionNumber => integer().nullable()();

  /// Future: stable ID of the contemplative prompt that inspired this entry.
  /// Populated by the AI recovery-bot feature; null for self-initiated entries.
  TextColumn get promptId => text().nullable()();

  /// Future: comma-separated user tags, e.g. "gratitude,fear,hope".
  TextColumn get tags => text().nullable()();

  /// Future: emotional tone at write-time — e.g. "hopeful" | "struggling".
  TextColumn get mood => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

// ─────────────────────────────────────────────
// ROLODEX SCHEMA (v14)
// ─────────────────────────────────────────────

/// A person the user knows from the rooms — potential sponsor, sponsee, or
/// just a fellow contact.
///
/// [isSponsor] — at most one row should have this true at a time; the
/// RolodexRepository enforces that invariant on write.
/// [sponseeId] — set when this contact has been promoted to a Sponsee entry.
/// [meetingId] — the meeting where this person was met (nullable).
class RolodexContacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();

  /// Meeting where this person was met (nullable; SET NULL on meeting delete).
  IntColumn get meetingId => integer()
      .nullable()
      .references(Meetings, #id, onDelete: KeyAction.setNull)();

  /// True when this contact is the user's current sponsor.
  /// Only one row should be true at a time — enforced by [RolodexRepository].
  BoolColumn get isSponsor =>
      boolean().withDefault(const Constant(false))();

  /// Set when this contact has been converted to a Sponsee entry.
  /// SET NULL if the linked Sponsee row is deleted.
  IntColumn get sponseeId => integer()
      .nullable()
      .references(Sponsees, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

// ─────────────────────────────────────────────
// SPONSOR CALL LOG SCHEMA (v13)
// ─────────────────────────────────────────────

/// Records each confirmed sponsor call — triggered from a scheduled reminder
/// or logged manually by the user at any time.
class SponsorCallLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The datetime the reminder notification was scheduled to fire.
  /// null when the call was logged manually outside a reminder cycle.
  DateTimeColumn get scheduledFor => dateTime().nullable()();

  /// When the user confirmed the call happened.
  DateTimeColumn get confirmedAt => dateTime()();

  /// True if the user tapped the in-app "Call Now" button; false = "Already
  /// called" self-report.
  BoolColumn get calledViaApp =>
      boolean().withDefault(const Constant(false))();

  TextColumn get notes => text().nullable()();
}

// ─────────────────────────────────────────────
// LITERATURE BOOKMARKS SCHEMA (v12)
// ─────────────────────────────────────────────

/// A user-saved bookmark within the Big Book or 12 & 12.
/// The [bookKey] is a stable identifier such as 'bigbook' or 'twelve_twelve'.
/// The [chapterKey] is a stable chapter identifier such as 'bb_ch5'.
@DataClassName('LiteratureBookmark')
class LiteratureBookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'bigbook' | 'twelve_twelve'
  TextColumn get bookKey => text()();

  /// Stable chapter identifier, e.g. 'bb_ch5', 'tt_step7'.
  TextColumn get chapterKey => text()();

  /// Human-readable chapter title, e.g. "How It Works".
  TextColumn get chapterTitle => text()();

  /// Optional personal note about why this chapter was bookmarked.
  TextColumn get note => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {bookKey, chapterKey}
      ];
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
  // v11 — Journal
  JournalEntries,
  // v12 — Literature bookmarks
  LiteratureBookmarks,
  // v13 — Sponsor call log
  SponsorCallLogs,
  // v14 — Rolodex contacts
  RolodexContacts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String encryptionKey) : super(_openConnection(encryptionKey));
  AppDatabase.testing(QueryExecutor executor) : super(executor);

  /// Same schema and encryption as production, backed by [databaseFile] (e.g. a
  /// temp file in tests).
  AppDatabase.forTesting(File databaseFile, String encryptionKey)
      : super(_openConnectionAt(databaseFile, encryptionKey));

  @override
  int get schemaVersion => 15;

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
          // v9 → v10: language field on meetings; default 'en' for existing rows
          if (from < 10) {
            await m.addColumn(meetings, meetings.language);
          }
          // v10 → v11: Journal entries for step/tradition reflection
          if (from < 11) {
            await m.createTable(journalEntries);
          }
          // v11 → v12: Planned meeting attendance + literature bookmarks
          if (from < 12) {
            await m.addColumn(meetings, meetings.isPlannedAttendance);
            await m.createTable(literatureBookmarks);
          }
          // v12 → v13: Sponsor call log
          if (from < 13) {
            await m.createTable(sponsorCallLogs);
          }
          // v13 → v14: Rolodex contacts
          if (from < 14) {
            await m.createTable(rolodexContacts);
          }
          // v14 → v15: review type context on daily reviews
          if (from < 15) {
            await m.addColumn(dailyReviews, dailyReviews.reviewType);
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
        await delete(step5Completions).go();
        await delete(meditationSessions).go();
        await delete(stepTwelveEvents).go();
        await delete(attendanceLogs).go();
        await delete(meetings).go();
        await delete(syncMetas).go();
        await delete(serviceCommitments).go();
        await delete(twelfthStepCalls).go();
        await delete(sponseeCheckIns).go();
        await delete(sponseeStepProgress).go();
        await delete(sponsees).go();
        await delete(journalEntries).go();
        await delete(literatureBookmarks).go();
        await delete(sponsorCallLogs).go();
        await delete(rolodexContacts).go();
      });
}

// ─────────────────────────────────────────────
// CONNECTION FACTORY
// ─────────────────────────────────────────────

void _configureEncryptedConnection(Database db, String encryptionKey) {
  // SQLite3MultipleCiphers (bundled via pubspec `hooks` → sqlite3: source: sqlite3mc).
  // SQLCipher-compatible settings for existing installs that used PRAGMA key + legacy.
  db.execute("PRAGMA key = '$encryptionKey';");
  db.execute('PRAGMA cipher = "sqlcipher";');
  db.execute('PRAGMA legacy = 4;');
  db.execute('PRAGMA foreign_keys = ON;');
}

QueryExecutor _openConnectionAt(File file, String encryptionKey) {
  return LazyDatabase(() async {
    return NativeDatabase.createInBackground(
      file,
      setup: (db) => _configureEncryptedConnection(db, encryptionKey),
    );
  });
}

QueryExecutor _openConnection(String encryptionKey) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(
      p.join(dbFolder.path, KeyService.productionDatabaseFileName),
    );
    return NativeDatabase.createInBackground(
      file,
      setup: (db) => _configureEncryptedConnection(db, encryptionKey),
    );
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
