import 'package:drift/drift.dart' show Value;

import '../database/database.dart';
import '../models/amends_type.dart';
import 'sobriety_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SeedDataService
//
// Populates a fresh (or wiped) database with realistic demo data so that every
// screen and insight card can be shown during a live demonstration.
//
// Narrative: the user ("Alex") has 18 months of sobriety, has completed Steps
// 1–5 and is working Steps 6–9 (defects, amends).  Alex sponsors two people
// and is active in service at their Home Group.
// ─────────────────────────────────────────────────────────────────────────────

class SeedDataService {
  final AppDatabase _db;
  SeedDataService(this._db);

  // ── Sample sponsor-review JSON ─────────────────────────────────────────────
  // Jordan M.'s Step 4 inventory export — paste this into the Review Import
  // sheet on the Sponsees tab to demo the sponsor review wizard.
  static const String sampleSponsorReviewJson = '''
{
  "appVersion": "1.0",
  "exportedAt": "2026-04-05",
  "resentments": [
    {
      "person": "Dad",
      "cause": "He was never around. Worked every weekend. Missed every school event.",
      "affects": "self_esteem,security,personal_relations",
      "myPart": "I never told him how I felt. I acted out to get his attention instead.",
      "flagForReview": true
    },
    {
      "person": "Coach Williams",
      "cause": "Cut me from the team junior year. Told me I'd never make it.",
      "affects": "self_esteem,ambitions,pride",
      "myPart": "I had been skipping practice. I expected to be treated differently than I'd earned.",
      "flagForReview": false
    },
    {
      "person": "Older brother (Derek)",
      "cause": "Always the favorite. Mom defended him even when he was wrong.",
      "affects": "self_esteem,personal_relations,security",
      "myPart": "I competed instead of connected. I resented him for what I wanted, not what he did.",
      "flagForReview": true
    }
  ],
  "fears": [
    {
      "subject": "Not being smart enough",
      "why": "Struggled in school. Teachers made comments. Always felt behind everyone else.",
      "myPart": "I never asked for help. Pride kept me from admitting I needed support.",
      "flagForReview": false
    },
    {
      "subject": "Repeating my dad's pattern",
      "why": "Fear that I'll become absent or emotionally unavailable like he was.",
      "myPart": "I have already pulled away from people when things get hard. The pattern is already there.",
      "flagForReview": true
    }
  ],
  "harms": [
    {
      "person": "Girlfriend (Kara)",
      "conduct": "Lied about drinking for six months. Disappeared for weekends without explanation.",
      "myPart": "I chose the bottle every time I had to choose. She got the leftover version of me.",
      "flagForReview": true
    },
    {
      "person": "Mom",
      "conduct": "Said things during arguments I cannot take back. Broke her trust repeatedly.",
      "myPart": "I weaponized her love. She was a safe target because she always stayed.",
      "flagForReview": false
    }
  ]
}''';

  Future<void> seed() async {
    // Wipe first so re-running the action is idempotent.
    await _db.wipeAllData();

    final today = DateTime.now();
    DateTime ago(int days, {int hour = 20, int minute = 0}) => DateTime(
          today.year,
          today.month,
          today.day - days,
          hour,
          minute,
        );

    // ── 1. Sobriety date — 548 days (18 months) ago ──────────────────────────
    await SobrietyService.setSobrietyDate(today.subtract(const Duration(days: 548)));

    // ── 2. Sync meta — meeting sources ───────────────────────────────────────
    await _db.into(_db.syncMetas).insertOnConflictUpdate(SyncMetasCompanion.insert(
      sourceId:     'meeting-guide',
      displayName:  'AA Meeting Guide',
      lastSyncAt:   Value(ago(1)),
      totalMeetings: const Value(842),
    ));
    await _db.into(_db.syncMetas).insertOnConflictUpdate(SyncMetasCompanion.insert(
      sourceId:     'na-api',
      displayName:  'NA Meeting Finder',
      lastSyncAt:   Value(ago(1)),
      totalMeetings: const Value(213),
    ));

    // ── 3. Meetings ───────────────────────────────────────────────────────────
    final homeGroupId = await _db.into(_db.meetings).insert(
      MeetingsCompanion.insert(
        sourceId:        'meeting-guide',
        externalId:      'hg-001',
        name:            'Tuesday Night Home Group',
        locationName:    const Value('St. Michael\'s Parish Hall'),
        address:         const Value('211 Oak Street'),
        city:            'Springfield',
        state:           'IL',
        weekday:         2, // Tuesday
        startTime:       '19:00',
        durationMinutes: const Value(60),
        typeCodes:       const Value('["O","BB"]'),
        isBookmarked:    const Value(true),
        isHomeGroup:     const Value(true),
        isPlannedAttendance: const Value(true),
        latitude:        const Value(39.7817),
        longitude:       const Value(-89.6501),
      ),
    );

    final speakerMeetingId = await _db.into(_db.meetings).insert(
      MeetingsCompanion.insert(
        sourceId:        'meeting-guide',
        externalId:      'sm-002',
        name:            'Friday Night Speaker Meeting',
        locationName:    const Value('Alano Club'),
        address:         const Value('400 S. Fifth St'),
        city:            'Springfield',
        state:           'IL',
        weekday:         5, // Friday
        startTime:       '20:00',
        durationMinutes: const Value(75),
        typeCodes:       const Value('["O","SP"]'),
        isBookmarked:    const Value(true),
        latitude:        const Value(39.7990),
        longitude:       const Value(-89.6440),
      ),
    );

    await _db.into(_db.meetings).insert(
      MeetingsCompanion.insert(
        sourceId:    'meeting-guide',
        externalId:  'bb-003',
        name:        'Wednesday Big Book Study',
        city:        'Springfield',
        state:       'IL',
        weekday:     3, // Wednesday
        startTime:   '12:00',
        durationMinutes: const Value(60),
        typeCodes:   const Value('["C","BB","ST"]'),
      ),
    );

    await _db.into(_db.meetings).insert(
      MeetingsCompanion.insert(
        sourceId:        'meeting-guide',
        externalId:      'on-004',
        name:            'Daily 6 AM Online Meeting',
        city:            'Online',
        state:           'IL',
        weekday:         0, // Sunday (repeating)
        startTime:       '06:00',
        isOnline:        const Value(true),
        conferenceUrl:   const Value('https://zoom.us/j/123456789'),
        onlinePlatform:  const Value('zoom'),
        typeCodes:       const Value('["O"]'),
      ),
    );

    // ── 4. Attendance logs — 18 meetings in the past 30 days ─────────────────
    final attendanceDays = [0, 2, 4, 7, 9, 11, 14, 16, 18, 21, 23, 25, 27, 29, 2, 5, 10, 17];
    for (var i = 0; i < attendanceDays.length; i++) {
      final d = attendanceDays[i];
      final meetingId = i % 3 == 0 ? speakerMeetingId : homeGroupId;
      await _db.into(_db.attendanceLogs).insert(
        AttendanceLogsCompanion.insert(
          meetingId:       Value(meetingId),
          meetingName:     i % 3 == 0 ? 'Friday Night Speaker Meeting' : 'Tuesday Night Home Group',
          attendedAt:      ago(d, hour: i % 3 == 0 ? 20 : 19),
          sharedAtMeeting: Value(i % 4 == 0),
          hasSponsorContact: Value(i % 5 == 0),
          hasServiceWork:  Value(i % 6 == 0),
          notes:           i % 7 == 0
              ? const Value('Good meeting. Identified with the speaker.')
              : const Value(null),
        ),
      );
    }

    // ── 5. Step 4 inventory — Resentments ────────────────────────────────────
    // "Mom" appears twice → triggers insight #5 (recurring resentment)
    final resentmentData = [
      (
        person: 'Mom',
        cause: 'She never trusted me, even after I got sober. Always checked up on me.',
        affects: 'self_esteem,personal_relations',
        myPart: 'I gave her years of reasons not to trust me. I chose to be dishonest.',
        flagged: true,
        daysAgo: 45,
      ),
      (
        person: 'David (Boss)',
        cause: 'Micromanages everything. Questioned my work in front of the whole team.',
        affects: 'self_esteem,ambitions,pride',
        myPart: 'I took shortcuts instead of doing the work thoroughly. I was defensive.',
        flagged: true,
        daysAgo: 42,
      ),
      (
        person: 'Sarah (ex)',
        cause: 'She ended the relationship while I was still drinking. Moved on quickly.',
        affects: 'self_esteem,security,sex_relations,personal_relations',
        myPart: 'I was emotionally unavailable and dishonest throughout the relationship.',
        flagged: false,
        daysAgo: 40,
      ),
      (
        person: 'Mom',
        cause: 'Christmas argument. She brought up my past in front of everyone.',
        affects: 'self_esteem,personal_relations,pride',
        myPart: 'I was defensive and stormed out instead of listening.',
        flagged: true,
        daysAgo: 38,
      ),
      (
        person: 'Neighbor (Tom)',
        cause: 'Filed a noise complaint without talking to me first. Feels like an attack.',
        affects: 'security,personal_relations',
        myPart: 'My gatherings were too loud. I never considered his perspective.',
        flagged: false,
        daysAgo: 35,
      ),
      (
        person: 'Jake (old friend)',
        cause: 'Lent him \$500 when drinking. He never paid it back and disappeared.',
        affects: 'security,pocketbook,personal_relations',
        myPart: 'I loaned money expecting something in return — that was manipulation.',
        flagged: false,
        daysAgo: 33,
      ),
      (
        person: 'Myself',
        cause: 'Wasted ten years drinking. Lost relationships, jobs, and self-respect.',
        affects: 'self_esteem,security,ambitions',
        myPart: 'I chose to pick up. I chose not to ask for help sooner.',
        flagged: true,
        daysAgo: 30,
      ),
      (
        person: 'Mark (coworker)',
        cause: 'Took credit for my project in the team meeting. Went to the manager behind my back.',
        affects: 'self_esteem,ambitions,pride',
        myPart: 'I did not communicate my boundaries or document my contributions.',
        flagged: false,
        daysAgo: 28,
      ),
    ];

    for (final r in resentmentData) {
      await _db.into(_db.resentments).insert(
        ResentmentsCompanion.insert(
          person:        r.person,
          cause:         r.cause,
          affects:       r.affects,
          myPart:        r.myPart,
          flagForReview: Value(r.flagged),
          createdAt:     ago(r.daysAgo),
        ),
      );
    }

    // ── 6. Step 4 inventory — Fears ──────────────────────────────────────────
    final fearData = [
      (
        subject: 'Financial insecurity',
        why: 'Lost my savings during active addiction. Still rebuilding. Fear of being broke again.',
        myPart: 'I spent recklessly and avoided budgeting. I did not plan.',
        flagged: true,
        daysAgo: 44,
      ),
      (
        subject: 'Losing my job',
        why: 'Boss already questioned me. Fear of being fired and having no income.',
        myPart: 'I have not been as thorough or communicative as I should be at work.',
        flagged: false,
        daysAgo: 42,
      ),
      (
        subject: 'People finding out about my past',
        why: 'Shame about DUI, lost job, broken relationships. Fear of judgment.',
        myPart: 'I have been selective about my story instead of trusting the process.',
        flagged: true,
        daysAgo: 39,
      ),
      (
        subject: 'Relapse',
        why: 'I know how quickly it can happen. Some days the thought still appears.',
        myPart: 'Not calling my sponsor when I feel the pull. Isolating.',
        flagged: true,
        daysAgo: 36,
      ),
      (
        subject: 'Being a burden to others',
        why: 'People have helped me so much. Fear of wearing out my welcome.',
        myPart: 'False pride — I do not ask for help, then resent people for not offering.',
        flagged: false,
        daysAgo: 34,
      ),
      (
        subject: 'Ending up alone',
        why: 'Pushed so many people away. Fear there is no one left who will accept me.',
        myPart: 'Self-pity and isolation keep me from building real connections.',
        flagged: false,
        daysAgo: 31,
      ),
    ];

    for (final f in fearData) {
      await _db.into(_db.fears).insert(
        FearsCompanion.insert(
          subject:       f.subject,
          why:           f.why,
          myPart:        f.myPart,
          flagForReview: Value(f.flagged),
          createdAt:     ago(f.daysAgo),
        ),
      );
    }

    // ── 7. Step 4 inventory — Harms ──────────────────────────────────────────
    final harmData = [
      (
        person: 'Sarah (ex-girlfriend)',
        conduct: 'Emotional manipulation, gaslighting, drinking and starting arguments at 2 AM.',
        myPart: 'I put my addiction before the relationship and used her as a punching bag.',
        amendsPlan: 'Write a letter. Acknowledge the harm without expecting forgiveness.',
        done: false,
        flagged: true,
        daysAgo: 43,
      ),
      (
        person: 'Mom',
        conduct: 'Years of lying about drinking, stealing cash from her purse, missed events.',
        myPart: 'I consistently chose alcohol over family and used her love as a safety net.',
        amendsPlan: 'Face-to-face amends. Already in progress — making living amends.',
        done: false,
        flagged: true,
        daysAgo: 41,
      ),
      (
        person: 'Jake',
        conduct: 'Borrowed \$500 and never paid it back. Lost contact.',
        myPart: 'I knew I could not pay it back when I asked. I was dishonest from the start.',
        amendsPlan: 'Locate and repay with interest.',
        done: false,
        flagged: false,
        daysAgo: 38,
      ),
      (
        person: 'Former employer (Apex Co.)',
        conduct: 'Called in sick repeatedly while drinking. Stole office supplies. Slept at my desk.',
        myPart: 'I was unreliable, dishonest, and put coworkers in difficult positions.',
        amendsPlan: 'Indirect amends through continued professional integrity at current job.',
        done: true,
        flagged: false,
        daysAgo: 36,
      ),
      (
        person: 'Lisa (sister)',
        conduct: 'Missed her wedding entirely. Drunk and passed out at the hotel.',
        myPart: 'I chose drinking over the most important day of her life.',
        amendsPlan: 'Personal conversation. I have already had this; living amends ongoing.',
        done: true,
        flagged: true,
        daysAgo: 33,
      ),
      (
        person: 'Carlos (former roommate)',
        conduct: 'Damaged his guitar and TV during a blackout. Denied it afterwards.',
        myPart: 'I lied directly to his face and never took responsibility.',
        amendsPlan: 'Pay for replacement + apology.',
        done: false,
        flagged: false,
        daysAgo: 31,
      ),
      (
        person: 'Neighbor (Tom)',
        conduct: 'Harassed him over the noise complaint. Left a nasty note on his door.',
        myPart: 'My ego was hurt and I retaliated instead of making it right.',
        amendsPlan: 'Knock on his door, acknowledge my behavior, offer to talk.',
        done: true,
        flagged: false,
        daysAgo: 29,
      ),
    ];

    final harmIds = <int>[];
    for (final h in harmData) {
      final id = await _db.into(_db.harms).insert(
        HarmsCompanion.insert(
          person:       h.person,
          conduct:      h.conduct,
          myPart:       h.myPart,
          amendsPlan:   Value(h.amendsPlan),
          isAmendsDone: Value(h.done),
          dateAmendsDone: h.done ? Value(ago(h.daysAgo - 5)) : const Value(null),
          flagForReview: Value(h.flagged),
          createdAt:    ago(h.daysAgo),
        ),
      );
      harmIds.add(id);
    }

    // ── 8. Amends ─────────────────────────────────────────────────────────────
    // 3 completed, 3 pending, 2 step8 → 43% done → neutral level
    final amendsData = [
      (person: 'Sarah (ex-girlfriend)', status: 'step8',     type: AmendsType.emotional,    priority: 1, timeframe: 'weeks',  daysAgo: 40),
      (person: 'Mom',                   status: 'pending',   type: AmendsType.personal,     priority: 1, timeframe: 'asap',   daysAgo: 38),
      (person: 'Jake',                  status: 'pending',   type: AmendsType.financial,    priority: 2, timeframe: 'months', daysAgo: 36),
      (person: 'Former employer',       status: 'completed', type: AmendsType.professional, priority: 3, timeframe: null,     daysAgo: 34),
      (person: 'Lisa (sister)',         status: 'completed', type: AmendsType.personal,     priority: 1, timeframe: null,     daysAgo: 32),
      (person: 'Carlos (roommate)',     status: 'pending',   type: AmendsType.financial,    priority: 2, timeframe: 'months', daysAgo: 30),
      (person: 'Neighbor Tom',          status: 'completed', type: AmendsType.personal,     priority: 2, timeframe: null,     daysAgo: 20),
      (person: 'Dad',                   status: 'step8',     type: AmendsType.personal,     priority: 1, timeframe: 'years',  daysAgo: 25),
    ];

    for (final a in amendsData) {
      await _db.into(_db.amends).insert(
        AmendsCompanion.insert(
          person:        a.person,
          harmId:        const Value(null),
          amendsType:    Value(a.type),
          status:        Value(a.status),
          priority:      Value(a.priority),
          timeframe:     Value(a.timeframe),
          dateCompleted: a.status == 'completed' ? Value(ago(a.daysAgo - 3)) : const Value(null),
          plan:          Value('Discussed with sponsor Bill. Approach agreed.'),
          createdAt:     Value(ago(a.daysAgo)),
        ),
      );
    }

    // ── 9. Step 5 completion ──────────────────────────────────────────────────
    await _db.into(_db.step5Completions).insert(
      Step5CompletionsCompanion.insert(
        admittedToSelf:        const Value(true),
        admittedToHigherPower: const Value(true),
        admittedToSponsor:     const Value(true),
        reflection: const Value(
          'The longest and most honest conversation of my life. Bill listened without '
          'judgment for three hours. I cried twice. I left lighter than I have felt '
          'in years. The fifth step actually works.',
        ),
        resentmentCount: const Value(8),
        fearCount:       const Value(6),
        harmCount:       const Value(7),
        completedAt:     ago(90, hour: 15),
      ),
    );

    // ── 10. Defects (Step 6) ──────────────────────────────────────────────────
    final defectData = [
      (name: 'Self-pity',    category: 'Emotional',    ready: true),
      (name: 'Dishonesty',   category: 'Character',    ready: true),
      (name: 'Pride',        category: 'Character',    ready: true),
      (name: 'Resentment',   category: 'Emotional',    ready: true),
      (name: 'Fear',         category: 'Emotional',    ready: false),
      (name: 'Selfishness',  category: 'Character',    ready: false),
      (name: 'Impatience',   category: 'Interpersonal', ready: false),
    ];

    final defectIds = <int>[];
    for (final d in defectData) {
      final id = await _db.into(_db.defects).insert(
        DefectsCompanion.insert(
          name:      d.name,
          category:  Value(d.category),
          isReady:   Value(d.ready),
          createdAt: ago(85),
        ),
      );
      defectIds.add(id);
    }

    // ── 11. Daily reviews — 28 entries across 30 days ────────────────────────
    // Design: recent 14 days have lower disturbers (improving trend → encouraging)
    //         older 14 days have higher disturbers
    //         ~75% have gratitude text → insight #12 encouraging
    //         Mix of morning / spot_check / nightly types
    // Days with NO review: day 8 and day 22 (gaps keep consistency at 93%)
    final reviewDays = <(int day, bool resentful, bool selfish, bool dishonest, bool afraid, String? gratitude, String? notes, String type)>[
      // Recent period (days 0–13) — lower disturbers ──────────────────────────
      (0,  false, false, false, false, 'Sobriety, my sponsor, my home group.', null, 'nightly'),
      (1,  true,  false, false, false, 'Coffee, sunshine, another sober day.', 'Felt irritable with mom\'s call. Prayed and let it go.', 'nightly'),
      (1,  false, false, false, false, 'Set an intention to be of service today.', null, 'morning'),
      (2,  false, false, false, false, 'My job, my health, a roof over my head.', null, 'nightly'),
      (3,  false, true,  false, false, 'My sponsees trusting me.', 'Caught myself thinking about what I could get from the meeting instead of give.', 'spot_check'),
      (3,  false, false, false, false, 'Gratitude for another morning without a hangover.', null, 'morning'),
      (4,  false, false, false, false, 'The 12 steps actually working.', null, 'nightly'),
      (5,  true,  false, false, true,  'Bill. He has more patience with me than I deserve.', 'Traffic set me off. Classic fear of being late/judged.', 'spot_check'),
      (6,  false, false, false, false, 'My sobriety, my clarity, my relationships rebuilding.', null, 'nightly'),
      (6,  false, false, false, false, 'Woke up clear-headed. Good day ahead.', null, 'morning'),
      (7,  false, false, false, false, 'Lisa called. She said she\'s proud of me.', null, 'nightly'),
      (9,  false, true,  false, false, 'The newcomers who remind me why I keep coming back.', 'Caught myself wanting to talk over someone at work. Paused instead.', 'spot_check'),
      (10, false, false, false, false, 'Peace of mind. Two years ago this was unthinkable.', null, 'nightly'),
      (11, false, false, false, false, 'Woke up with a sense of purpose.', null, 'morning'),
      (12, false, false, false, false, 'The fellowship, the literature, the steps.', null, 'nightly'),
      (13, true,  false, true,  false, 'Honesty. At least I can see it now.', 'Told a half-truth to avoid a difficult conversation. Noticed it and corrected.', 'spot_check'),
      // Older period (days 14–29) — higher disturbers ─────────────────────────
      (14, true,  true,  false, true,  null, 'Hard day. Lots going on at work. Difficult to concentrate.', 'nightly'),
      (15, true,  false, true,  true,  'The program is bigger than my problems today.', 'Lied about being stuck in traffic. Classic.', 'nightly'),
      (16, true,  true,  false, false, null, 'Pushed someone\'s advice away because my ego was bruised.', 'spot_check'),
      (17, false, true,  true,  true,  null, 'Three disturbers today — need to call Bill tomorrow.', 'nightly'),
      (18, true,  false, false, true,  'Grateful I am not where I was.', null, 'nightly'),
      (18, true,  true,  false, false, null, 'Morning review — resentment from yesterday still sitting with me.', 'morning'),
      (19, false, true,  true,  false, 'The people in my life who haven\'t given up on me.', null, 'nightly'),
      (20, true,  true,  true,  false, null, 'Reactive at work twice today.', 'spot_check'),
      (21, true,  false, false, true,  'My Higher Power. Something kept me sober today.', null, 'nightly'),
      (23, true,  true,  false, true,  null, null, 'nightly'),
      (24, false, true,  true,  true,  'My sobriety. It\'s the foundation of everything.', 'Selfish thoughts most of the day.', 'nightly'),
      (25, true,  true,  false, false, 'Meetings, sponsorship, service — the triangle works.', null, 'spot_check'),
      (26, true,  false, true,  true,  null, 'Fear and dishonesty showed up together today.', 'nightly'),
      (27, true,  true,  true,  true,  null, 'All four today. Rough week. Made it though.', 'nightly'),
      (28, false, true,  false, true,  'Progress, not perfection.', null, 'morning'),
      (29, true,  false, true,  false, null, null, 'nightly'),
    ];

    final reviewIds = <int>[];
    for (final r in reviewDays) {
      final id = await _db.into(_db.dailyReviews).insert(
        DailyReviewsCompanion.insert(
          date:        ago(r.$1, hour: r.$8 == 'morning' ? 7 : r.$8 == 'spot_check' ? 14 : 21),
          wasResentful: Value(r.$2),
          wasSelfish:   Value(r.$3),
          wasDishonest: Value(r.$4),
          wasAfraid:    Value(r.$5),
          gratitude:    Value(r.$6),
          notes:        Value(r.$7),
          reviewType:   Value(r.$8),
          createdAt:    ago(r.$1, hour: r.$8 == 'morning' ? 7 : r.$8 == 'spot_check' ? 14 : 22),
        ),
      );
      reviewIds.add(id);
    }

    // ── 12. Shortcoming logs — "Self-pity" 6×, "Dishonesty" 2×, "Pride" 2× ──
    // 6× Self-pity → insight #7 "Most noticed shortcoming" at gentle level (≥5)
    final shortcomingData = [
      (desc: 'Self-pity',  defectIdx: 0, daysAgo: 2,  reviewIdx: 0),
      (desc: 'Self-pity',  defectIdx: 0, daysAgo: 5,  reviewIdx: 4),
      (desc: 'Dishonesty', defectIdx: 1, daysAgo: 7,  reviewIdx: 7),
      (desc: 'Self-pity',  defectIdx: 0, daysAgo: 10, reviewIdx: 11),
      (desc: 'Pride',      defectIdx: 2, daysAgo: 13, reviewIdx: 15),
      (desc: 'Self-pity',  defectIdx: 0, daysAgo: 16, reviewIdx: 18),
      (desc: 'Self-pity',  defectIdx: 0, daysAgo: 19, reviewIdx: 21),
      (desc: 'Dishonesty', defectIdx: 1, daysAgo: 22, reviewIdx: 23),
      (desc: 'Self-pity',  defectIdx: 0, daysAgo: 25, reviewIdx: 25),
      (desc: 'Pride',      defectIdx: 2, daysAgo: 28, reviewIdx: 29),
    ];

    for (final s in shortcomingData) {
      await _db.into(_db.shortcomingLogs).insert(
        ShortcomingLogsCompanion.insert(
          description:     s.desc,
          dateObserved:    ago(s.daysAgo),
          defectId:        Value(defectIds[s.defectIdx]),
          relatedReviewId: Value(
            s.reviewIdx < reviewIds.length ? reviewIds[s.reviewIdx] : null,
          ),
        ),
      );
    }

    // ── 13. Meditation sessions — 22 of the last 30 days ─────────────────────
    // 22/30 = 73% → neutral (≥40%)
    // This week: ~55 min, last week: ~35 min → encouraging for insight #9
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekStart = DateTime(monday.year, monday.month, monday.day);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    // This-week sessions (Mon–today, ~55 total minutes)
    final thisWeekDays = [0, 1, 2, 3, 4].where((d) {
      final day = thisWeekStart.add(Duration(days: d));
      return !day.isAfter(now);
    }).toList();

    for (final offset in thisWeekDays) {
      final d = thisWeekStart.add(Duration(days: offset));
      // Morning session
      await _db.into(_db.meditationSessions).insert(
        MeditationSessionsCompanion.insert(
          sessionType:     'morning',
          reflectionTheme: ['acceptance', 'courage', 'serenity', 'gratitude', 'surrender'][offset % 5],
          reflectionKey:   'seed_morning_tw_$offset',
          durationSeconds: Value(600 + offset * 60), // 10–14 min
          completedAt:     DateTime(d.year, d.month, d.day, 7, 15),
        ),
      );
    }

    // Last-week sessions (~35 total minutes)
    final lastWeekOffsets = [0, 2, 4]; // Mon, Wed, Fri of last week
    for (final offset in lastWeekOffsets) {
      final d = lastWeekStart.add(Duration(days: offset));
      await _db.into(_db.meditationSessions).insert(
        MeditationSessionsCompanion.insert(
          sessionType:     offset == 4 ? 'evening' : 'morning',
          reflectionTheme: ['humility', 'service', 'peace'][offset ~/ 2],
          reflectionKey:   'seed_lw_$offset',
          durationSeconds: const Value(660), // 11 min each
          completedAt:     DateTime(d.year, d.month, d.day, offset == 4 ? 21 : 7, 10),
        ),
      );
    }

    // Remaining sessions spread across days 8–30 (fill to ~22 unique days)
    final olderDays = [8, 9, 11, 12, 14, 16, 17, 19, 20, 21, 23, 24, 26, 27];
    final themes = ['acceptance', 'courage', 'serenity', 'gratitude', 'surrender', 'humility', 'service', 'peace', 'honesty', 'love', 'faith', 'hope', 'patience', 'tolerance'];
    for (var i = 0; i < olderDays.length; i++) {
      final d = olderDays[i];
      await _db.into(_db.meditationSessions).insert(
        MeditationSessionsCompanion.insert(
          sessionType:     i % 3 == 2 ? 'evening' : 'morning',
          reflectionTheme: themes[i % themes.length],
          reflectionKey:   'seed_older_$d',
          durationSeconds: Value(300 + (i % 4) * 120), // 5–11 min
          completedAt:     ago(d, hour: i % 3 == 2 ? 21 : 7),
        ),
      );
    }

    // ── 14. Sponsees ──────────────────────────────────────────────────────────
    final jordanId = await _db.into(_db.sponsees).insert(
      SponseesCompanion.insert(
        name:                  'Jordan M.',
        phone:                 const Value('(217) 555-0147'),
        sobrietyDate:          Value(ago(185)),
        startedSponsoringDate: Value(ago(160)),
        currentStep:           const Value(4),
        isActive:              const Value(true),
        notes: const Value('Working Step 4 earnestly. Very willing. Calls every Tuesday.'),
      ),
    );

    final caseyId = await _db.into(_db.sponsees).insert(
      SponseesCompanion.insert(
        name:                  'Casey T.',
        phone:                 const Value('(217) 555-0293'),
        sobrietyDate:          Value(ago(420)),
        startedSponsoringDate: Value(ago(380)),
        currentStep:           const Value(7),
        isActive:              const Value(true),
        notes: const Value('Completed Step 6 last month. Working on humility. Strong program.'),
      ),
    );

    // Step progress for Jordan (Steps 1–3 done, Step 4 in progress)
    for (var step = 1; step <= 12; step++) {
      await _db.into(_db.sponseeStepProgress).insert(
        SponseeStepProgressCompanion.insert(
          sponseeId:   jordanId,
          stepNumber:  step,
          status: Value(
            step <= 3 ? 'completed' : step == 4 ? 'in_progress' : 'not_started',
          ),
          completedAt: step <= 3 ? Value(ago(180 - (step * 15))) : const Value(null),
        ),
      );
    }

    // Step progress for Casey (Steps 1–6 done, Step 7 in progress)
    for (var step = 1; step <= 12; step++) {
      await _db.into(_db.sponseeStepProgress).insert(
        SponseeStepProgressCompanion.insert(
          sponseeId:   caseyId,
          stepNumber:  step,
          status: Value(
            step <= 6 ? 'completed' : step == 7 ? 'in_progress' : 'not_started',
          ),
          completedAt: step <= 6 ? Value(ago(360 - (step * 30))) : const Value(null),
        ),
      );
    }

    // Check-ins
    await _db.into(_db.sponseeCheckIns).insert(
      SponseeCheckInsCompanion.insert(
        sponseeId:   jordanId,
        scheduledAt: ago(7, hour: 19),
        completedAt: Value(ago(7, hour: 19, minute: 45)),
        notes: const Value('Reviewed his Step 4 list. Encouraged him to be thorough with harms column.'),
      ),
    );
    await _db.into(_db.sponseeCheckIns).insert(
      SponseeCheckInsCompanion.insert(
        sponseeId:   caseyId,
        scheduledAt: ago(3, hour: 18),
        completedAt: Value(ago(3, hour: 18, minute: 50)),
        notes: const Value('Read Step 7 prayer together. Discussed willingness vs perfection.'),
      ),
    );
    await _db.into(_db.sponseeCheckIns).insert(
      SponseeCheckInsCompanion.insert(
        sponseeId:   jordanId,
        scheduledAt: ago(-7, hour: 19), // upcoming
      ),
    );

    // ── 15. 12th step calls ───────────────────────────────────────────────────
    await _db.into(_db.twelfthStepCalls).insert(
      TwelfthStepCallsCompanion.insert(
        callType:    const Value('call'),
        person:      const Value('Mike'),
        description: 'Outreach call to newcomer referred by the homegroup secretary.',
        outcome:     const Value('Good conversation. He has 4 days. Will meet for coffee Saturday.'),
        occurredAt:  ago(5, hour: 17),
      ),
    );
    await _db.into(_db.twelfthStepCalls).insert(
      TwelfthStepCallsCompanion.insert(
        callType:    const Value('visit'),
        person:      const Value('Robert'),
        description: 'In-person visit to member struggling after relapse.',
        outcome:     const Value('He is back at meetings. Gave him my number again.'),
        occurredAt:  ago(11, hour: 14),
      ),
    );
    await _db.into(_db.twelfthStepCalls).insert(
      TwelfthStepCallsCompanion.insert(
        callType:    const Value('sponsorship'),
        person:      const Value('Jordan M.'),
        description: 'Weekly step work call — reviewed Step 4 resentment entries.',
        outcome:     const Value('Made real progress. Jordan identified a recurring pattern around control.'),
        occurredAt:  ago(7, hour: 19),
        sponseeId:   Value(jordanId),
      ),
    );
    await _db.into(_db.twelfthStepCalls).insert(
      TwelfthStepCallsCompanion.insert(
        callType:    const Value('sponsorship'),
        person:      const Value('Casey T.'),
        description: 'Step 7 check-in. Read the Step 7 prayer together.',
        outcome:     const Value('Casey is ready. Moved into Step 8 list next week.'),
        occurredAt:  ago(3, hour: 18),
        sponseeId:   Value(caseyId),
      ),
    );
    await _db.into(_db.twelfthStepCalls).insert(
      TwelfthStepCallsCompanion.insert(
        callType:    const Value('general'),
        person:      const Value(null),
        description: 'Helped set up chairs and coffee before the Tuesday meeting.',
        outcome:     const Value('Simple service. Worth more than I can calculate.'),
        occurredAt:  ago(2, hour: 18, minute: 30),
      ),
    );

    // ── 16. Service commitments ───────────────────────────────────────────────
    await _db.into(_db.serviceCommitments).insert(
      ServiceCommitmentsCompanion.insert(
        type:               const Value('position'),
        title:              'GSR (Group Service Representative)',
        organization:       const Value('Tuesday Night Home Group'),
        startDate:          ago(180),
        isActive:           const Value(true),
        isRecurring:        const Value(true),
        recurringWeekday:   const Value(2), // Tuesday
        recurringTime:      const Value('19:00'),
        reminderEnabled:    const Value(true),
        reminderMinutesBefore: const Value(60),
        notes: const Value('Represent the group at district meetings. Monthly report.'),
      ),
    );
    await _db.into(_db.serviceCommitments).insert(
      ServiceCommitmentsCompanion.insert(
        type:            const Value('general'),
        title:           'Coffee & Setup',
        organization:    const Value('Tuesday Night Home Group'),
        startDate:       ago(90),
        isActive:        const Value(true),
        isRecurring:     const Value(true),
        recurringWeekday: const Value(2),
        recurringTime:   const Value('18:30'),
        reminderEnabled: const Value(true),
        reminderMinutesBefore: const Value(30),
      ),
    );
    await _db.into(_db.serviceCommitments).insert(
      ServiceCommitmentsCompanion.insert(
        type:         const Value('speaking'),
        title:        'Speaker — Unity Group Anniversary',
        organization: const Value('Unity Group'),
        startDate:    ago(-14), // 2 weeks from now
        isActive:     const Value(true),
        isRecurring:  const Value(false),
        notes: const Value('20-minute qualification. Focus on how Step 5 changed everything.'),
      ),
    );

    // ── 17. Step 12 events ────────────────────────────────────────────────────
    await _db.into(_db.stepTwelveEvents).insert(
      StepTwelveEventsCompanion.insert(
        title:     'District Meeting',
        description: const Value('Monthly GSR report — bring group conscience notes.'),
        location:  const Value('Intergroup Office, 88 Commerce Blvd'),
        startTime: ago(-10, hour: 18, minute: 30), // 10 days from now
        endTime:   Value(ago(-10, hour: 20)),
        eventType: const Value('service'),
      ),
    );
    await _db.into(_db.stepTwelveEvents).insert(
      StepTwelveEventsCompanion.insert(
        title:     'Coffee with Mike (newcomer)',
        description: const Value('Follow-up after 12th-step call. Bring a Big Book.'),
        startTime: ago(-3, hour: 10), // 3 days from now
        eventType: const Value('general'),
      ),
    );

    // ── 18. Sponsor call logs — 10 calls in last 30 days ─────────────────────
    final callDays = [1, 3, 6, 8, 12, 15, 18, 21, 25, 28];
    for (final d in callDays) {
      await _db.into(_db.sponsorCallLogs).insert(
        SponsorCallLogsCompanion.insert(
          confirmedAt:  ago(d, hour: 8, minute: 30),
          calledViaApp: Value(d % 3 == 0),
          scheduledFor: d % 3 == 0 ? Value(ago(d, hour: 8)) : const Value(null),
          notes: Value(
            d <= 3
                ? 'Quick morning check-in. Bill reminded me to keep it simple.'
                : d <= 10
                    ? 'Talked through the resentment toward David at work. Bill said: "Your job is not to fix him — it\'s to not let him live in your head."'
                    : d <= 20
                        ? 'Discussed amends list. He thinks I should wait on Sarah — more Step 8 work first.'
                        : null,
          ),
        ),
      );
    }

    // ── 19. Journal entries — 10 entries across Steps 1, 2, 3, 4, 5, 6, 8, 9, 10, 11 ──
    // 8 unique step numbers → insight #10 "8/12" → encouraging level
    final journalData = [
      (step: 1,  title: 'Admitting Powerlessness',
       content: 'Step 1 was the beginning of everything. I thought I could control it. '
           'The evidence was everywhere that I couldn\'t, but I kept finding new excuses. '
           'When I finally said "I am an alcoholic and I cannot manage my life," something '
           'released. It was terrifying and relieving in the same moment.',
       daysAgo: 500),
      (step: 2,  title: 'Came to Believe',
       content: 'I am not a religious person. The God-of-my-understanding took years to find. '
           'But I kept coming to meetings, kept hearing people talk about a power greater than '
           'themselves, and slowly something shifted. I do not need to understand it. I just '
           'need to let it work.',
       daysAgo: 470),
      (step: 3,  title: 'Turning It Over',
       content: 'The Third Step Prayer hit me harder than I expected. "God, I offer myself to '
           'Thee — to build with me and to do with me as Thou wilt." The word "offer" matters. '
           'It is active, not passive. I am choosing this. I read it every morning for a month.',
       daysAgo: 440),
      (step: 4,  title: 'The Fear List Changed Everything',
       content: 'Writing out my fears was more uncomfortable than writing my resentments. '
           'Resentment lets you point at someone else. Fear is all you. Looking at what I '
           'was afraid of — financial insecurity, people seeing through me, dying alone — '
           'I could finally see the beliefs that had been running my behavior for decades.',
       daysAgo: 200),
      (step: 5,  title: 'The Day After Step 5',
       content: 'I left Bill\'s house and sat in my car for ten minutes. Not crying, just '
           'still. I do not know how to describe what changed — something cleaned out. '
           'The Big Book says we may be able to enjoy a new freedom, and I believe it now.',
       daysAgo: 89),
      (step: 6,  title: 'Entirely Ready',
       content: 'Bill asked me: "Are you willing to have God remove these defects — even '
           'the ones that feel like they protect you?" Self-pity has been my security blanket. '
           'Being the victim meant nothing was ever my fault. I am not sure I am "entirely" '
           'ready, but I am more ready than I have ever been.',
       daysAgo: 75),
      (step: 8,  title: 'The List Is Not the Amends',
       content: 'Making the list was hard. Admitting Carlos — I genuinely forgot until I '
           'really sat with it. Bill said the list is not punishment, it is a map to freedom. '
           'Each name on the list is a place where I gave away a piece of myself.',
       daysAgo: 50),
      (step: 9,  title: 'After the Amends to Lisa',
       content: 'She cried. I cried. She said she knew I loved her even when I was drinking. '
           'I did not deserve that grace. I received it anyway. This is what the program '
           'promises. I understand the ninth step promises now — not as words in a book, '
           'but as something I felt.',
       daysAgo: 30),
      (step: 10, title: 'The Spot Check Is Not Judgment',
       content: 'I used to think the 10th step was about cataloguing my failures. It is not. '
           'It is about catching the smoke before the fire. Today I noticed self-pity creeping '
           'in around 2pm, named it, prayed, and moved on. That is the whole practice.',
       daysAgo: 14),
      (step: 11, title: 'What Meditation Is Actually For',
       content: 'I finally stopped trying to empty my mind and just let it be what it is. '
           'The instructions say: "seek through prayer and meditation to improve our conscious '
           'contact." Contact, not control. Seven minutes of stillness every morning is changing '
           'how I move through the rest of the day.',
       daysAgo: 7),
    ];

    for (final j in journalData) {
      final ts = ago(j.daysAgo, hour: 21);
      await _db.into(_db.journalEntries).insert(
        JournalEntriesCompanion.insert(
          title:       Value(j.title),
          content:     j.content,
          stepNumber:  Value(j.step),
          createdAt:   Value(ts),
          updatedAt:   Value(ts),
        ),
      );
    }

    // ── 20. Literature bookmarks ──────────────────────────────────────────────
    await _db.into(_db.literatureBookmarks).insertOnConflictUpdate(
      LiteratureBookmarksCompanion.insert(
        bookKey:      'bigbook',
        chapterKey:   'bb_ch5',
        chapterTitle: 'How It Works',
        note: const Value('Read every morning. "Rarely have we seen a person fail..." is where it starts.'),
      ),
    );
    await _db.into(_db.literatureBookmarks).insertOnConflictUpdate(
      LiteratureBookmarksCompanion.insert(
        bookKey:      'twelve_twelve',
        chapterKey:   'tt_step3',
        chapterTitle: 'Step Three',
        note: const Value('The Third Step Prayer. Return to this when I feel like running the show.'),
      ),
    );
    await _db.into(_db.literatureBookmarks).insertOnConflictUpdate(
      LiteratureBookmarksCompanion.insert(
        bookKey:      'bigbook',
        chapterKey:   'bb_promises',
        chapterTitle: 'The Promises',
        note: const Value('Read after completing Lisa\'s amends. Every word is true.'),
      ),
    );

    // ── 21. Rolodex contacts ──────────────────────────────────────────────────
    await _db.into(_db.rolodexContacts).insert(
      RolodexContactsCompanion.insert(
        name:      'Bill H. (Sponsor)',
        phone:     const Value('(217) 555-0088'),
        notes:     const Value('18 years sober. Methodical, patient, direct. Old-timer.'),
        isSponsor: const Value(true),
        meetingId: Value(homeGroupId),
      ),
    );
    await _db.into(_db.rolodexContacts).insert(
      RolodexContactsCompanion.insert(
        name:      'Jordan M.',
        phone:     const Value('(217) 555-0147'),
        notes:     const Value('My first sponsee. Earnest and willing.'),
        sponseeId: Value(jordanId),
        meetingId: Value(homeGroupId),
      ),
    );
    await _db.into(_db.rolodexContacts).insert(
      RolodexContactsCompanion.insert(
        name:      'Casey T.',
        phone:     const Value('(217) 555-0293'),
        notes:     const Value('Strong program. Leading a meeting next month.'),
        sponseeId: Value(caseyId),
        meetingId: Value(homeGroupId),
      ),
    );
    await _db.into(_db.rolodexContacts).insert(
      RolodexContactsCompanion.insert(
        name:     'Barb P.',
        phone:    const Value('(217) 555-0361'),
        email:    const Value('bpflint@example.com'),
        notes:    const Value('Service committee co-chair. Call before district meetings.'),
        meetingId: Value(homeGroupId),
      ),
    );
    await _db.into(_db.rolodexContacts).insert(
      RolodexContactsCompanion.insert(
        name:     'Mike N. (newcomer)',
        phone:    const Value('(217) 555-0512'),
        notes:    const Value('4 days sober. Referred by secretary. Coffee Saturday.'),
      ),
    );
  }
}
