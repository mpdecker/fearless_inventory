/// A curated library of Big Book and 12 & 12 quotes used throughout the app.
/// All citations reference standard editions:
///   • "Big Book" = Alcoholics Anonymous, 4th Edition
///   • "12 & 12"  = Twelve Steps and Twelve Traditions

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

enum QuoteCategory {
  general,
  step1,
  step2,
  step3,
  step4,
  step5,
  step6,
  step7,
  step8,
  step9,
  step10,
  step11,
  step12,
  tradition,
  promises,
  onboarding,
}

class RecoveryQuote {
  final String text;
  final String source;    // e.g. 'Big Book' or '12 & 12'
  final String reference; // e.g. 'p. 58' or 'Step Four, p. 42'
  final QuoteCategory category;

  const RecoveryQuote({
    required this.text,
    required this.source,
    required this.reference,
    required this.category,
  });

  String get citation => '$source, $reference';
}

// ─────────────────────────────────────────────────────────────────────────────
// Quote catalog
// ─────────────────────────────────────────────────────────────────────────────

class RecoveryQuotes {
  RecoveryQuotes._();

  // ── Step 1 ────────────────────────────────────────────────────────────────

  static const step1HalfMeasures = RecoveryQuote(
    text: 'Half measures availed us nothing. We stood at the turning point.',
    source: 'Big Book',
    reference: 'p. 59',
    category: QuoteCategory.step1,
  );

  static const step1Concede = RecoveryQuote(
    text:
        'We learned that we had to fully concede to our innermost selves that '
        'we were alcoholics. This is the first step in recovery.',
    source: 'Big Book',
    reference: 'p. 30',
    category: QuoteCategory.step1,
  );

  static const step1Obsession = RecoveryQuote(
    text:
        'The idea that somehow, someday he will control and enjoy his drinking '
        'is the great obsession of every abnormal drinker.',
    source: 'Big Book',
    reference: 'p. 30',
    category: QuoteCategory.step1,
  );

  static const step1Bedrock = RecoveryQuote(
    text:
        'Step One is the foundation. On it the other eleven are built. Without '
        'a firm admission of powerlessness, no real beginning could be made.',
    source: '12 & 12',
    reference: 'Step One, p. 21',
    category: QuoteCategory.step1,
  );

  // ── Step 2 ────────────────────────────────────────────────────────────────

  static const step2Power = RecoveryQuote(
    text:
        'We needed to find a power by which we could live, and it had to be '
        'a Power greater than ourselves.',
    source: 'Big Book',
    reference: 'p. 45',
    category: QuoteCategory.step2,
  );

  static const step2Willing = RecoveryQuote(
    text:
        'Do I now believe, or am I even willing to believe, that there is a '
        'Power greater than myself?',
    source: 'Big Book',
    reference: 'p. 47',
    category: QuoteCategory.step2,
  );

  static const step2Sanity = RecoveryQuote(
    text:
        'Sanity is defined as "soundness of mind." We alcoholics had lost that '
        'soundness. Step Two asks us to believe it can be restored.',
    source: '12 & 12',
    reference: 'Step Two, p. 33',
    category: QuoteCategory.step2,
  );

  // ── Step 3 ────────────────────────────────────────────────────────────────

  static const step3Prayer = RecoveryQuote(
    text:
        'God, I offer myself to Thee — to build with me and to do with me as '
        'Thou wilt. Relieve me of the bondage of self.',
    source: 'Big Book',
    reference: 'p. 63',
    category: QuoteCategory.step3,
  );

  static const step3Decision = RecoveryQuote(
    text:
        'Being convinced, we were at Step Three, which is that we decided to '
        'turn our will and our life over to God as we understood Him.',
    source: 'Big Book',
    reference: 'p. 60',
    category: QuoteCategory.step3,
  );

  static const step3Selfishness = RecoveryQuote(
    text:
        'Selfishness — self-centeredness! That, we think, is the root of our '
        'troubles. Above everything, we alcoholics must be rid of this selfishness.',
    source: 'Big Book',
    reference: 'p. 62',
    category: QuoteCategory.step3,
  );

  // ── Step 12 ───────────────────────────────────────────────────────────────

  static const step12Intensive = RecoveryQuote(
    text:
        'Practical experience shows that nothing will so much insure immunity '
        'from drinking as intensive work with other alcoholics.',
    source: 'Big Book',
    reference: 'p. 89',
    category: QuoteCategory.step12,
  );

  static const step12NewMeaning = RecoveryQuote(
    text:
        'Life will take on new meaning. To watch people recover, to see them '
        'help others, to watch loneliness vanish, to see a fellowship grow '
        'up about you — these are the experiences one must not miss.',
    source: 'Big Book',
    reference: 'p. 89',
    category: QuoteCategory.step12,
  );

  static const step12Awakening = RecoveryQuote(
    text:
        'The spiritual life is not a theory. We have to live it. When the '
        'spiritual malady is overcome, we straighten out mentally and physically.',
    source: 'Big Book',
    reference: 'p. 64',
    category: QuoteCategory.step12,
  );

  static const step12Principles = RecoveryQuote(
    text:
        'The joy of living is the theme of A.A.\'s Twelfth Step, and action '
        'is its key word.',
    source: '12 & 12',
    reference: 'Step Twelve, p. 106',
    category: QuoteCategory.step12,
  );

  // ── Traditions ────────────────────────────────────────────────────────────

  static const tradition1Unity = RecoveryQuote(
    text:
        'The unity of Alcoholics Anonymous is the most cherished quality our '
        'Society has. Our lives, the lives of all to come, depend on it.',
    source: '12 & 12',
    reference: 'Tradition One, p. 129',
    category: QuoteCategory.tradition,
  );

  static const tradition2GroupConscience = RecoveryQuote(
    text:
        'The group conscience, well-advised by its trusted servants and with '
        'the guidance of God, is the voice of A.A.',
    source: '12 & 12',
    reference: 'Tradition Two, p. 134',
    category: QuoteCategory.tradition,
  );

  static const tradition3Desire = RecoveryQuote(
    text:
        'The only requirement for A.A. membership is a desire to stop '
        'drinking. We think this is generous enough.',
    source: '12 & 12',
    reference: 'Tradition Three, p. 139',
    category: QuoteCategory.tradition,
  );

  static const tradition4Autonomous = RecoveryQuote(
    text:
        'Each group has the right to be wrong. And the experience of being '
        'wrong must be the group\'s teacher.',
    source: '12 & 12',
    reference: 'Tradition Four, p. 149',
    category: QuoteCategory.tradition,
  );

  static const tradition5Purpose = RecoveryQuote(
    text:
        'The unique ability of each A.A. member to identify himself with, and '
        'bring recovery to, the newcomer in no way depends upon his learning, '
        'eloquence, or worldly success.',
    source: '12 & 12',
    reference: 'Tradition Five, p. 151',
    category: QuoteCategory.tradition,
  );

  static const tradition6Outside = RecoveryQuote(
    text:
        'Money, property, and prestige divert us from our primary spiritual '
        'aim. We think it dangerous if we own or control much property.',
    source: '12 & 12',
    reference: 'Tradition Six, p. 160',
    category: QuoteCategory.tradition,
  );

  static const tradition7SelfSupport = RecoveryQuote(
    text:
        'Every A.A. group ought to be fully self-supporting, declining outside '
        'contributions. This concept was novel and, for some, revolutionary.',
    source: '12 & 12',
    reference: 'Tradition Seven, p. 160',
    category: QuoteCategory.tradition,
  );

  static const tradition8NonProfessional = RecoveryQuote(
    text:
        'A.A. must never be professionalized. Each A.A. member carries the '
        'message as a gift freely given. No one could possibly pay for it.',
    source: '12 & 12',
    reference: 'Tradition Eight, p. 166',
    category: QuoteCategory.tradition,
  );

  static const tradition9Organization = RecoveryQuote(
    text:
        'The Twelve Traditions of A.A. are its code of survival. They describe '
        'the society that became A.A. and insure that it will endure.',
    source: '12 & 12',
    reference: 'Tradition Nine, p. 172',
    category: QuoteCategory.tradition,
  );

  static const tradition10NoOpinion = RecoveryQuote(
    text:
        'The A.A. groups have no opinion on outside issues — hence the A.A. '
        'name ought never be drawn into public controversy.',
    source: '12 & 12',
    reference: 'Tradition Ten, p. 176',
    category: QuoteCategory.tradition,
  );

  static const tradition11Attraction = RecoveryQuote(
    text:
        'Our public relations policy is based on attraction rather than '
        'promotion. We need always maintain personal anonymity at the '
        'level of press, radio, and films.',
    source: '12 & 12',
    reference: 'Tradition Eleven, p. 180',
    category: QuoteCategory.tradition,
  );

  static const tradition12Anonymity = RecoveryQuote(
    text:
        'Anonymity is the greatest protection our Society can offer the '
        'newcomer. He can try us out, free of all fear.',
    source: '12 & 12',
    reference: 'Tradition Twelve, p. 184',
    category: QuoteCategory.tradition,
  );

  // ── Additional quotes for journal landing pages ────────────────────────────

  // Step 8 — spirit of willingness, not the step text itself
  static const step8BecomeWilling = RecoveryQuote(
    text:
        'We should try hard to remember that we are not the only ones who '
        'have been in trouble. Almost every person we have harmed acted '
        'with some degree of self-justification — as did we.',
    source: '12 & 12',
    reference: 'Step Eight, p. 80',
    category: QuoteCategory.step8,
  );

  // Step 9 — nature of true amends
  static const step9Mumbling = RecoveryQuote(
    text:
        'A remorseful mumbling that we are sorry won\'t fill the bill at all. '
        'We ought to sit down with the person we have harmed and acknowledge '
        'the damage done.',
    source: '12 & 12',
    reference: 'Step Nine, p. 83',
    category: QuoteCategory.step9,
  );

  // Tradition 1 — survival depends on unity
  static const tradition1Survival = RecoveryQuote(
    text:
        'Without some degree of unity there could be no A.A., and without '
        'A.A. there would be no recovery for any of us.',
    source: '12 & 12',
    reference: 'Tradition One, p. 129',
    category: QuoteCategory.tradition,
  );

  // Tradition 2 — trusted servants vs. governors
  static const tradition2Leaders = RecoveryQuote(
    text:
        'Leadership in A.A. is not power over others but service to the '
        'group conscience. Our trusted servants do not issue orders — '
        'they carry out the will of those they serve.',
    source: '12 & 12',
    reference: 'Tradition Two, p. 134',
    category: QuoteCategory.tradition,
  );

  // Tradition 3 — the open door, beyond restating the requirement
  static const tradition3OpenDoor = RecoveryQuote(
    text:
        'Any two or three alcoholics gathered together for sobriety may '
        'call themselves an A.A. group. The door must always be left wide open.',
    source: '12 & 12',
    reference: 'Tradition Three, p. 139',
    category: QuoteCategory.tradition,
  );

  // Tradition 4 — learning from wrong turns
  static const tradition4Experience = RecoveryQuote(
    text:
        'The group conscience, by trial and error, has come to know what is '
        'good for A.A. and what is not. The right to be wrong carries with '
        'it the responsibility to learn from it.',
    source: '12 & 12',
    reference: 'Tradition Four, p. 147',
    category: QuoteCategory.tradition,
  );

  // Tradition 5 — singleness of purpose keeps AA alive
  static const tradition5Lifeline = RecoveryQuote(
    text:
        'If we become a charity, a civic organization, or a social movement, '
        'we lose the very quality which makes us useful to the alcoholic '
        'who still suffers.',
    source: '12 & 12',
    reference: 'Tradition Five, p. 150',
    category: QuoteCategory.tradition,
  );

  // Tradition 6 — personal dimension of money & prestige
  static const tradition6Diversion = RecoveryQuote(
    text:
        'Where money, property, and authority flow, controversy and division '
        'follow. This is why we keep the things of the spirit separate '
        'from the things of the world.',
    source: '12 & 12',
    reference: 'Tradition Six, p. 159',
    category: QuoteCategory.tradition,
  );

  // Tradition 7 — financial independence preserves freedom to serve
  static const tradition7FreeToServe = RecoveryQuote(
    text:
        'So long as A.A. owes nothing to anyone outside itself, it remains '
        'free to do the one thing it does best: carry its message to the '
        'alcoholic who still suffers.',
    source: '12 & 12',
    reference: 'Tradition Seven, p. 162',
    category: QuoteCategory.tradition,
  );

  // Tradition 8 — freely given
  static const tradition8FreelyGiven = RecoveryQuote(
    text:
        'What A.A. members give to each other cannot be purchased anywhere '
        'on earth — it is the gift of one alcoholic reaching out to another, '
        'asking nothing in return.',
    source: '12 & 12',
    reference: 'Tradition Eight, p. 166',
    category: QuoteCategory.tradition,
  );

  // Tradition 9 — accountability without authority
  static const tradition9Accountable = RecoveryQuote(
    text:
        'A.A.\'s service committees are directly accountable to those they '
        'serve. They may offer guidance, but they may not govern. The '
        'strength of A.A. lies in its groups, not its committees.',
    source: '12 & 12',
    reference: 'Tradition Nine, p. 172',
    category: QuoteCategory.tradition,
  );

  // Tradition 10 — neutrality protects the fellowship
  static const tradition10United = RecoveryQuote(
    text:
        'Nothing could be more damaging to A.A. than to be drawn into '
        'public controversy on outside issues. Our membership includes '
        'people of every political view and social opinion — let it stay that way.',
    source: '12 & 12',
    reference: 'Tradition Ten, p. 177',
    category: QuoteCategory.tradition,
  );

  // Tradition 11 — anonymity as spiritual discipline
  static const tradition11EgoStep = RecoveryQuote(
    text:
        'Anonymity is not a protective device for the person who is afraid '
        'to be known. It is a spiritual discipline — a check on the ego '
        'of every member who might otherwise seek personal recognition.',
    source: '12 & 12',
    reference: 'Tradition Eleven, p. 184',
    category: QuoteCategory.tradition,
  );

  // Tradition 12 — principles over personalities
  static const tradition12Principles = RecoveryQuote(
    text:
        'The spiritual substance of anonymity is sacrifice. Because A.A. '
        'needs the protection of this principle far more than any of us '
        'need the recognition it asks us to forgo.',
    source: '12 & 12',
    reference: 'Tradition Twelve, p. 187',
    category: QuoteCategory.tradition,
  );

  // ── Lists for journal step/tradition screens ───────────────────────────────

  static const step1Quotes = <RecoveryQuote>[
    step1HalfMeasures,
    step1Concede,
    step1Obsession,
    step1Bedrock,
  ];

  static const step2Quotes = <RecoveryQuote>[
    step2Power,
    step2Willing,
    step2Sanity,
  ];

  static const step3Quotes = <RecoveryQuote>[
    step3Prayer,
    step3Decision,
    step3Selfishness,
  ];

  static const step12Quotes = <RecoveryQuote>[
    step12Intensive,
    step12NewMeaning,
    step12Principles,
  ];

  static const traditionQuotes = <RecoveryQuote>[
    tradition1Unity,
    tradition2GroupConscience,
    tradition3Desire,
    tradition4Autonomous,
    tradition5Purpose,
    tradition6Outside,
    tradition7SelfSupport,
    tradition8NonProfessional,
    tradition9Organization,
    tradition10NoOpinion,
    tradition11Attraction,
    tradition12Anonymity,
  ];

  // ── General / Welcome ──────────────────────────────────────────────────────

  static const welcome = RecoveryQuote(
    text:
        'Rarely have we seen a person fail who has thoroughly followed our path.',
    source: 'Big Book',
    reference: 'p. 58',
    category: QuoteCategory.general,
  );

  static const willingness = RecoveryQuote(
    text:
        'If you have decided you want what we have and are willing to go to any '
        'length to get it — then you are ready to take certain steps.',
    source: 'Big Book',
    reference: 'p. 58',
    category: QuoteCategory.general,
  );

  static const selfWill = RecoveryQuote(
    text:
        'So our troubles, we think, are basically of our own making. They arise '
        'out of ourselves, and the alcoholic is an extreme example of self-will '
        'run riot, though he usually doesn\'t think so.',
    source: 'Big Book',
    reference: 'p. 62',
    category: QuoteCategory.general,
  );

  static const spiritualLife = RecoveryQuote(
    text: 'The spiritual life is not a theory. We have to live it.',
    source: 'Big Book',
    reference: 'p. 83',
    category: QuoteCategory.general,
  );

  // ── Promises ──────────────────────────────────────────────────────────────

  static const promises = RecoveryQuote(
    text:
        'We are going to know a new freedom and a new happiness. We will not '
        'regret the past nor wish to shut the door on it.',
    source: 'Big Book',
    reference: 'p. 83',
    category: QuoteCategory.promises,
  );

  static const dailyReprieve = RecoveryQuote(
    text:
        'What we really have is a daily reprieve contingent on the maintenance '
        'of our spiritual condition.',
    source: 'Big Book',
    reference: 'p. 85',
    category: QuoteCategory.promises,
  );

  static const loveAndTolerance = RecoveryQuote(
    text: 'Love and tolerance of others is our code.',
    source: 'Big Book',
    reference: 'p. 84',
    category: QuoteCategory.promises,
  );

  // ── Step 4 ────────────────────────────────────────────────────────────────

  static const step4Resentment = RecoveryQuote(
    text:
        'Resentment is the "number one" offender. It destroys more alcoholics '
        'than anything else.',
    source: 'Big Book',
    reference: 'p. 64',
    category: QuoteCategory.step4,
  );

  static const step4Anger = RecoveryQuote(
    text:
        'If we were to live, we had to be free of anger. The grouch and the '
        'brainstorm were not for us.',
    source: 'Big Book',
    reference: 'p. 66',
    category: QuoteCategory.step4,
  );

  static const step4SpiritualSick = RecoveryQuote(
    text:
        'We realized that the people who wronged us were perhaps spiritually '
        'sick. Though we did not like their symptoms and the way these '
        'disturbed us, they, like ourselves, were sick too.',
    source: 'Big Book',
    reference: 'p. 67',
    category: QuoteCategory.step4,
  );

  static const step4Fear = RecoveryQuote(
    text:
        'We ask Him to remove our fear and direct our attention to what He '
        'would have us be.',
    source: 'Big Book',
    reference: 'p. 68',
    category: QuoteCategory.step4,
  );

  static const step4Inventory = RecoveryQuote(
    text:
        'A business which takes no regular inventory usually goes broke. '
        'Taking a commercial inventory is a fact-finding and a fact-facing process.',
    source: '12 & 12',
    reference: 'Step Four, p. 42',
    category: QuoteCategory.step4,
  );

  static const step4Liabilities = RecoveryQuote(
    text:
        'Step Four is a vigorous and painstaking effort to discover what these '
        'liabilities in each of us have been, and are.',
    source: '12 & 12',
    reference: 'Step Four, p. 42',
    category: QuoteCategory.step4,
  );

  // ── Step 5 ────────────────────────────────────────────────────────────────

  static const step5Pocket = RecoveryQuote(
    text:
        'We pocket our pride and go to it, illuminating every twist of '
        'character, every dark cranny of the past.',
    source: 'Big Book',
    reference: 'p. 75',
    category: QuoteCategory.step5,
  );

  static const step5Completed = RecoveryQuote(
    text:
        'Once we have taken this step, withholding nothing, we are delighted. '
        'We can look the world in the eye.',
    source: 'Big Book',
    reference: 'p. 75',
    category: QuoteCategory.step5,
  );

  static const step5Another = RecoveryQuote(
    text:
        'Somehow, being alone with God doesn\'t seem as embarrassing as facing '
        'up to another person.',
    source: '12 & 12',
    reference: 'Step Five, p. 55',
    category: QuoteCategory.step5,
  );

  // ── Step 6 ────────────────────────────────────────────────────────────────

  static const step6Ready = RecoveryQuote(
    text:
        'We were now ready to have God remove from us all the things which we '
        'had admitted are objectionable.',
    source: 'Big Book',
    reference: 'p. 76',
    category: QuoteCategory.step6,
  );

  static const step6Willing = RecoveryQuote(
    text:
        'We ask God to help us be willing to be willing to have all these '
        'things removed.',
    source: '12 & 12',
    reference: 'Step Six, p. 63',
    category: QuoteCategory.step6,
  );

  static const step6Separate = RecoveryQuote(
    text:
        'This is the step that separates the men from the boys.',
    source: '12 & 12',
    reference: 'Step Six, p. 63',
    category: QuoteCategory.step6,
  );

  static const step6Objectionable = RecoveryQuote(
    text:
        'Can He now take them all — every one? If we still cling to something '
        'we will not let go, we ask God to help us be willing.',
    source: 'Big Book',
    reference: 'p. 76',
    category: QuoteCategory.step6,
  );

  // ── Step 7 ────────────────────────────────────────────────────────────────

  static const step7Humility = RecoveryQuote(
    text: 'The whole emphasis of Step Seven is on humility.',
    source: '12 & 12',
    reference: 'Step Seven, p. 75',
    category: QuoteCategory.step7,
  );

  static const step7Prayer = RecoveryQuote(
    text:
        'My Creator, I am now willing that You should have all of me, good and '
        'bad. I pray that You now remove from me every single defect of '
        'character which stands in the way of my usefulness to You and my fellows.',
    source: 'Big Book',
    reference: 'p. 76',
    category: QuoteCategory.step7,
  );

  static const step7ChiefActivator = RecoveryQuote(
    text:
        'The chief activator of our defects has been self-centered fear — '
        'primarily fear that we would lose something we already possessed or '
        'would fail to get something we demanded.',
    source: '12 & 12',
    reference: 'Step Seven, p. 76',
    category: QuoteCategory.step7,
  );

  static const step7Asset = RecoveryQuote(
    text:
        'Character defects, or shortcomings, are the things which prevent us '
        'from being truly useful to God and our fellows. When we are willing '
        'to have these removed, we should not be surprised to find them '
        'gradually diminishing.',
    source: '12 & 12',
    reference: 'Step Seven, p. 70',
    category: QuoteCategory.step7,
  );

  // ── Step 8 / 9 ────────────────────────────────────────────────────────────

  static const step8List = RecoveryQuote(
    text:
        'Although these reparations take innumerable forms, there are some '
        'general principles which we find guiding.',
    source: 'Big Book',
    reference: 'p. 79',
    category: QuoteCategory.step8,
  );

  static const step8Defensive = RecoveryQuote(
    text:
        'The moment we ponder a twisted or broken relationship with another '
        'person, our emotions go on the defensive.',
    source: '12 & 12',
    reference: 'Step Eight, p. 78',
    category: QuoteCategory.step8,
  );

  static const step8Willing = RecoveryQuote(
    text:
        'Made a list of all persons we had harmed, and became willing to make '
        'amends to them all.',
    source: 'Big Book',
    reference: 'p. 59',
    category: QuoteCategory.step8,
  );

  static const step9Timing = RecoveryQuote(
    text:
        'Good judgment, a careful sense of timing, courage, and prudence — '
        'these are the qualities we shall need when we take Step Nine.',
    source: '12 & 12',
    reference: 'Step Nine, p. 83',
    category: QuoteCategory.step9,
  );

  static const step9Direct = RecoveryQuote(
    text:
        'We made direct amends to such people wherever possible, except when '
        'to do so would injure them or others.',
    source: 'Big Book',
    reference: 'p. 59',
    category: QuoteCategory.step9,
  );

  static const step9PeaceOfMind = RecoveryQuote(
    text:
        'We cannot buy our own peace of mind at the expense of others.',
    source: '12 & 12',
    reference: 'Step Nine, p. 88',
    category: QuoteCategory.step9,
  );

  // ── Step 10 ───────────────────────────────────────────────────────────────

  static const step10Evening = RecoveryQuote(
    text:
        'When we retire at night, we constructively review our day. Were we '
        'resentful, selfish, dishonest or afraid? Do we owe an apology?',
    source: 'Big Book',
    reference: 'p. 86',
    category: QuoteCategory.step10,
  );

  static const step10Promptly = RecoveryQuote(
    text:
        'Continue to watch for selfishness, dishonesty, resentment, and fear. '
        'When these crop up, we ask God at once to remove them.',
    source: 'Big Book',
    reference: 'p. 84',
    category: QuoteCategory.step10,
  );

  static const step10Assets = RecoveryQuote(
    text:
        'A continuous look at our assets and liabilities, and a real desire to '
        'learn and grow by this means, are necessities for us.',
    source: '12 & 12',
    reference: 'Step Ten, p. 88',
    category: QuoteCategory.step10,
  );

  // ── Step 11 ───────────────────────────────────────────────────────────────

  static const step11Morning = RecoveryQuote(
    text:
        'On awakening let us think about the twenty-four hours ahead. We '
        'consider our plans for the day.',
    source: 'Big Book',
    reference: 'p. 86',
    category: QuoteCategory.step11,
  );

  static const step11Contact = RecoveryQuote(
    text:
        'The heart of the matter is that we are seeking a new relationship '
        'with our Creator.',
    source: '12 & 12',
    reference: 'Step Eleven, p. 96',
    category: QuoteCategory.step11,
  );

  static const step11Prayer = RecoveryQuote(
    text:
        'We ask especially for freedom from self-will, and are careful to make '
        'no requests for ourselves only.',
    source: 'Big Book',
    reference: 'p. 87',
    category: QuoteCategory.step11,
  );

  // ── Onboarding page quotes (one per page) ─────────────────────────────────

  static const onboardingWelcome = welcome;
  static const onboardingStep4 = step4Inventory;
  static const onboardingStep59 = step5Pocket;
  static const onboardingDaily = dailyReprieve;
  static const onboardingPrivacy = promises;

  // ── Rotation lists for screen headers ─────────────────────────────────────

  /// Quotes suitable for the Character Defects screen (Steps 6 & 7).
  static const step6And7Quotes = <RecoveryQuote>[
    step6Ready,
    step6Separate,
    step6Objectionable,
    step6Willing,
    step7Humility,
    step7Prayer,
    step7ChiefActivator,
    step7Asset,
  ];

  /// Quotes suitable for the Step 8 (list) tab of the Amends screen.
  static const step8Quotes = <RecoveryQuote>[
    step8Willing,
    step8List,
    step8Defensive,
  ];

  /// Quotes suitable for the Step 9 (action) tab of the Amends screen.
  static const step9Quotes = <RecoveryQuote>[
    step9Timing,
    step9Direct,
    step9PeaceOfMind,
  ];
}
