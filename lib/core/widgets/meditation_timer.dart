import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Self-contained meditation stopwatch.
///
/// Displays an MM:SS counter.  The user taps Start to begin, Pause to pause,
/// and "End & Save" when done.  [onSave] is called with total elapsed seconds
/// so the parent screen can persist the session to the database.
///
/// The widget enters a permanently-saved state after "End & Save" is tapped,
/// showing a confirmation row so the user knows the time was recorded.
class MeditationTimerWidget extends HookConsumerWidget {
  final void Function(int seconds) onSave;
  final Color accentColor;

  const MeditationTimerWidget({
    super.key,
    required this.onSave,
    this.accentColor = const Color(0xFF3949AB), // indigo-700
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsed   = useState(0);
    final isRunning = useState(false);
    final isSaved   = useState(false);

    // useEffect returns the cleanup callback; each time isRunning changes, the
    // old timer is cancelled and a new one is started (or not, if paused).
    useEffect(() {
      if (!isRunning.value) return null;
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        elapsed.value++;
      });
      return timer.cancel;
    }, [isRunning.value]);

    final minutes = elapsed.value ~/ 60;
    final seconds = elapsed.value % 60;
    final display =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(
            'MEDITATION TIMER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
              color: accentColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 14),

          // ── Clock face ──────────────────────────────────────────────────
          Text(
            display,
            style: TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w200,
              letterSpacing: 3,
              color: isSaved.value
                  ? accentColor.withOpacity(0.35)
                  : accentColor.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),

          // ── Controls ────────────────────────────────────────────────────
          if (!isSaved.value) ...[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              children: [
                _TimerButton(
                  label: isRunning.value
                      ? 'Pause'
                      : (elapsed.value == 0 ? 'Start' : 'Resume'),
                  icon: isRunning.value
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  color: accentColor,
                  onTap: () => isRunning.value = !isRunning.value,
                ),
                if (elapsed.value > 0)
                  _TimerButton(
                    label: 'End & Save',
                    icon: Icons.check_circle_outline,
                    color: Colors.teal.shade700,
                    onTap: () {
                      isRunning.value = false;
                      isSaved.value   = true;
                      onSave(elapsed.value);
                    },
                  ),
              ],
            ),
          ] else ...[
            // ── Saved confirmation ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.teal.shade600, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Time saved — ${_formatDuration(elapsed.value)}',
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDuration(int totalSeconds) {
    if (totalSeconds == 0) return '0 sec';
    if (totalSeconds < 60) return '$totalSeconds sec';
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widget
// ─────────────────────────────────────────────────────────────────────────────

class _TimerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TimerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 14)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
      ),
    );
  }
}
