import 'package:flutter/material.dart';
import '../../core/quotes/recovery_quotes.dart';
import '../../core/services/onboarding_service.dart';
import '../home/home_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page data model
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingPage {
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final RecoveryQuote quote;

  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.quote,
  });
}

const _pages = [
  // ── 1. Welcome ────────────────────────────────────────────────────────────
  _OnboardingPage(
    title: 'A New Life Is Possible',
    body:
        'Recovery is not a destination — it\'s a daily way of life. '
        'Fearless Inventory is your private companion for working all '
        'twelve steps, building habits of accountability, and staying '
        'close to your sponsor and fellowship. '
        'Everything you enter stays encrypted on this device.',
    icon: Icons.auto_awesome_outlined,
    color: Color(0xFF3949AB), // indigo
    quote: RecoveryQuotes.welcome,
  ),

  // ── 2. Daily Practice ─────────────────────────────────────────────────────
  _OnboardingPage(
    title: 'One Day at a Time',
    body:
        'Your sobriety is contingent on the maintenance of your spiritual '
        'condition — one day at a time. The Dashboard keeps your Step 11 '
        'morning meditation, Step 10 evening inventory, and active stepwork '
        'front and center. Small daily actions build the life the promises '
        'describe.',
    icon: Icons.loop_outlined,
    color: Color(0xFF4527A0), // deep purple
    quote: RecoveryQuotes.dailyReprieve,
  ),

  // ── 3. All Twelve Steps ───────────────────────────────────────────────────
  _OnboardingPage(
    title: 'Into Action',
    body:
        'Every step has a dedicated home — from your fourth-step moral '
        'inventory and fifth-step reading, through character defects and '
        'shortcomings, your amends list, and on into service and sponsorship '
        'in the twelfth. Work each step thoroughly, with your sponsor\'s '
        'guidance, and carry what you learn forward.',
    icon: Icons.format_list_numbered_outlined,
    color: Color(0xFF00695C), // dark teal
    quote: RecoveryQuotes.spiritualLife,
  ),

  // ── 4. Privacy + Begin ────────────────────────────────────────────────────
  _OnboardingPage(
    title: 'Your Recovery Stays Yours',
    body:
        'A unique encryption key is generated on this device and never '
        'transmitted anywhere. Your fifth step is yours to share — with '
        'your Higher Power, yourself, and the person you choose. '
        'Use this tool with a sponsor. Stay in the middle of the herd. '
        'The promises are real.',
    icon: Icons.shield_outlined,
    color: Color(0xFF1B5E20), // dark green
    quote: RecoveryQuotes.promises,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await OnboardingService.markComplete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Page content ─────────────────────────────────────────────────
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _OnboardingPageView(page: _pages[i]),
          ),

          // ── Skip button (top-right) ───────────────────────────────────────
          if (_current < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip',
                    style: TextStyle(color: Colors.white70, fontSize: 15)),
              ),
            ),

          // ── Bottom nav (dots + button) ───────────────────────────────────
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _current ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i == _current
                            ? _pages[_current].color
                            : Colors.white24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Next / Begin My Recovery
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: _pages[_current].color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _current == _pages.length - 1
                          ? 'Begin My Recovery'
                          : 'Next',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual page view
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            page.color.withOpacity(0.9),
            Colors.black,
          ],
          stops: const [0.0, 0.65],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 60, 28, 160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ───────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(page.icon, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 32),

              // ── Title ──────────────────────────────────────────────────────
              Text(
                page.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // ── Body ───────────────────────────────────────────────────────
              Text(
                page.body,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 15,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 28),

              // ── Quote ──────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: Colors.white.withOpacity(0.35),
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u201C${page.quote.text}\u201D',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '— ${page.quote.citation}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
