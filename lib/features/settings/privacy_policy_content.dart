/// Canonical privacy policy text, rendered in-app by [PrivacyPolicyScreen].
///
/// Both stores require a privacy policy reachable from inside the app **and**
/// a hosted URL on the store listing. Keeping the text here means the in-app
/// requirement is met with no dependency on hosting, so no broken link can
/// ship. `docs/privacy-policy.md` is the same content for hosting — update
/// both together.
library;

/// Human-readable date this policy last changed. Bump when the text changes.
const String kPrivacyPolicyLastUpdated = 'July 27, 2026';

/// Publicly hosted copy, used on the store listings.
///
/// Published by `.github/workflows/pages.yml` from `docs/privacy-policy.md`,
/// so it always matches the text below. The Settings entry does not depend on
/// this — it renders the bundled copy — but when set, the policy screen also
/// offers to open the online version.
const String kPrivacyPolicyUrl =
    'https://mpdecker.github.io/fearless_inventory/privacy-policy.html';

class PolicySection {
  final String heading;
  final List<String> paragraphs;
  const PolicySection(this.heading, this.paragraphs);
}

const List<PolicySection> kPrivacyPolicySections = [
  PolicySection(
    'The short version',
    [
      'Fearless Inventory is built so your recovery work stays yours. Your '
          'inventory, daily reviews, amends, journal entries, literature '
          'highlights and notes, meditation history, sponsee records, and '
          'contacts are stored only on this device, in an encrypted database. '
          'We cannot read them. They are never uploaded to us.',
      'We do not use analytics, advertising, or tracking of any kind. We do '
          'not sell or share your information.',
    ],
  ),
  PolicySection(
    'What stays on your device',
    [
      'All recovery content you enter is written to a local database that is '
          'encrypted on your device (SQLCipher). This includes Step 4 '
          'resentments, fears, and harms; Step 10 daily reviews; Step 8/9 '
          'amends; journal entries; literature highlights and notes; '
          'meditation sessions; service commitments; sponsee and Rolodex '
          'records; and meeting attendance.',
      'Your sobriety date and your app-lock PIN are held in your device\'s '
          'secure storage (iOS Keychain / Android encrypted storage). The PIN '
          'is stored as a hash, not as the digits you type.',
      'If you import contacts into your Rolodex, those names and numbers are '
          'copied into the same local encrypted database. They are not sent '
          'anywhere.',
    ],
  ),
  PolicySection(
    'Optional account',
    [
      'You can use the entire app without an account by choosing "Continue '
          'without an account". In that mode we hold no information about you '
          'at all.',
      'If you do create an account, it exists only to sign you in. It is '
          'handled by Google Firebase Authentication, which receives your '
          'email address and, depending on the method you choose, an '
          'identifier from Google or Apple Sign-In. Your recovery content is '
          'never attached to that account or uploaded.',
      'You can delete your account at any time from Settings → Account. You '
          'can erase all local recovery data from Settings → Clear All Data.',
    ],
  ),
  PolicySection(
    'Location',
    [
      'Location is used only to find recovery meetings near you, and only if '
          'you grant permission. Your coordinates are used on your device to '
          'calculate distances to meetings — they are not transmitted to us or '
          'to anyone else.',
      'If you instead type a city or zip code to search, that text (not your '
          'coordinates) is sent to Nominatim, the OpenStreetMap geocoding '
          'service, to turn it into a map location.',
    ],
  ),
  PolicySection(
    'Network connections',
    [
      'Meeting listings are downloaded from public recovery directories, such '
          'as AA intergroup services and NA meeting search. These requests '
          'fetch public meeting data; they do not include your recovery '
          'content. As with any internet request, the service you connect to '
          'can see your device\'s IP address.',
      'Opening directions for a meeting hands that meeting\'s address to your '
          'device\'s maps app. Tapping the support link opens Ko-fi in your '
          'browser. Both are outside this app and governed by their own '
          'privacy policies.',
    ],
  ),
  PolicySection(
    'Notifications',
    [
      'Reminders — daily review, bedtime meditation, sponsor calls, and '
          'meetings — are scheduled locally on your device. Their content is '
          'generated on the device and is not sent through any server.',
    ],
  ),
  PolicySection(
    'Children',
    [
      'Fearless Inventory is intended for adults in twelve-step recovery. It '
          'is not directed at children, and we do not knowingly collect '
          'information from them.',
    ],
  ),
  PolicySection(
    'Changes',
    [
      'If this policy changes, the date above will be updated and the revised '
          'policy will appear here in the app.',
    ],
  ),
  PolicySection(
    'Contact',
    [
      'Questions about this policy can be sent to the address published on '
          'the app\'s store listing.',
    ],
  ),
];
