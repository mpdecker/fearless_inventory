import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/database/database.dart';
import '../../core/providers/sponsor_call_provider.dart';
import '../../data/repositories/sponsor_call_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Shown when the user taps the "Call your sponsor" notification, or when they
/// tap "Log a sponsor call" in Settings.
///
/// Provides a direct-dial link and an "Already Called" button that records the
/// call in [SponsorCallLogs] for insights tracking.
///
/// Pass [scheduledFor] when launching from a notification so the log entry can
/// be linked back to the reminder that triggered it.
class SponsorCallScreen extends ConsumerWidget {
  final DateTime? scheduledFor;

  const SponsorCallScreen({super.key, this.scheduledFor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(sponsorCallConfigProvider);
    final lastCallAsync = ref.watch(_lastCallProvider);

    final phone = configAsync.maybeWhen(
      data: (c) => c.phone,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Call Your Sponsor')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header icon ───────────────────────────────────────────────
            const Icon(Icons.phone_in_talk_outlined,
                size: 72, color: Colors.tealAccent),
            const SizedBox(height: 24),

            // ── Last call ──────────────────────────────────────────────────
            lastCallAsync.when(
              data: (last) => _LastCallBanner(last: last),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),

            // ── Call now ───────────────────────────────────────────────────
            if (phone != null && phone.isNotEmpty) ...[
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.call),
                label: Text(
                  'Call $phone',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: () => _dialPhone(context, phone),
              ),
              const SizedBox(height: 12),
            ] else ...[
              // Prompt to set a phone number
              Card(
                color: Colors.white10,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "No sponsor phone number saved.\n"
                    "Add it under Settings → Notifications → "
                    "Call your sponsor reminder.",
                    style: TextStyle(
                        color: Colors.grey.shade400, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Already called ─────────────────────────────────────────────
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.tealAccent),
                foregroundColor: Colors.tealAccent,
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'Already Called — Log It',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () => _logCall(context, ref, calledViaApp: false),
            ),

            const Spacer(),

            // ── Hint ──────────────────────────────────────────────────────
            Text(
              'Calls are logged privately on this device and used '
              'only to show your sponsor-contact frequency in Insights.',
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 12, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dialPhone(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the phone dialler.')),
      );
    }
  }

  Future<void> _logCall(
    BuildContext context,
    WidgetRef ref, {
    required bool calledViaApp,
  }) async {
    final repo = ref.read(sponsorCallRepositoryProvider);
    await repo.logCall(
      scheduledFor: scheduledFor,
      confirmedAt: DateTime.now(),
      calledViaApp: calledViaApp,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sponsor call logged. Keep up the great work!'),
          backgroundColor: Colors.teal,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Last call banner
// ─────────────────────────────────────────────────────────────────────────────

class _LastCallBanner extends StatelessWidget {
  final SponsorCallLog? last;
  const _LastCallBanner({required this.last});

  @override
  Widget build(BuildContext context) {
    if (last == null) {
      return Text(
        'No sponsor calls logged yet.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      );
    }

    final diff = DateTime.now().difference(last!.confirmedAt);
    final String ago;
    if (diff.inDays == 0) {
      ago = 'today';
    } else if (diff.inDays == 1) {
      ago = 'yesterday';
    } else {
      ago = '${diff.inDays} days ago';
    }

    return Text(
      'Last logged: $ago',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal provider
// ─────────────────────────────────────────────────────────────────────────────

final _lastCallProvider =
    StreamProvider.autoDispose<SponsorCallLog?>((ref) {
  return ref.watch(sponsorCallRepositoryProvider).watchLastCall();
});
