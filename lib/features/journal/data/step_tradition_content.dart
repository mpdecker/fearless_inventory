import '../../../core/quotes/recovery_quotes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

enum JournalSubjectType { step, tradition }

/// Immutable content descriptor for a single Step or Tradition.
/// Drives the step/tradition landing page in the Journal tab.
class JournalSubjectContent {
  final JournalSubjectType type;

  /// Step or tradition number (1–12).
  final int number;

  /// The canonical text of the step or tradition.
  final String text;

  /// Short thematic label, e.g. "Powerlessness & Unmanageability".
  final String title;

  /// One- or two-paragraph description of the spiritual purpose of this
  /// step / tradition — written in the voice of recovery literature.
  final String description;

  /// Two or three key themes surfaced by this step / tradition.
  final List<String> themes;

  /// Curated quotes from Big Book or 12 & 12 that illuminate this topic.
  final List<RecoveryQuote> quotes;

  /// Reflective writing prompts.  Currently static; architecture supports
  /// future replacement by AI-generated prompts via [PromptService].
  final List<String> contemplativePrompts;

  const JournalSubjectContent({
    required this.type,
    required this.number,
    required this.text,
    required this.title,
    required this.description,
    required this.themes,
    required this.quotes,
    required this.contemplativePrompts,
  });

  String get label =>
      type == JournalSubjectType.step ? 'Step $number' : 'Tradition $number';

  String get fullLabel =>
      type == JournalSubjectType.step
          ? 'Step $number: $title'
          : 'Tradition $number: $title';
}

// ─────────────────────────────────────────────────────────────────────────────
// Steps 1–12
// ─────────────────────────────────────────────────────────────────────────────

const _steps = <JournalSubjectContent>[
  // ── Step 1 ────────────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.step,
    number: 1,
    text:
        'We admitted we were powerless over alcohol — that our lives had become unmanageable.',
    title: 'Powerlessness & Unmanageability',
    description:
        'The First Step asks us to face a fundamental truth about ourselves: that '
        'our attempts to control our drinking (or addictive behavior) have utterly '
        'failed, and that our lives have suffered as a result. Admitting powerlessness '
        'is not defeat — it is the gateway to freedom. The 12 & 12 calls this the '
        'bedrock upon which happy and purposeful lives may be built.\n\n'
        'Many of us resisted this step for years. We bargained, minimized, and '
        'rationalized. Step One asks us to stop fighting and see clearly what is '
        'actually true. The relief that comes from honest surrender is one of '
        'recovery\'s greatest gifts.',
    themes: ['Surrender', 'Honesty', 'Acceptance'],
    quotes: [
      RecoveryQuotes.step1HalfMeasures,
      RecoveryQuotes.step1Concede,
      RecoveryQuotes.step1Bedrock,
    ],
    contemplativePrompts: [
      'In what ways did my attempt to control my drinking (or other behavior) show itself most clearly? What evidence did I ignore or explain away?',
      'How did the unmanageability of my life manifest — in my relationships, work, health, or inner life? What did I lose that I am only now beginning to grieve?',
      'What does genuine surrender feel like to me today? Is there any area of my life where I am still trying to manage outcomes that are beyond my control?',
    ],
  ),

  // ── Step 2 ────────────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.step,
    number: 2,
    text:
        'Came to believe that a Power greater than ourselves could restore us to sanity.',
    title: 'Hope & a Higher Power',
    description:
        'Step Two opens the door to hope after the humility of Step One. It asks '
        'not for blind faith, but for simple open-mindedness — can I believe that '
        'there might be something greater than my own thinking that could help me? '
        'Many of us came to this step as confirmed skeptics, yet found that an '
        'honest, open mind was all that was required.\n\n'
        'The word "came" suggests a process, not an event. We came to believe '
        'gradually — through watching others recover, through small moments of '
        'unexpected grace, through the quiet evidence that something was working. '
        'This step is about possibility, not certainty.',
    themes: ['Hope', 'Open-Mindedness', 'Faith'],
    quotes: [
      RecoveryQuotes.step2Power,
      RecoveryQuotes.step2Willing,
      RecoveryQuotes.step2Sanity,
    ],
    contemplativePrompts: [
      'What did "sanity" look like in my using? What thoughts and behaviors were truly insane, even if they seemed logical to me at the time?',
      'What barriers do I carry to believing in a Higher Power? Can I identify what I already believe in — love, nature, the fellowship itself — as a starting point?',
      'What would it look like to be "restored to sanity" in a specific area of my life today? What would be different?',
    ],
  ),

  // ── Step 3 ────────────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.step,
    number: 3,
    text:
        'Made a decision to turn our will and our lives over to the care of God as we understood Him.',
    title: 'Decision & Surrender',
    description:
        'Step Three is the turning point — a decision, not yet a complete action. '
        'The Big Book describes it as the beginning of a lifelong practice of '
        'releasing self-will and trusting something greater. We don\'t do this '
        'perfectly; we return to this decision again and again throughout our lives.\n\n'
        'The phrase "as we understood Him" is a gift of radical inclusivity. Our '
        'understanding of a Higher Power is deeply personal and may evolve '
        'throughout recovery. What Step Three asks is not theological precision, '
        'but a willingness to stop playing God with our own lives and others\' lives.',
    themes: ['Trust', 'Willingness', 'Letting Go'],
    quotes: [
      RecoveryQuotes.step3Prayer,
      RecoveryQuotes.step3Decision,
      RecoveryQuotes.step3Selfishness,
    ],
    contemplativePrompts: [
      'What areas of my life am I still trying to run on self-will? What would it look like — concretely — to turn those areas over today?',
      'What does "God as I understand Him" mean to me right now? How has that understanding shifted since I first came into recovery?',
      'When I face a difficult decision, how do I try to discern the will of a Higher Power? What practices or people help me find clarity?',
    ],
  ),

  // ── Step 4 ────────────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.step,
    number: 4,
    text:
        'Made a searching and fearless moral inventory of ourselves.',
    title: 'The Searching & Fearless Inventory',
    description:
        'Step Four is the courageous act of looking clearly at ourselves — not '
        'to condemn, but to understand. Like a business that takes stock to know '
        'what it has, we examine our resentments, fears, and relationships to '
        'understand where self-will, fear, and character flaws have driven our lives.\n\n'
        'The inventory is a tool, not a punishment. The 12 & 12 reminds us that '
        'a business which takes no regular inventory usually goes broke. The same '
        'is true of our inner lives. The goal is honesty, not self-flagellation — '
        'and the insight gained here becomes the foundation for all the steps that follow.',
    themes: ['Honesty', 'Courage', 'Self-Knowledge'],
    quotes: [
      RecoveryQuotes.step4Resentment,
      RecoveryQuotes.step4Inventory,
      RecoveryQuotes.step4Liabilities,
    ],
    contemplativePrompts: [
      'What resentments am I still carrying that I haven\'t fully explored? What fear or wounded pride might lie beneath them?',
      'Which of my character defects do I find easiest to acknowledge? Which are hardest to see? What does that tell me?',
      'As I look at my part in various situations in my inventory, what patterns emerge? What recurring themes do I notice about how I move through the world?',
    ],
  ),

  // ── Step 5 ────────────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.step,
    number: 5,
    text:
        'Admitted to God, to ourselves, and to another human being the exact nature of our wrongs.',
    title: 'The Three Admissions',
    description:
        'Step Five moves our inventory from paper to voice. Something profound '
        'happens when we speak our story aloud to another person — the shame and '
        'secrets lose their power. The Big Book promises that after this step, '
        'we will know "a new freedom."\n\n'
        'Step Five is also about radical honesty with ourselves: not just listing '
        'behaviors, but acknowledging the underlying patterns, fears, and motives '
        'that drive them. Many find that the experience of being heard without '
        'judgment — and still being accepted — is a transformative encounter '
        'with grace.',
    themes: ['Honesty', 'Humility', 'Freedom'],
    quotes: [
      RecoveryQuotes.step5Pocket,
      RecoveryQuotes.step5Completed,
      RecoveryQuotes.step5Another,
    ],
    contemplativePrompts: [
      'What did the experience of sharing my Step Five teach me? Were there surprises — things that felt more or less significant once spoken aloud?',
      'How did sharing with another person change my relationship to my past? What still feels unresolved or unspoken?',
      'The Big Book says after Step Five we will "know a new freedom." In what ways have I begun to experience that freedom?',
    ],
  ),

  // ── Step 6 ────────────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.step,
    number: 6,
    text:
        'Were entirely ready to have God remove all these defects of character.',
    title: 'Readiness & Release',
    description:
        'Step Six asks us to become entirely willing — not to have our defects '
        'removed immediately, but to want them removed. This is harder than it '
        'sounds. Our character defects have often served us; they\'ve been '
        'survival mechanisms, coping strategies, and familiar companions.\n\n'
        'The 12 & 12 calls this "the step that separates the men from the boys," '
        'not because it\'s dramatic, but because genuine willingness to change '
        'requires us to let go of old identities. We may need to ask God to '
        'make us willing to be willing — and that honest starting point is '
        'perfectly sufficient.',
    themes: ['Willingness', 'Readiness', 'Character'],
    quotes: [
      RecoveryQuotes.step6Ready,
      RecoveryQuotes.step6Willing,
      RecoveryQuotes.step6Separate,
    ],
    contemplativePrompts: [
      'Which of my character defects am I most reluctant to release? What benefit — protection, control, comfort — does it still provide me?',
      'What does "entirely ready" mean to me? Have I been entirely ready for all my defects, or just some of them? What accounts for the difference?',
      'How have my character defects both harmed me and served me? What would life look like without the ones I cling to most tightly?',
    ],
  ),

  // ── Step 7 ────────────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.step,
    number: 7,
    text: 'Humbly asked Him to remove our shortcomings.',
    title: 'Humility & Prayer',
    description:
        'Step Seven is the shortest step in the Big Book, yet the 12 & 12 '
        'devotes considerable attention to its spiritual core: humility. Not '
        'the humility of self-abasement, but the humility of right-sized '
        'self-understanding — knowing we are neither the center of the universe '
        'nor worthless.\n\n'
        'We ask, not demand. We acknowledge that we cannot remove our own '
        'shortcomings through willpower. The 12 & 12 points out that our '
        'character defects are often former assets gone awry — and that their '
        'gradual removal is one of the most reliable signs of spiritual growth.',
    themes: ['Humility', 'Prayer', 'Transformation'],
    quotes: [
      RecoveryQuotes.step7Humility,
      RecoveryQuotes.step7Prayer,
      RecoveryQuotes.step7ChiefActivator,
    ],
    contemplativePrompts: [
      'How has my understanding of humility changed since I came into recovery? What did I used to mistake for humility that was actually false modesty or self-pity?',
      'When my shortcomings reappear — and they do — what is my internal response? Do I bring them to prayer, or do I carry them in shame?',
      'Which shortcomings seem most persistent in my life today? What might a Higher Power be teaching me through their gradual, patient removal?',
    ],
  ),

  // ── Step 8 ────────────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.step,
    number: 8,
    text:
        'Made a list of all persons we had harmed, and became willing to make amends to them all.',
    title: 'The List & Willingness',
    description:
        'Step Eight asks us to cast a wide, honest net — not deciding yet what '
        'amends will look like, but simply becoming willing to see clearly who '
        'we\'ve harmed. The 12 & 12 notes that our emotions go on the defensive '
        'the moment we examine broken relationships, and Step Eight asks us '
        'to persist anyway.\n\n'
        'Willingness is the key; we don\'t have to feel ready to make every amend, '
        'only to be willing to be willing. The list often reveals not just '
        'the harm we\'ve done to others, but the harm we\'ve done to ourselves — '
        'an important element many overlook.',
    themes: ['Willingness', 'Honesty', 'Responsibility'],
    quotes: [
      RecoveryQuotes.step8Defensive,
      RecoveryQuotes.step8BecomeWilling,
      RecoveryQuotes.step8List,
    ],
    contemplativePrompts: [
      'Who appears on my amends list who surprised me — someone I initially didn\'t want to include, or someone I had forgotten? What does their inclusion teach me?',
      'What is the difference between guilt and genuine remorse? How has working Step Eight affected my relationship to that distinction?',
      'Are there people on my list I am still not fully willing to make amends to? What is the obstacle — fear, pride, or a belief that they owe me something first?',
    ],
  ),

  // ── Step 9 ────────────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.step,
    number: 9,
    text:
        'Made direct amends to such people wherever possible, except when to do so would injure them or others.',
    title: 'Making It Right',
    description:
        'Step Nine is where the work of recovery becomes visible in the world. '
        'Making amends is not merely saying sorry — it is changed behavior, '
        'restitution where possible, and honest acknowledgment of harm done. '
        'The exception clause is important: we don\'t make amends that cause '
        'further harm to others.\n\n'
        'The 12 & 12 guides us through the judgment required: timing, directness, '
        'and the genuine desire to set things right rather than to relieve our '
        'own guilt. As we complete this step, the Promises begin to come true '
        'in our lives — often in ways we least expect.',
    themes: ['Responsibility', 'Courage', 'Restoration'],
    quotes: [
      RecoveryQuotes.step9Mumbling,
      RecoveryQuotes.step9Timing,
      RecoveryQuotes.step9PeaceOfMind,
    ],
    contemplativePrompts: [
      'What has the experience of making amends taught me about myself and the people I harmed? What has surprised me about the process?',
      'Are there amends I am avoiding? What fear or concern keeps me from taking that step? What would it take to become willing?',
      'How has the Ninth Step changed my sense of who I am? What has been healed — in my relationships, in my conscience, in my sense of self?',
    ],
  ),

  // ── Step 10 ───────────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.step,
    number: 10,
    text:
        'Continued to take personal inventory and when we were wrong promptly admitted it.',
    title: 'Continuous Housecleaning',
    description:
        'Step Ten moves the inventory process into daily life. We no longer let '
        'resentments and wrongs accumulate — we catch them promptly. The Big Book '
        'describes a spot-check inventory throughout the day, and a more thorough '
        'review at night. This is how we maintain the spiritual fitness we\'ve built.\n\n'
        'The 12 & 12 reminds us that we aim for progress, not perfection. Step '
        'Ten also asks us to notice what we did well — gratitude and acknowledgment '
        'of growth are as important as catching our wrongs. Over time, this daily '
        'practice becomes second nature.',
    themes: ['Vigilance', 'Promptness', 'Growth'],
    quotes: [
      RecoveryQuotes.step10Evening,
      RecoveryQuotes.step10Promptly,
      RecoveryQuotes.step10Assets,
    ],
    contemplativePrompts: [
      'Looking at today (or the past week), where did I become resentful, selfish, dishonest, or afraid? What was my part in those moments?',
      'How promptly am I admitting my wrongs — to myself, to others, to God? Is there anything I am still carrying that needs to be acknowledged or set right?',
      'What does the Step Ten inventory tell me about where I\'m growing? What patterns do I notice — both the struggles and the genuine progress?',
    ],
  ),

  // ── Step 11 ───────────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.step,
    number: 11,
    text:
        'Sought through prayer and meditation to improve our conscious contact with God as we understood Him, '
        'praying only for knowledge of His will for us and the power to carry that out.',
    title: 'Prayer & Meditation',
    description:
        'Step Eleven is the great sustaining practice — not just something we do '
        'when in trouble, but a daily discipline of contact with a Higher Power. '
        'The Big Book outlines specific morning and evening practices. Prayer and '
        'meditation together form a two-way communication: prayer is speaking; '
        'meditation is listening.\n\n'
        'Over time, this step cultivates an inner life from which all our actions '
        'flow more naturally. We don\'t pray for specific outcomes, but for the '
        'wisdom to understand God\'s will and the courage to carry it out — a '
        'profound shift from the self-centered prayers of our using days.',
    themes: ['Prayer', 'Meditation', 'God\'s Will'],
    quotes: [
      RecoveryQuotes.step11Morning,
      RecoveryQuotes.step11Contact,
      RecoveryQuotes.step11Prayer,
    ],
    contemplativePrompts: [
      'What does my prayer and meditation practice look like today? What obstacles get in the way of it being more consistent, and what helps me return to it?',
      'How have I come to understand "God\'s will for me" differently than when I first came into recovery? What has changed in that understanding?',
      'When I sit in silence, what do I encounter — peace, restlessness, insight, fear? What do these experiences tell me about my inner life?',
    ],
  ),

  // ── Step 12 ───────────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.step,
    number: 12,
    text:
        'Having had a spiritual awakening as the result of these steps, we tried to carry this message '
        'to alcoholics, and to practice these principles in all our affairs.',
    title: 'Spiritual Awakening & Service',
    description:
        'Step Twelve is both the culmination and the beginning. The spiritual '
        'awakening is not always a dramatic flash of light — it is more often a '
        'gradual transformation: a new way of thinking, feeling, and relating to '
        'life. We carry the message not as experts but as witnesses: "Here is what '
        'happened to me."\n\n'
        'And we practice the principles in all our affairs — not just at meetings, '
        'but at home, at work, in traffic, in the quiet moments when no one is '
        'watching. This step asks us to let recovery permeate every corner of our '
        'lives, until the program is no longer something we do but something we are.',
    themes: ['Service', 'Spiritual Awakening', 'Principles'],
    quotes: [
      RecoveryQuotes.step12Intensive,
      RecoveryQuotes.step12NewMeaning,
      RecoveryQuotes.step12Principles,
    ],
    contemplativePrompts: [
      'What does my "spiritual awakening" look like? In what concrete ways am I a different person than I was when I arrived in recovery?',
      'How do I carry the message to others? What do I offer freely that was once freely given to me? What holds me back from giving more?',
      'Where in my daily affairs do I still struggle to practice the principles — patience, honesty, service, humility? What would it look like to bring recovery fully into that area?',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Traditions 1–12
// ─────────────────────────────────────────────────────────────────────────────

const _traditions = <JournalSubjectContent>[
  // ── Tradition 1 ───────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.tradition,
    number: 1,
    text:
        'Our common welfare should come first; personal recovery depends upon A.A. unity.',
    title: 'Unity Above All',
    description:
        'The First Tradition asks each member to consider the group before '
        'themselves. Personal recovery doesn\'t happen in isolation — it depends '
        'on the vitality of the fellowship that surrounds it. When we put our '
        'own desires, preferences, or grievances before the good of the group, '
        'we threaten the foundation on which everyone\'s recovery rests.\n\n'
        'The paradox is that by serving the whole, we serve ourselves. Unity '
        'is not uniformity — it is a shared commitment to a common purpose, '
        'maintained by people with very different backgrounds and personalities.',
    themes: ['Unity', 'Common Good', 'Interconnection'],
    quotes: [
      RecoveryQuotes.tradition1Unity,
      RecoveryQuotes.tradition1Survival,
    ],
    contemplativePrompts: [
      'How have I experienced the unity of the fellowship as a source of strength in my own recovery? What would I have lost without it?',
      'Are there ways my individual preferences or opinions have come into tension with the good of my group? How did I navigate that tension?',
      'What does "common welfare" mean to me beyond A.A.? How does this principle apply to my family, workplace, or community?',
    ],
  ),

  // ── Tradition 2 ───────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.tradition,
    number: 2,
    text:
        'For our group purpose there is but one ultimate authority — a loving God as He may express '
        'Himself in our group conscience. Our leaders are but trusted servants; they do not govern.',
    title: 'Loving Authority & Group Conscience',
    description:
        'The Second Tradition establishes a radical form of governance: not '
        'hierarchy, but conscience. The group conscience, when worked properly, '
        'is a process of seeking shared wisdom rather than imposing individual '
        'will. This requires members to check their egos at the door and '
        'genuinely try to discern what serves the group\'s purpose.\n\n'
        'Leaders in A.A. are described as "trusted servants" — a reminder that '
        'service in recovery means accountability, not authority. The greatest '
        'leaders are often those who lead least, creating space for the '
        'collective voice to be heard.',
    themes: ['Group Conscience', 'Service', 'Humility'],
    quotes: [
      RecoveryQuotes.tradition2GroupConscience,
      RecoveryQuotes.tradition2Leaders,
    ],
    contemplativePrompts: [
      'Have I ever been part of a group conscience decision that surprised me, or went differently than I expected? What did I learn from the process?',
      'What does "trusted servant" leadership look like in practice? How does it differ from how leadership typically works in the world outside A.A.?',
      'Where in my life am I being called to lead by serving rather than by directing? How does this tradition shape how I approach that role?',
    ],
  ),

  // ── Tradition 3 ───────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.tradition,
    number: 3,
    text: 'The only requirement for A.A. membership is a desire to stop drinking.',
    title: 'Radical Inclusion',
    description:
        'The Third Tradition is one of the most countercultural principles in '
        'recovery: no dues, no requirements, no vetting. Anyone who wants to '
        'stop drinking belongs. This means the fellowship must welcome people '
        'at every stage, in every condition — the newcomer who is visibly '
        'suffering, the person who has relapsed, the one who seems not to '
        '"want it" enough.\n\n'
        'The 12 & 12 traces the history of A.A.\'s early attempts to restrict '
        'membership and the lessons learned: whenever we put up barriers, we '
        'risk turning away the very person who needs the program most.',
    themes: ['Inclusion', 'Equality', 'Welcome'],
    quotes: [
      RecoveryQuotes.tradition3OpenDoor,
      RecoveryQuotes.tradition3Desire,
    ],
    contemplativePrompts: [
      'Have I ever felt like an outsider in recovery — unsure if I really "qualified"? How did that change? What made the difference?',
      'How do I personally embody the spirit of radical welcome toward newcomers, especially those who seem different from me or "not ready"?',
      'What does this tradition suggest about how I approach people in my daily life — those who seem unlike me, or who are struggling in ways I don\'t fully understand?',
    ],
  ),

  // ── Tradition 4 ───────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.tradition,
    number: 4,
    text:
        'Each group should be autonomous except in matters affecting other groups or A.A. as a whole.',
    title: 'Autonomy Within Unity',
    description:
        'The Fourth Tradition balances independence with responsibility. Each '
        'group has the freedom to run itself as it sees fit — but not at the '
        'expense of the broader fellowship. This principle honors local '
        'knowledge and diversity while maintaining the integrity of the whole.\n\n'
        'It is a template for responsible freedom: I can do as I see best, '
        'within the constraint that I don\'t harm the larger community. '
        'The 12 & 12 notes that A.A. groups have sometimes learned hard lessons '
        'about where autonomy ends and harm to others begins — and that these '
        'lessons were valuable precisely because they were experienced, not imposed.',
    themes: ['Autonomy', 'Responsibility', 'Community'],
    quotes: [
      RecoveryQuotes.tradition4Autonomous,
      RecoveryQuotes.tradition4Experience,
    ],
    contemplativePrompts: [
      'How do I balance personal autonomy with responsibility to others in my recovery? Where is that balance most challenging?',
      'Have I ever seen a group or individual act "autonomously" in ways that harmed the broader community? What did that teach you about the limits of independence?',
      'What does responsible freedom look like in my own life today — in my choices, my relationships, my participation in the fellowship?',
    ],
  ),

  // ── Tradition 5 ───────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.tradition,
    number: 5,
    text:
        'Each group has but one primary purpose — to carry its message to the alcoholic who still suffers.',
    title: 'Singleness of Purpose',
    description:
        'The Fifth Tradition asks us to keep the main thing the main thing. '
        'The group\'s purpose is singular: helping the alcoholic who still '
        'suffers. This simplicity protects the group from drift and dilution. '
        'As A.A. has grown and diversified, this tradition has repeatedly '
        'saved the fellowship from becoming something else.\n\n'
        'The message we carry isn\'t complicated — we share our experience, '
        'strength, and hope. What we\'re offering to someone who\'s struggling '
        'is exactly what someone once offered us: a hand, a story, and the '
        'living proof that recovery is possible.',
    themes: ['Purpose', 'Service', 'Simplicity'],
    quotes: [
      RecoveryQuotes.tradition5Lifeline,
      RecoveryQuotes.tradition5Purpose,
    ],
    contemplativePrompts: [
      'What is the "message" of A.A. as I understand it today? How do I try to carry it — at meetings, in my relationships, in the way I live?',
      'When my own thinking gets complicated or heavy, how do I return to what\'s essential? How does singleness of purpose help me simplify?',
      'Who is the "person who still suffers" that I have the most immediate opportunity to help right now? What would it look like to show up for them?',
    ],
  ),

  // ── Tradition 6 ───────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.tradition,
    number: 6,
    text:
        'An A.A. group ought never endorse, finance, or lend the A.A. name to any related '
        'facility or outside enterprise, lest problems of money, property, and prestige '
        'divert us from our primary purpose.',
    title: 'Keeping A.A. Separate',
    description:
        'The Sixth Tradition protects the fellowship from the gravitational pull '
        'of money, property, and prestige. By keeping A.A. separate from outside '
        'enterprises — however well-intentioned — the group preserves its primary '
        'purpose. The tradition doesn\'t judge other organizations; it simply asks '
        'that A.A. not lend its name or resources to them.\n\n'
        'This principle has a deeply personal dimension. In our own lives, we can '
        'notice how easily the pursuit of money, status, or recognition can crowd '
        'out what matters most. The Sixth Tradition invites us to examine our own '
        'relationship with these forces.',
    themes: ['Boundaries', 'Focus', 'Integrity'],
    quotes: [
      RecoveryQuotes.tradition6Outside,
      RecoveryQuotes.tradition6Diversion,
    ],
    contemplativePrompts: [
      'Where in my own life do I need to maintain healthy boundaries to protect what\'s most important to me? What tends to distract me from my primary purpose?',
      'How has the principle of keeping spiritual work separate from money and prestige shown up in my recovery journey? What have I learned from observing others navigate this?',
      'What "outside enterprises" — whether financial, social, or reputational — most tempt me to compromise my integrity or divert my attention?',
    ],
  ),

  // ── Tradition 7 ───────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.tradition,
    number: 7,
    text:
        'Every A.A. group ought to be fully self-supporting, declining outside contributions.',
    title: 'Self-Supporting Through Our Own Contributions',
    description:
        'The Seventh Tradition embodies a kind of spiritual independence: we '
        'accept nothing from outside that could compromise our freedom to serve. '
        'A.A. has declined large financial gifts and outside funding, trusting '
        'that the small contributions of members are enough.\n\n'
        'This tradition has a personal dimension that extends beyond the group: '
        'am I contributing to my own recovery and to A.A., or am I expecting '
        'others to carry me? The spirit of the Seventh Tradition asks us to give '
        'freely of what we have — time, money, experience — because giving is '
        'itself a form of recovery.',
    themes: ['Self-Reliance', 'Contribution', 'Freedom'],
    quotes: [
      RecoveryQuotes.tradition7FreeToServe,
      RecoveryQuotes.tradition7SelfSupport,
    ],
    contemplativePrompts: [
      'How am I contributing to my recovery and to A.A.? In what ways do I give back what was given to me, freely and without expectation?',
      'Have I ever found myself expecting others to carry my recovery for me? What shift in thinking — or action — was required to change that?',
      'What does the principle of self-support suggest about how I approach my daily life — work, finances, relationships? Where am I dependent in ways that don\'t serve me?',
    ],
  ),

  // ── Tradition 8 ───────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.tradition,
    number: 8,
    text:
        'Alcoholics Anonymous should remain forever nonprofessional, but our service '
        'centers may employ special workers.',
    title: 'The Gift of Nonprofessional Help',
    description:
        'The Eighth Tradition preserves something precious: the unique power of '
        'one alcoholic helping another, for free, out of gratitude. When we '
        'professionalize this relationship, we change its nature fundamentally. '
        'The 12 & 12 acknowledges that service workers can be paid, but the heart '
        'of A.A. — one alcoholic talking to another — must never become a '
        'paid service.\n\n'
        'What makes A.A. work is not professional expertise but lived experience. '
        'The newcomer who looks across the table at someone who has been where '
        'they are, and sees them living a different life, receives something no '
        'degree or credential can offer.',
    themes: ['Freely Given', 'Equality', 'Experience'],
    quotes: [
      RecoveryQuotes.tradition8NonProfessional,
      RecoveryQuotes.tradition8FreelyGiven,
    ],
    contemplativePrompts: [
      'What is different about receiving help from someone who has been where I\'ve been, versus receiving professional help? What does each offer that the other cannot?',
      'How do I give freely in my recovery — time, presence, honest sharing — without expectation of gratitude, credit, or reciprocity?',
      'In what areas of my life might I be "professionalizing" a relationship that would be better given freely? Where am I transactional when I could be generous?',
    ],
  ),

  // ── Tradition 9 ───────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.tradition,
    number: 9,
    text:
        'A.A., as such, ought never be organized; but we may create service boards or '
        'committees directly responsible to those they serve.',
    title: 'Service Without Hierarchy',
    description:
        'The Ninth Tradition protects the fellowship from the risks of formal '
        'organization: bureaucracy, power struggles, and institutional self-'
        'preservation. Service committees and boards exist to serve the groups, '
        'not to govern them. No one is "in charge" of A.A. — the program belongs '
        'to all of us equally.\n\n'
        'This tradition has a counterintuitive wisdom: the less formal the '
        'structure, the more resilient the fellowship. By keeping the lines of '
        'authority loose and accountability direct, A.A. has remained adaptable '
        'and resistant to corruption for nearly a century.',
    themes: ['Structure', 'Service', 'Accountability'],
    quotes: [
      RecoveryQuotes.tradition9Accountable,
      RecoveryQuotes.tradition9Organization,
    ],
    contemplativePrompts: [
      'How do I react to authority and organizational structure — in A.A. and in my life generally? What has recovery taught me about the difference between service and control?',
      'What does it look like to serve without seeking power or recognition? Can I name a time I experienced that quality in myself or witnessed it in someone else?',
      'How does the principle of accountability without hierarchy apply to how I manage my own commitments — to myself, to the fellowship, to my relationships?',
    ],
  ),

  // ── Tradition 10 ──────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.tradition,
    number: 10,
    text:
        'Alcoholics Anonymous has no opinion on outside issues; hence the A.A. name '
        'ought never be drawn into public controversy.',
    title: 'Outside Issues & Singleness of Focus',
    description:
        'The Tenth Tradition protects A.A. from controversy. By refusing to take '
        'positions on outside issues — political, social, religious — the fellowship '
        'remains a place where people of every background and viewpoint can belong. '
        'The 12 & 12 traces how involvement in outside controversies nearly '
        'fractured early A.A. groups.\n\n'
        'Neutrality isn\'t indifference; it\'s the deliberate choice to keep the '
        'focus on what A.A. uniquely offers. Members can hold any opinions they '
        'like — A.A. simply does not. This distinction often requires considerable '
        'personal discipline, especially in a polarized world.',
    themes: ['Neutrality', 'Focus', 'Discipline'],
    quotes: [
      RecoveryQuotes.tradition10United,
      RecoveryQuotes.tradition10NoOpinion,
    ],
    contemplativePrompts: [
      'How do I handle strong opinions about "outside issues" in my recovery community? What principles guide me when conversation drifts toward controversy?',
      'Is there an area in my life where I let controversy or strong opinions distract me from what matters most? What would refocusing look like?',
      'What does it look like to hold my convictions firmly while keeping them out of spaces where they don\'t belong? How do I practice that discipline?',
    ],
  ),

  // ── Tradition 11 ──────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.tradition,
    number: 11,
    text:
        'Our public relations policy is based on attraction rather than promotion; we need '
        'always maintain personal anonymity at the level of press, radio, and films.',
    title: 'Attraction, Not Promotion',
    description:
        'The Eleventh Tradition guides how A.A. relates to the world outside: '
        'not by marketing, but by living well. When people see recovered alcoholics '
        'living useful, peaceful lives, that is the most compelling advertisement '
        'possible. Personal anonymity at the public level protects both the '
        'individual and the fellowship.\n\n'
        'No one should become the "face" of A.A. in a way that could cause harm '
        'if they relapse. More deeply, anonymity asks us to let the principles '
        'speak louder than any personality — including our own. There is a '
        'freedom in not needing to be recognized.',
    themes: ['Attraction', 'Anonymity', 'Integrity'],
    quotes: [
      RecoveryQuotes.tradition11EgoStep,
      RecoveryQuotes.tradition11Attraction,
    ],
    contemplativePrompts: [
      'In my own life, how am I "attractive" rather than "promotional" about my recovery? Do I share my story with wisdom and appropriate discretion?',
      'What does personal anonymity protect — for me individually and for the fellowship as a whole? What have I learned about the wisdom of not needing recognition?',
      'How does the principle of attraction rather than promotion apply to how I live my values generally — not just around A.A., but in everything I do?',
    ],
  ),

  // ── Tradition 12 ──────────────────────────────────────────────────────────
  JournalSubjectContent(
    type: JournalSubjectType.tradition,
    number: 12,
    text:
        'Anonymity is the spiritual foundation of all our traditions, ever reminding us '
        'to place principles before personalities.',
    title: 'Anonymity as Spiritual Foundation',
    description:
        'The Twelfth Tradition distills all the traditions into a single spiritual '
        'principle: anonymity is not merely about names and faces. It is about '
        'placing principles above personalities — the principle of recovery above '
        'any individual\'s status, reputation, or preferences.\n\n'
        'Anonymity asks us to check our ego at the door, to remember that we are '
        'fellow travelers, not stars or saviors. The 12 & 12 describes this as the '
        'humility that makes the whole program possible. It is also, paradoxically, '
        'a source of tremendous freedom — we are released from the exhausting need '
        'to be seen, credited, and remembered.',
    themes: ['Anonymity', 'Humility', 'Principles Before Personalities'],
    quotes: [
      RecoveryQuotes.tradition12Anonymity,
      RecoveryQuotes.tradition12Principles,
    ],
    contemplativePrompts: [
      'What does anonymity mean to me beyond protecting my name? How does it function as a spiritual principle — a practice of ego-release — in my daily life?',
      'Are there ways in which I put "personality" (my own or others\') ahead of principles in my recovery or my relationships? What would it look like to change that?',
      'How has the practice of anonymity and placing principles first shaped who I am? What have I found in the freedom of remaining "right-sized"?',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Public accessors
// ─────────────────────────────────────────────────────────────────────────────

class StepTraditionContent {
  StepTraditionContent._();

  /// All 12 steps in order (index 0 = Step 1).
  static const List<JournalSubjectContent> steps = _steps;

  /// All 12 traditions in order (index 0 = Tradition 1).
  static const List<JournalSubjectContent> traditions = _traditions;

  /// Returns content for a step number (1–12), or null if out of range.
  static JournalSubjectContent? forStep(int number) {
    if (number < 1 || number > 12) return null;
    return _steps[number - 1];
  }

  /// Returns content for a tradition number (1–12), or null if out of range.
  static JournalSubjectContent? forTradition(int number) {
    if (number < 1 || number > 12) return null;
    return _traditions[number - 1];
  }
}
