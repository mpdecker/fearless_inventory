import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/features/settings/privacy_policy_content.dart';
import 'package:fearless_inventory/features/settings/screens/privacy_policy_screen.dart';

void main() {
  group('policy content', () {
    test('has sections, each with a heading and at least one paragraph', () {
      expect(kPrivacyPolicySections, isNotEmpty);
      for (final s in kPrivacyPolicySections) {
        expect(s.heading.trim(), isNotEmpty);
        expect(s.paragraphs, isNotEmpty,
            reason: '"${s.heading}" must have body text');
        for (final p in s.paragraphs) {
          expect(p.trim(), isNotEmpty);
        }
      }
    });

    test('covers the disclosures both stores expect', () {
      final all = [
        for (final s in kPrivacyPolicySections) ...[s.heading, ...s.paragraphs]
      ].join(' ').toLowerCase();

      // Every category of data handling the app actually performs.
      expect(all, contains('encrypted'));
      expect(all, contains('location'));
      expect(all, contains('contacts'));
      expect(all, contains('firebase'));
      expect(all, contains('delete'));
      // The privacy claim the app makes elsewhere must appear here too.
      expect(all, contains('without an account'));
    });

    test('hosted URL, when set, is a well-formed HTTPS address', () {
      if (kPrivacyPolicyUrl.isEmpty) return; // not yet hosted — allowed
      final uri = Uri.tryParse(kPrivacyPolicyUrl);
      expect(uri, isNotNull, reason: 'must parse as a URI');
      expect(uri!.scheme, 'https',
          reason: 'store listings and the in-app link require HTTPS');
      expect(uri.host, isNotEmpty);
      expect(uri.hasEmptyPath, isFalse,
          reason: 'should point at the policy page, not just a host');
    });

    test('hosted markdown copy exists and tracks the same last-updated date',
        () {
      final file = File('docs/privacy-policy.md');
      expect(file.existsSync(), isTrue,
          reason: 'docs/privacy-policy.md is the copy meant for hosting');
      final md = file.readAsStringSync();
      expect(md, contains(kPrivacyPolicyLastUpdated),
          reason: 'in-app and hosted copies must not drift out of sync');
      // Spot-check that section headings made it into the hosted copy.
      for (final s in kPrivacyPolicySections) {
        expect(md.toLowerCase(), contains(s.heading.toLowerCase()),
            reason: 'hosted copy is missing the "${s.heading}" section');
      }
    });
  });

  testWidgets('screen renders every section heading', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PrivacyPolicyScreen()),
    );
    await tester.pump();

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.textContaining(kPrivacyPolicyLastUpdated), findsOneWidget);

    // Scroll through and confirm each heading appears.
    for (final s in kPrivacyPolicySections) {
      await tester.scrollUntilVisible(
        find.text(s.heading),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(s.heading), findsOneWidget);
    }
  });

  testWidgets('external-link action appears only when a hosted URL is set',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyScreen()));
    await tester.pump();

    // Guards against shipping a button that opens an empty/404 URL.
    if (kPrivacyPolicyUrl.isEmpty) {
      expect(find.byIcon(Icons.open_in_new), findsNothing);
    } else {
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
    }
  });
}
