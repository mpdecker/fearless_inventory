import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Feature Imports
import '../review/daily_review_screen.dart';
import '../review/review_history_screen.dart';
import '../amends/amends_list_screen.dart'; // Pointing to the new Amends Workspace
import '../insights/recovery_insights_screen.dart'; // New dedicated Insights tab
import '../settings/settings_screen.dart';
import '../review/providers/streak_provider.dart'; 

// Stepwork Imports
import '../stepwork/step_4_landing_screen.dart';
import '../stepwork/defect_management_screen.dart';
import '../stepwork/shortcoming_dashboard_screen.dart';
import '../stepwork/step_11_meditation_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  // Callback to allow child views to request a tab change (e.g., clicking Step 9 card)
  void _onTabRequest(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 4 Pages now instead of 3
    final List<Widget> pages = [
      _HomeDashboardView(onTabRequest: _onTabRequest),
      const ReviewHistoryScreen(),
      const AmendsListScreen(),       // The new tabbed Step 8/9 workspace
      const RecoveryInsightsScreen(), // The extracted heatmap and stats
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Recovery Companion', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const SettingsScreen())
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
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.history_outlined), label: 'Reviews'),
          NavigationDestination(icon: Icon(Icons.handshake_outlined), label: 'Amends'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Insights'),
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
        const _StreakHeader(),
        
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
            MaterialPageRoute(builder: (_) => Step11MeditationScreen())
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
            MaterialPageRoute(builder: (_) => const DailyReviewScreen())
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
            MaterialPageRoute(builder: (_) => Step4LandingScreen())
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
            MaterialPageRoute(builder: (_) => const DefectManagementScreen())
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
            MaterialPageRoute(builder: (_) => const ShortcomingDashboardScreen())
          ),
        ),
        _buildActionCard(
          context: context,
          title: "Steps 8 & 9: Amends",
          subtitle: "List, willingness, and action plans",
          icon: Icons.handshake_outlined,
          color: Colors.blueGrey.shade700,
          onTap: () => onTabRequest(2), // Switch to the Amends Tab
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(title, 
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: Colors.grey.shade700, 
          letterSpacing: 1.1, 
          fontSize: 12
        )),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), 
            borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}

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