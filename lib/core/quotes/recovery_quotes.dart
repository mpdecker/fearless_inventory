/// A curated library of Big Book and 12 & 12 quotes used throughout the app.
/// All citations reference standard editions:
///   • "Big Book" = Alcoholics Anonymous, 4th Edition
///   • "12 & 12"  = Twelve Steps and Twelve Traditions

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

enum QuoteCategory {
  general,
  step4,
  step5,
  step6,
  step7,
  step8,
  step9,
  step10,
  step11,
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
