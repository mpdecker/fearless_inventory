import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../privacy_policy_content.dart';

/// Renders the bundled privacy policy. Shown from Settings → Privacy so the
/// policy is reachable inside the app without depending on a hosted URL.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _openHosted(BuildContext context) async {
    final uri = Uri.parse(kPrivacyPolicyUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the online policy.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        actions: [
          // Only offered once a hosted copy exists.
          if (kPrivacyPolicyUrl.isNotEmpty)
            IconButton(
              tooltip: 'Open online version',
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _openHosted(context),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text(
            'Last updated $kPrivacyPolicyLastUpdated',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          for (final section in kPrivacyPolicySections) ...[
            Text(
              section.heading,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final paragraph in section.paragraphs) ...[
              Text(paragraph, style: bodyStyle),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
