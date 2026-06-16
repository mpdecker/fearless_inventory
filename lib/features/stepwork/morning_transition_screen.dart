import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MorningTransitionScreen
//
// Self-playing, fully automatic sequence (4.4 s total):
//   0.00–0.38  Sky fades from night (deep indigo/purple) to sunrise palette
//   0.00–0.52  Sun rises from below the horizon line to a resting position
//   0.05–0.22  Sun body fades in
//   0.18–0.44  Light rays fade in around the sun
//   0.20–0.42  Quote fades in  (starts while sun is still rising)
//   0.42–0.84  Quote holds     (~1850 ms of fully-visible time)
//   0.84–0.96  Quote fades out
//   0.93–1.00  Whole scene fades to white (morning wash)
//   1.00       Navigator.pop() → returns to whatever screen is below
//              (use pushReplacement from the meditation screen so we go
//               straight back to Home)
// ─────────────────────────────────────────────────────────────────────────────

class MorningTransitionScreen extends StatefulWidget {
  const MorningTransitionScreen({super.key});

  @override
  State<MorningTransitionScreen> createState() =>
      _MorningTransitionScreenState();
}

class _MorningTransitionScreenState extends State<MorningTransitionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Individual animation segments (all drive off the single controller)
  late final Animation<double> _sky;
  late final Animation<double> _sunRise;
  late final Animation<double> _sunFadeIn;
  late final Animation<double> _rays;
  late final Animation<double> _quoteIn;
  late final Animation<double> _quoteOut;
  late final Animation<double> _exit;

  @override
  void initState() {
    super.initState();

    // Lock to portrait and hide system bars for an immersive sunrise
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4400),
    );

    // Sky and sun finish slightly faster, freeing the second half for the quote.
    _sky = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.0, 0.38, curve: Curves.easeIn));
    _sunRise = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.52, curve: Curves.easeOutCubic));
    _sunFadeIn = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.05, 0.22, curve: Curves.easeIn));
    _rays = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.18, 0.44, curve: Curves.easeIn));

    // Quote starts fading in early (while the sun is still rising) and
    // holds on-screen until late in the sequence before fading out.
    _quoteIn = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.20, 0.42, curve: Curves.easeIn));
    _quoteOut = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.84, 0.96, curve: Curves.easeOut));
    _exit = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.93, 1.0, curve: Curves.easeIn));

    _ctrl.forward().then((_) {
      if (mounted) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        // Quote is fully in until it starts fading out
        final quoteOpacity =
            (_quoteIn.value * (1.0 - _quoteOut.value)).clamp(0.0, 1.0);

        // Final wash to white
        final sceneOpacity = (1.0 - _exit.value).clamp(0.0, 1.0);

        // Sky gradient: night → sunrise
        final skyTop = Color.lerp(
          const Color(0xFF0D1626), // deep night
          const Color(0xFFE8622A), // warm coral-orange
          _sky.value,
        )!;
        final skyBottom = Color.lerp(
          const Color(0xFF1C0A38), // midnight purple
          const Color(0xFFFFBF47), // golden horizon
          _sky.value,
        )!;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Opacity(
            opacity: sceneOpacity,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [skyTop, skyBottom],
                ),
              ),
              child: Stack(
                children: [
                  // ── Sunrise painter (horizon + sun + rays) ──────────
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SunrisePainter(
                        sunProgress: _sunRise.value,
                        sunOpacity: _sunFadeIn.value,
                        rayOpacity: _rays.value,
                      ),
                    ),
                  ),

                  // ── Quote ───────────────────────────────────────────
                  Center(
                    child: Opacity(
                      opacity: quoteOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          '"In whatever I am faced with today,\n'
                          'thy will not mine be done."',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                            height: 1.65,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(0, 1),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sunrise painter
// ─────────────────────────────────────────────────────────────────────────────

class _SunrisePainter extends CustomPainter {
  final double sunProgress; // 0 = below horizon, 1 = risen
  final double sunOpacity;  // 0 → 1 fade-in of sun body
  final double rayOpacity;  // 0 → 1 fade-in of rays

  const _SunrisePainter({
    required this.sunProgress,
    required this.sunOpacity,
    required this.rayOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.70;
    final sunR = size.width * 0.095;

    // Sun travels from 1.8 radii below horizon to 26 % up the canvas
    final sunStartY = horizonY + sunR * 1.8;
    final sunEndY = size.height * 0.26;
    final sunY = sunStartY + (sunEndY - sunStartY) * sunProgress;
    final sunCenter = Offset(size.width / 2, sunY);

    // ── Horizon line (fades in with sky) ──────────────────────────────
    final horizonPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18 * sunOpacity)
      ..strokeWidth = 0.8;
    canvas.drawLine(
      Offset(0, horizonY),
      Offset(size.width, horizonY),
      horizonPaint,
    );

    if (sunOpacity <= 0) return;

    // ── Outer glow ────────────────────────────────────────────────────
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withValues(alpha: 0.45 * sunOpacity),
          Colors.deepOrange.withValues(alpha: 0.18 * sunOpacity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
          Rect.fromCircle(center: sunCenter, radius: sunR * 4.0));
    canvas.drawCircle(sunCenter, sunR * 4.0, glowPaint);

    // ── Sun body ──────────────────────────────────────────────────────
    final sunColor = Color.lerp(
      const Color(0xFFFFB300), // deep amber at horizon
      const Color(0xFFFFF176), // pale yellow when risen
      sunProgress,
    )!;
    final sunPaint = Paint()
      ..color = sunColor.withValues(alpha: sunOpacity);
    canvas.drawCircle(sunCenter, sunR, sunPaint);

    // ── Rays ──────────────────────────────────────────────────────────
    if (rayOpacity <= 0) return;
    const numRays = 14;
    final innerR = sunR * 1.4;
    final outerR = sunR * 2.2;
    final rayPaint = Paint()
      ..color = Colors.amber.shade100.withValues(alpha: 0.55 * rayOpacity)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < numRays; i++) {
      final angle = (i / numRays) * 2 * pi - pi / 2; // start at top
      canvas.drawLine(
        Offset(sunCenter.dx + innerR * cos(angle),
            sunCenter.dy + innerR * sin(angle)),
        Offset(sunCenter.dx + outerR * cos(angle),
            sunCenter.dy + outerR * sin(angle)),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SunrisePainter old) =>
      old.sunProgress != sunProgress ||
      old.sunOpacity != sunOpacity ||
      old.rayOpacity != rayOpacity;
}
