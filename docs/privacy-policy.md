# Fearless Inventory — Privacy Policy

_Last updated: September 14, 2026_

<!--
  MAINTAINER NOTE (not rendered anywhere, including the published site).

  This file is the source of truth for the hosted policy. The app renders the
  same policy from lib/features/settings/privacy_policy_content.dart — when you
  change one, change the other and bump the date in both. A test enforces that
  the date and section headings match.

  Publishing: .github/workflows/pages.yml converts this file to HTML via
  tool/render_privacy_policy.py and deploys it to GitHub Pages on every push to
  master. Only that generated page is published — docs/ is never served.
-->


## The short version

Fearless Inventory is built so your recovery work stays yours. Your inventory,
daily reviews, amends, journal entries, literature highlights and notes,
meditation history, sponsee records, contacts, and sobriety date are stored in
an encrypted database on this device. We cannot read them.

On the web version only, if you create an account, an encrypted copy of that
same database may be backed up so you can restore it on another device. It is
protected by a passphrase only you know — we cannot decrypt it. See "Optional
account" below for what that means and how to avoid it.

We do not use analytics, advertising, or tracking of any kind. We do not sell
or share your information.

## What stays on your device

All recovery content you enter — Step 4 resentments, fears, and harms; Step 10
daily reviews; Step 8/9 amends; journal entries; literature highlights and
notes; meditation sessions; service commitments; sponsee and Rolodex records;
meeting attendance; and your sobriety date — is written to a local database
encrypted on your device (SQLCipher).

Your app-lock PIN is held separately, in your device's secure storage (iOS
Keychain / Android encrypted storage), as a hash — not as the digits you type.

If you import contacts into your Rolodex, those names and numbers are copied
into the same local encrypted database. They are not sent anywhere.

## Optional account

You can use the entire app without an account by choosing "Continue without an
account". In that mode we hold no information about you at all.

If you do create an account, it is handled by Google Firebase Authentication,
which receives your email address and, depending on the method you choose, an
identifier from Google or Apple Sign-In.

On the mobile apps (iOS/Android), an account exists only to sign you in — your
recovery content is never attached to it or uploaded, exactly as described
above.

On the web version, signing in additionally backs up an encrypted copy of your
local database to our server so you can restore it on another device or
browser. We never see the unencrypted content: it is encrypted on your device
(AES-256-GCM) with a key derived from a passphrase you choose, before it ever
leaves your browser, using the same encryption that protects the local
database. We do not know your passphrase and cannot recover it or decrypt your
backup if you forget it. If a browser session detects a backup that differs
from what is on that device, it asks you which version to keep before changing
anything.

You can delete your account at any time from Settings → Account, which also
deletes any cloud backup. You can erase all local recovery data from Settings
→ Clear All Data.

## Location

Location is used only to find recovery meetings near you, and only if you grant
permission. Your coordinates are used on your device to calculate distances to
meetings — they are not transmitted to us or to anyone else.

If you instead type a city or zip code to search, that text (not your
coordinates) is sent to Nominatim, the OpenStreetMap geocoding service, to turn
it into a map location.

## Network connections

Meeting listings are downloaded from public recovery directories, such as AA
intergroup services and NA meeting search. These requests fetch public meeting
data; they do not include your recovery content. As with any internet request,
the service you connect to can see your device's IP address.

Opening directions for a meeting hands that meeting's address to your device's
maps app. Tapping the support link opens Ko-fi in your browser. Both are
outside this app and governed by their own privacy policies.

## Notifications

Reminders — daily review, bedtime meditation, sponsor calls, and meetings — are
scheduled locally on your device. Their content is generated on the device and
is not sent through any server.

## Children

Fearless Inventory is intended for adults in twelve-step recovery. It is not
directed at children, and we do not knowingly collect information from them.

## Changes

If this policy changes, the date above will be updated and the revised policy
will appear in the app.

## Contact

Questions about this policy can be sent to the address published on the app's
store listing.
