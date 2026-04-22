# App Review Information (template)

Copy the sections below into **App Store Connect → App Review Information** (and keep equivalent notes for Google Play internal testing if reviewers ask).

## Sign-in required

Reviewers land on **mandatory account** flow after onboarding: they must **sign in or register**, then **verify email** (if using email/password), then set a **6-digit app PIN** before reaching the home screen.

## Demo account (email / password)

- **Email:** `___________________________` *(dedicated Firebase test user; verify email once before submitting)*
- **Password:** `___________________________`

**PIN:** Any **6 digits** when prompted (e.g. `123456`). State the same PIN here if you want reviewers to use a fixed value:

- **Suggested PIN for review:** `___________________________`

## OAuth-only testing

If you also need Google or Apple sign-in verified, say so here and ensure **TestFlight** / **internal testing** builds have working OAuth configuration.

## Notes

- Recovery content is **local and encrypted**; deleting the **cloud account** from **Settings → Account → Delete Account** does **not** wipe on-device inventory unless the user uses **Clear All Data**.
