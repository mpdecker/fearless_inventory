import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/features/settings/privacy_policy_content.dart';

/// Covers the generator that produces the publicly hosted policy page.
///
/// The important guarantee here is negative: `docs/privacy-policy.md` carries a
/// maintainer note, and `docs/` also holds internal release planning documents.
/// Only the rendered policy may ever reach the public site.
void main() {
  final python = ['python3', 'python']
      .firstWhere((p) => Process.runSync('which', [p]).exitCode == 0,
          orElse: () => '');

  group('privacy policy site generator', () {
    late Directory outDir;
    late String html;

    setUpAll(() {
      if (python.isEmpty) return;
      outDir = Directory.systemTemp.createTempSync('fi_policy_site_');
      final result = Process.runSync(
        python,
        ['tool/render_privacy_policy.py', 'docs/privacy-policy.md', outDir.path],
      );
      expect(result.exitCode, 0, reason: 'generator failed: ${result.stderr}');
      html = File('${outDir.path}/privacy-policy.html').readAsStringSync();
    });

    tearDownAll(() {
      if (python.isEmpty) return;
      if (outDir.existsSync()) outDir.deleteSync(recursive: true);
    });

    test('publishes the policy, the index, and .nojekyll', () {
      expect(File('${outDir.path}/privacy-policy.html').existsSync(), isTrue);
      // A bare repo-root URL must not 404.
      expect(File('${outDir.path}/index.html').existsSync(), isTrue);
      expect(File('${outDir.path}/.nojekyll').existsSync(), isTrue);
    });

    test('never leaks maintainer notes or internal file references', () {
      for (final secret in [
        'MAINTAINER NOTE',
        'privacy_policy_content.dart',
        'kPrivacyPolicyUrl',
        'pages.yml',
        'render_privacy_policy.py',
      ]) {
        expect(html.toLowerCase(), isNot(contains(secret.toLowerCase())),
            reason: '"$secret" must not appear on the public page');
      }
      // HTML comments are stripped entirely.
      expect(html, isNot(contains('<!--')));
    });

    test('renders every section of the in-app policy', () {
      for (final section in kPrivacyPolicySections) {
        expect(html, contains('<h2>${section.heading}</h2>'),
            reason: 'published page is missing "${section.heading}"');
      }
      expect(html, contains(kPrivacyPolicyLastUpdated));
    });

    test('leaves no unconverted markdown in the output', () {
      final body = html.split('<main>').last.split('</main>').first;
      expect(body, isNot(contains('**')));
      expect(body, isNot(contains('## ')));
      expect(body, isNot(contains('`')));
    });

    test('is a complete, self-contained HTML document', () {
      expect(html, startsWith('<!DOCTYPE html>'));
      expect(html.trim(), endsWith('</html>'));
      // No external requests from a page whose whole point is privacy.
      expect(html, isNot(contains('http://')));
      expect(html, isNot(contains('src=')));
    });
  }, skip: python.isEmpty ? 'python3 not available' : null);
}
