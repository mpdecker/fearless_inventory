import 'package:flutter/material.dart';
import '../../core/quotes/recovery_quotes.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/widgets/quote_card.dart';
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
    title: 'A New Freedom Awaits',
    body:
        'Fearless Inventory is a private companion for serious Big Book '
        'stepwork — designed to be worked alongside your sponsor, one day '
        'at a time. Everything you enter stays encrypted on this device.',
    icon: Icons.auto_awesome_outlined,
    color: Color(0xFF3949AB), // indigo
    quote: RecoveryQuotes.welcome,
  ),

  // ── 2. Step 4 ─────────────────────────────────────────────────────────────
  _OnboardingPage(
    title: 'A Searching and Fearless Inventory',
    body:
        'The heart of the app is the four-column Step 4 worksheet — '
        'resentments, fears, and harms — drawn directly from the Big Book. '
        'Flag entries for your sponsor and export the full worksheet for your '
        'Step 5 reading.',
    icon: Icons.assignment_outlined,
    color: Color(0xFFB71C1C), // dark red
    quote: RecoveryQuotes.step4Inventory,
  ),

  // ── 3. Steps 5–9 ──────────────────────────────────────────────────────────
  _OnboardingPage(
    title: 'Admitted the Exact Nature of Our Wrongs',
    body:
        'Once your inventory is complete, the Step 5 Ceremony walks you '
        'through the three admissions. Steps 6 and 7 map your character '
        'defects and shortcomings. Steps 8 and 9 guide your amends list, '
        'planning, and follow-through — including timeframes.',
    icon: Icons.handshake_outlined,
    color: Color(0xFF00695C), // dark teal
    quote: RecoveryQuotes.step5Pocket,
  ),

  // ── 4. Daily Practice ─────────────────────────────────────────────────────
  _OnboardingPage(
    title: 'A Daily Reprieve',
    body:
        'The Step 10 daily inventory lets you log multiple incidents '
        'throughout the day — each one distinct, each one honest. Morning '
        'and evening Step 11 meditation screens support your conscious '
        'contact with God.',
    icon: Icons.nightlight_round_outlined,
    color: Color(0xFF4527A0), // deep purple
    quote: RecoveryQuotes.dailyReprieve,
  ),

  // ── 5. Privacy & Begin ────────────────────────────────────────────────────
  _OnboardingPage(
    title: 'Your Inventory Stays Yours',
    body:
        'A unique encryption key is generated on this device and never '
        'transmitted anywhere. You may wipe all data at any time from '
        'Settings. Your fifth step is yours to share — with your Higher '
        'Power, yourself, and the person you choose.',
    icon: Icons.lock_outline,
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
                // Dots
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
                // Next / Get Started
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
                          ? 'Begin My Inventory'
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
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 15,
                  height: 1.6,
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
                      color: Colors.white.withOpacity(0.4),
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
                        color: page.color == const Color(0xFFB71C1C)
                            ? Colors.redAccent.shade100
                            : Colors.white.withOpacity(0.55),
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
