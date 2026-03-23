/// Canonical character defects referenced in the Big Book and
/// 12 Steps & 12 Traditions.
///
/// Organised into three categories used throughout the Step 6 / 7 workflow.
/// These are offered as quick-select chips in the Discovery Wizard and as
/// fallback dropdown entries in the Shortcoming Log sheet so the user always
/// has options even before building a personal defect catalog.
class CharacterDefects {
  CharacterDefects._();

  // ── Seven Deadly Sins (12&12 Step 6) ──────────────────────────────────────

  static const List<String> sevenDeadlySins = [
    'Pride',
    'Greed',
    'Lust',
    'Anger',
    'Gluttony',
    'Envy',
    'Sloth',
  ];

  // ── Big Book core (pp. 62–63) ─────────────────────────────────────────────

  static const List<String> bigBookCore = [
    'Selfishness',
    'Self-Seeking',
    'Dishonesty',
    'Fear',
    'Self-Pity',
    'Resentment',
  ];

  // ── Common patterns (12&12 and widely used in step work) ──────────────────

  static const List<String> commonPatterns = [
    'Jealousy',
    'Procrastination',
    'Perfectionism',
    'People-Pleasing',
    'Controlling',
    'Impatience',
    'Intolerance',
    'Cowardice',
    'Laziness',
    'Vanity',
    'Gossip',
    'Grandiosity',
    'Manipulation',
    'Isolation',
  ];

  // ── Combined list in display order ────────────────────────────────────────

  /// All defects in display order: 7 Deadly Sins → Big Book core → common.
  static List<String> get all => [
        ...sevenDeadlySins,
        ...bigBookCore,
        ...commonPatterns,
      ];
}
