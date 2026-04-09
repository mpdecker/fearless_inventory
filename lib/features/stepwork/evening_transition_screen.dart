import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EveningTransitionScreen
//
// Self-playing, fully automatic sequence (4.4 s total):
//   0.00–0.38  Sky deepens slightly (midnight blue → deep indigo-black)
//   0.00–0.52  Moon rises from below the horizon line to a resting position
//   0.05–0.22  Moon body and star field fade in
//   0.18–0.44  Soft moon-glow and halo fade in
//   0.20–0.42  Serenity Prayer fades in  (starts while moon is still rising)
//   0.42–0.84  Prayer holds             (~1850 ms of fully-visible time)
//   0.84–0.96  Prayer fades out
//   0.93–1.00  Scene fades to the app night colour (0xFF12121F)
//   1.00       Navigator.pop() → returns to whatever screen is below
//              (use pushReplacement from the bedtime screen so we go
//               straight back to Home)
// ─────────────────────────────────────────────────────────────────────────────

class EveningTransitionScreen extends StatefulWidget {
  const EveningTransitionScreen({super.key});

  @override
  State<EveningTransitionScreen> createState() =>
      _EveningTransitionScreenState();
}

class _EveningTransitionScreenState extends State<EveningTransitionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _sky;
  late final Animation<double> _moonRise;
  late final Animation<double> _moonFadeIn;
  late final Animation<double> _glow;
  late final Animation<double> _prayerIn;
  late final Animation<double> _prayerOut;
  late final Animation<double> _exit;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4400),
    );

    _sky = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.0, 0.38, curve: Curves.easeIn));
    _moonRise = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.52, curve: Curves.easeOutCubic));
    _moonFadeIn = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.05, 0.22, curve: Curves.easeIn));
    _glow = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.18, 0.44, curve: Curves.easeIn));
    _prayerIn = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.20, 0.42, curve: Curves.easeIn));
    _prayerOut = CurvedAnimation(
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
    // The Material underneath is the app's night colour so the exit fade
    // dissolves into darkness rather than white.
    return Material(
      color: const Color(0xFF12121F),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final prayerOpacity =
              (_prayerIn.value * (1.0 - _prayerOut.value)).clamp(0.0, 1.0);
          final sceneOpacity = (1.0 - _exit.value).clamp(0.0, 1.0);

          // Sky barely shifts — a subtle deepening from near-black to rich
          // deep-indigo as the moon illuminates the upper atmosphere.
          final skyTop = Color.lerp(
            const Color(0xFF050510), // near-black night
            const Color(0xFF0D0D2B), // deep indigo
            _sky.value,
          )!;
          final skyBottom = Color.lerp(
            const Color(0xFF0A0A1A), // midnight
            const Color(0xFF1A1040), // dark violet at horizon
            _sky.value,
          )!;

          return Opacity(
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
                  // ── Moonrise painter (stars + horizon + moon) ──────
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MoonrisePainter(
                        moonProgress: _moonRise.value,
                        moonOpacity: _moonFadeIn.value,
                        glowOpacity: _glow.value,
                      ),
                    ),
                  ),

                  // ── Serenity Prayer ────────────────────────────────
                  Center(
                    child: Opacity(
                      opacity: prayerOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'God, grant me the serenity\n'
                          'to accept the things I cannot change,\n'
                          'courage to change the things I can,\n'
                          'and wisdom to know the difference.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFDDDDF4),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                            height: 1.75,
                            shadows: [
                              Shadow(
                                color: Colors.black87,
                                offset: Offset(0, 1),
                                blurRadius: 14,
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
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Moonrise painter
// ─────────────────────────────────────────────────────────────────────────────

class _MoonrisePainter extends CustomPainter {
  final double moonProgress; // 0 = below horizon, 1 = risen
  final double moonOpacity;  // star field + moon body fade-in
  final double glowOpacity;  // soft halo fade-in

  const _MoonrisePainter({
    required this.moonProgress,
    required this.moonOpacity,
    required this.glowOpacity,
  });

  // Fixed star field — positions as fractions of canvas size so they scale
  // to any screen. Kept deterministic (no Random) so they never jump.
  static const _stars = <(double, double, double)>[
    // (x-fraction, y-fraction, radius)
    (0.08, 0.06, 1.4), (0.18, 0.12, 1.0), (0.31, 0.04, 1.6),
    (0.45, 0.09, 1.1), (0.57, 0.03, 1.3), (0.68, 0.11, 0.9),
    (0.79, 0.05, 1.5), (0.91, 0.08, 1.2), (0.13, 0.20, 0.8),
    (0.25, 0.17, 1.4), (0.38, 0.22, 1.0), (0.52, 0.15, 1.3),
    (0.64, 0.19, 0.9), (0.76, 0.14, 1.6), (0.88, 0.23, 1.1),
    (0.06, 0.30, 1.2), (0.20, 0.33, 0.8), (0.35, 0.28, 1.5),
    (0.50, 0.31, 1.0), (0.62, 0.27, 1.3), (0.74, 0.35, 0.9),
    (0.86, 0.29, 1.4), (0.94, 0.38, 1.1), (0.10, 0.42, 0.8),
    (0.28, 0.45, 1.2), (0.43, 0.40, 1.0), (0.58, 0.44, 0.9),
    (0.72, 0.41, 1.3), (0.83, 0.48, 1.1), (0.96, 0.44, 0.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.70;
    final moonR = size.width * 0.085;

    // Moon travels from 1.8 radii below horizon to ~24 % up the canvas
    final moonStartY = horizonY + moonR * 1.8;
    final moonEndY = size.height * 0.24;
    final moonY = moonStartY + (moonEndY - moonStartY) * moonProgress;
    final moonCenter = Offset(size.width / 2, moonY);

    // ── Star field ─────────────────────────────────────────────────────────
    if (moonOpacity > 0) {
      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.75 * moonOpacity);
      for (final (fx, fy, r) in _stars) {
        // Only draw stars in the upper sky (above horizon)
        final sy = size.height * fy;
        if (sy < horizonY) {
          canvas.drawCircle(Offset(size.width * fx, sy), r, starPaint);
        }
      }
    }

    // ── Horizon line ────────────────────────────────────────────────────────
    final horizonPaint = Paint()
      ..color = const Color(0xFFB0B0D0).withValues(alpha: 0.15 * moonOpacity)
      ..strokeWidth = 0.7;
    canvas.drawLine(
      Offset(0, horizonY),
      Offset(size.width, horizonY),
      horizonPaint,
    );

    if (moonOpacity <= 0) return;

    // ── Outer soft halo ─────────────────────────────────────────────────────
    if (glowOpacity > 0) {
      final haloPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF9090C8).withValues(alpha: 0.30 * glowOpacity),
            const Color(0xFF6060A0).withValues(alpha: 0.12 * glowOpacity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
            Rect.fromCircle(center: moonCenter, radius: moonR * 4.5));
      canvas.drawCircle(moonCenter, moonR * 4.5, haloPaint);
    }

    // ── Moon body ───────────────────────────────────────────────────────────
    // A slightly warm silver — cooler and dimmer near horizon, brighter risen.
    final moonColor = Color.lerp(
      const Color(0xFFB0A8C8), // dim blue-silver at horizon
      const Color(0xFFEEEEFF), // bright silver-white when risen
      moonProgress,
    )!;
    final moonPaint = Paint()
      ..color = moonColor.withValues(alpha: moonOpacity);
    canvas.drawCircle(moonCenter, moonR, moonPaint);

    // ── Subtle crescent shadow (makes it look like a real moon) ─────────────
    // Draw a slightly offset darker disc to create a crescent illusion.
    final shadowPaint = Paint()
      ..color = const Color(0xFF0D0D2B).withValues(alpha: 0.55 * moonOpacity)
      ..blendMode = BlendMode.srcOver;
    canvas.drawCircle(
      moonCenter.translate(moonR * 0.35, -moonR * 0.10),
      moonR * 0.88,
      shadowPaint,
    );

    // ── Subtle ray shimmer (shorter and softer than sunrise rays) ───────────
    if (glowOpacity <= 0) return;
    const numRays = 16;
    final innerR = moonR * 1.3;
    final outerR = moonR * 1.75;
    final rayPaint = Paint()
      ..color = const Color(0xFFCCCCFF).withValues(alpha: 0.22 * glowOpacity)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < numRays; i++) {
      final angle = (i / numRays) * 2 * pi - pi / 2;
      canvas.drawLine(
        Offset(moonCenter.dx + innerR * cos(angle),
            moonCenter.dy + innerR * sin(angle)),
        Offset(moonCenter.dx + outerR * cos(angle),
            moonCenter.dy + outerR * sin(angle)),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MoonrisePainter old) =>
      old.moonProgress != moonProgress ||
      old.moonOpacity != moonOpacity ||
      old.glowOpacity != glowOpacity;
}
