import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/navigation/adaptive_page_route.dart';
import '../../core/widgets/app_dialogs.dart';

// Feature Imports
import '../review/daily_review_hub_screen.dart';
import '../../core/quotes/recovery_quotes.dart';
import '../../core/widgets/quote_card.dart';
import '../amends/amends_list_screen.dart';
import '../insights/recovery_insights_screen.dart';
import '../meetings/meetings_screen.dart';
import '../settings/settings_screen.dart';
import '../review/providers/streak_provider.dart';
import '../../core/providers/sobriety_provider.dart';
import '../../core/services/sobriety_service.dart';
import '../../core/services/onboarding_service.dart';

// Stepwork Imports
import '../stepwork/step_4_landing_screen.dart';
import '../stepwork/defect_management_screen.dart';
import '../stepwork/shortcoming_dashboard_screen.dart';
import '../stepwork/step_11_meditation_screen.dart';
import '../stepwork/bedtime_meditation_screen.dart';
import '../stepwork/step12_screen.dart';

// Journal
import '../journal/screens/journal_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  /// Tracks which tab intros have been shown this session to prevent
  /// double-firing if the user taps quickly before the async check completes.
  final Set<int> _introShownThisSession = {};

  // Callback to allow child views to request a tab switch by index.
  void _onTabRequest(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _onDestinationSelected(int index) async {
    setState(() => _selectedIndex = index);
    // Dashboard (0) never gets an intro; ignore already-shown tabs.
    if (index == 0 || _introShownThisSession.contains(index)) return;
    // Guard immediately to prevent double-show on rapid taps.
    _introShownThisSession.add(index);
    final alreadyVisited = await OnboardingService.hasVisitedTab(index);
    if (alreadyVisited || !mounted) return;
    await OnboardingService.markTabVisited(index);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TabIntroSheet(tabIndex: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomeDashboardView(onTabRequest: _onTabRequest), // 0 — Dashboard
      const MeetingsScreen(),                          // 1 — Meetings
      const Step12Screen(),                            // 2 — Step 12
      const JournalTab(),                              // 3 — Journal
      const RecoveryInsightsScreen(),                  // 4 — Insights
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Companion',
          style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              adaptivePageRoute((_) => const SettingsScreen()),
            ),
          )
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Meetings'),
          NavigationDestination(icon: Icon(Icons.diversity_3_outlined), label: 'Step 12'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Journal'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Insights'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab first-visit intro sheets
// ─────────────────────────────────────────────────────────────────────────────

class _TabIntroData {
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  const _TabIntroData({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
  });
}

const _kTabIntros = <int, _TabIntroData>{
  // ── 1. Meetings ──────────────────────────────────────────────────────────
  1: _TabIntroData(
    title: 'Your Meeting Life',
    body:
        'Search AA, NA, and OA meetings near you or anywhere in the world. '
        'Bookmark your home group, save favorites, and mark meetings for '
        'planned attendance — they show up on your Step 12 service calendar '
        'as recurring weekly events so your commitments stay visible.',
    icon: Icons.groups_outlined,
    color: Color(0xFF1A56DB),
  ),
  // ── 2. Step 12 ────────────────────────────────────────────────────────────
  2: _TabIntroData(
    title: 'Service & Fellowship',
    body:
        'The joy of living is the theme of the Twelfth Step, and action is '
        'its key word. Log your 12th Step calls, track service commitments, '
        'and manage your sponsees here. The calendar keeps your service life '
        'organized alongside your planned meeting attendance.',
    icon: Icons.diversity_3_outlined,
    color: Color(0xFF00695C),
  ),
  // ── 3. Journal ────────────────────────────────────────────────────────────
  3: _TabIntroData(
    title: 'Your Recovery Journal',
    body:
        'Write freely or work through guided prompts anchored to any step or '
        'tradition. Entries are linked to your step work, searchable by '
        'subject, and exportable as a formatted PDF — useful for Step 5 '
        'preparation or sharing reflections with your sponsor.',
    icon: Icons.menu_book_outlined,
    color: Color(0xFF4527A0),
  ),
  // ── 4. Insights ───────────────────────────────────────────────────────────
  4: _TabIntroData(
    title: 'Recovery at a Glance',
    body:
        'Honest data for honest reflection. See your Step 10 review streak, '
        'inventory patterns over time, and your meditation history. Sobriety '
        'milestones and trend charts help you and your sponsor spot growth — '
        'and blind spots — across days, months, and years.',
    icon: Icons.insights_outlined,
    color: Color(0xFFB45309),
  ),
};

class _TabIntroSheet extends StatelessWidget {
  final int tabIndex;
  const _TabIntroSheet({required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final intro = _kTabIntros[tabIndex];
    if (intro == null) return const SizedBox.shrink();

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(28, 16, 28, bottomPadding + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Icon ─────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: intro.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(intro.icon, color: intro.color, size: 32),
          ),
          const SizedBox(height: 16),

          // ── Title ─────────────────────────────────────────────────────────
          Text(
            intro.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // ── Body ──────────────────────────────────────────────────────────
          Text(
            intro.body,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),

          // ── CTA ───────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: intro.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Got it',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeDashboardView extends StatelessWidget {
  final Function(int) onTabRequest;

  const _HomeDashboardView({required this.onTabRequest});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const _SobrietyCard(),
        const _StreakHeader(),
        const _DailyQuoteBanner(),

        // DAILY MAINTENANCE
        _buildSectionHeader("DAILY MAINTENANCE"),
        _buildActionCard(
          context: context,
          title: "Step 11: Morning Meditation",
          subtitle: "Seeking through prayer & meditation",
          icon: Icons.wb_sunny_outlined,
          color: Colors.orange.shade800,
          onTap: () => Navigator.push(
            context,
            adaptivePageRoute((_) => Step11MeditationScreen()),
          ),
        ),
        _buildActionCard(
          context: context,
          title: "Step 10: Evening Review",
          subtitle: "Continued to take personal inventory",
          icon: Icons.nightlight_round_outlined,
          color: Colors.indigo.shade800,
          onTap: () => Navigator.push(
            context,
            adaptivePageRoute((_) => const DailyReviewHubScreen()),
          ),
        ),
        _buildActionCard(
          context: context,
          title: "Step 11: Bedtime Meditation",
          subtitle: "Wind down — trust, gratitude, and rest",
          icon: Icons.bedtime_outlined,
          color: Colors.deepPurple.shade700,
          onTap: () => Navigator.push(
            context,
            adaptivePageRoute((_) => const BedtimeMeditationScreen()),
          ),
        ),

        const SizedBox(height: 16),
        
        // ACTIVE STEPWORK
        _buildSectionHeader("ACTIVE STEPWORK"),
        _buildActionCard(
          context: context,
          title: "Step 4: Moral Inventory",
          subtitle: "Resentments, Fears, & Harms",
          icon: Icons.assignment_outlined,
          color: Colors.redAccent.shade700,
          onTap: () => Navigator.push(
            context,
            adaptivePageRoute((_) => Step4LandingScreen()),
          ),
        ),
        _buildActionCard(
          context: context,
          title: "Step 6: Character Defects",
          subtitle: "Entirely ready for removal",
          icon: Icons.auto_awesome_mosaic_outlined,
          color: Colors.purple.shade700,
          onTap: () => Navigator.push(
            context,
            adaptivePageRoute((_) => const DefectManagementScreen()),
          ),
        ),
        _buildActionCard(
          context: context,
          title: "Step 7: Shortcomings",
          subtitle: "Humbly asked Him to remove",
          icon: Icons.self_improvement,
          color: Colors.teal.shade700,
          onTap: () => Navigator.push(
            context,
            adaptivePageRoute((_) => const ShortcomingDashboardScreen()),
          ),
        ),
        _buildActionCard(
          context: context,
          title: "Steps 8 & 9: Amends",
          subtitle: "List, willingness, and action plans",
          icon: Icons.handshake_outlined,
          color: Colors.blueGrey.shade700,
          onTap: () => Navigator.push(
            context,
            adaptivePageRoute((_) => const AmendsListScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Builder(
      builder: (context) {
        final muted = Theme.of(context).colorScheme.onSurface.withOpacity(0.65);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: muted,
              letterSpacing: 1.1,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final outline = Theme.of(context).colorScheme.outline.withOpacity(0.35);
        final subtitleColor =
            Theme.of(context).colorScheme.onSurface.withOpacity(0.72);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: outline),
          ),
          child: ListTile(
            onTap: onTap,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(subtitle,
                style: TextStyle(color: subtitleColor, fontSize: 13)),
            trailing: Icon(Icons.chevron_right, color: subtitleColor),
          ),
        );
      },
    );
  }
}

// ── Daily quote banner ────────────────────────────────────────────────────────
// Cycles through the Promises quotes based on day-of-year so it changes
// daily without requiring a network call.

const _dashboardQuotes = [
  RecoveryQuotes.promises,
  RecoveryQuotes.dailyReprieve,
  RecoveryQuotes.loveAndTolerance,
  RecoveryQuotes.spiritualLife,
  RecoveryQuotes.step10Assets,
  RecoveryQuotes.step11Contact,
  RecoveryQuotes.selfWill,
];

class _DailyQuoteBanner extends StatelessWidget {
  const _DailyQuoteBanner();

  @override
  Widget build(BuildContext context) {
    final dayIndex = DateTime.now().dayOfYear % _dashboardQuotes.length;
    final quote = _dashboardQuotes[dayIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: QuoteCard(quote: quote, compact: true),
    );
  }
}

extension on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays;
  }
}

// ── Sobriety card ─────────────────────────────────────────────────────────────

class _SobrietyCard extends ConsumerWidget {
  const _SobrietyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateAsync = ref.watch(sobrietyDateProvider);

    return dateAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (date) => date == null
          ? _buildUnset(context, ref)
          : _buildSet(context, ref, date),
    );
  }

  // ── No date set yet ──────────────────────────────────────────────────────

  Widget _buildUnset(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final teal = cs.secondary;
    return GestureDetector(
      onTap: () => _pickDate(context, ref, initial: null),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: teal.withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: teal.withOpacity(0.45), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: teal, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set your sobriety date',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to enter the date you got sober',
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.72),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: teal.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }

  // ── Date is set ──────────────────────────────────────────────────────────

  Widget _buildSet(BuildContext context, WidgetRef ref, DateTime date) {
    final days = SobrietyService.daysSober(date);
    final milestone = SobrietyService.currentMilestone(days);
    final next = SobrietyService.nextMilestone(days);
    final daysToNext = next != null ? next.days - days : null;

    return GestureDetector(
      onTap: () => _pickDate(context, ref, initial: date),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade600, Colors.teal.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Days counter
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$days',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 52,
                          height: 1.0,
                          letterSpacing: -1,
                        ),
                      ),
                      const Text(
                        'Days Sober',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit hint
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.edit_calendar_outlined,
                        color: Colors.white38, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      _formatSobrietyDate(date),
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            // ── Milestone badge ──────────────────────────────────────────
            if (milestone != null) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  _MilestoneBadge(
                    label: '🏅 ${milestone.shortLabel}',
                    color: Colors.amber.shade300,
                    textColor: Colors.teal.shade900,
                  ),
                  if (daysToNext != null)
                    _MilestoneBadge(
                      label: '$daysToNext days to ${next!.shortLabel}',
                      color: Colors.white.withOpacity(0.15),
                      textColor: Colors.white70,
                    ),
                ],
              ),
            ] else if (daysToNext != null) ...[
              const SizedBox(height: 14),
              _MilestoneBadge(
                label: '$daysToNext days to ${next!.shortLabel}',
                color: Colors.white.withOpacity(0.15),
                textColor: Colors.white70,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Date picker ──────────────────────────────────────────────────────────

  Future<void> _pickDate(
      BuildContext context, WidgetRef ref, {required DateTime? initial}) async {
    final now = DateTime.now();
    final picked = await showAdaptiveAppDatePicker(
      context: context,
      initialDate: initial ?? now.subtract(const Duration(days: 1)),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Select your sobriety date',
      confirmText: 'Set date',
      fieldLabelText: 'Sobriety date',
    );

    if (picked != null) {
      await ref.read(sobrietyDateProvider.notifier).setDate(picked);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _formatSobrietyDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }
}

class _MilestoneBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _MilestoneBadge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Streak header ─────────────────────────────────────────────────────────────

class _StreakHeader extends ConsumerWidget {
  const _StreakHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade500, Colors.indigo.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$streak Day Streak",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const Text(
                  "Trudging the Road of Happy Destiny.",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}