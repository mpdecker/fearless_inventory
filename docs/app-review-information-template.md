# App Review Information

Paste the **Notes** block below into **App Store Connect → App Review Information**, and keep it handy for Google Play if a reviewer asks how to get in.

Verified against the shipping flow on 2026-07-28. If the sign-in flow changes,
re-check this file — inaccurate review notes cause avoidable rejections.

---

## Do reviewers need a demo account?

**No.** The app can be used fully without one.

This changed when local-only mode was added: the welcome screen offers
**"Continue without an account"**. Everything works in that mode — inventory,
daily reviews, amends, journal, literature, meetings — because recovery content
lives on the device rather than in an account.

App Store Connect asks whether a sign-in is required. Answer **no** and paste
the notes below so the reviewer knows the option exists and where to tap.

If you would rather hand them an account anyway, create a dedicated Firebase
test user, verify its email before submitting, and fill in:

- **Email:** `___________________________`
- **Password:** `___________________________`

---

## Notes for the reviewer (copy/paste)

```
No account is required to review this app.

On the welcome screen, tap "Continue without an account" to use the app in
local-only mode. Everything is available in that mode — no sign-up, no email
verification.

You will then be asked to create a 6-digit PIN. This is the app lock; it
protects the user's recovery journal on their own device. Any 6 digits work
(for example 123456), and you re-enter the same PIN to confirm. If the device
supports Face ID or Touch ID you will be offered biometric unlock — you can
tap "Skip".

After that you are on the home screen with full access.

About this app: Fearless Inventory is a private companion for twelve-step
recovery (AA/NA/OA). Everything the user writes — Step 4 inventory, Step 10
daily reviews, amends, journal entries — is stored only on the device in an
encrypted database and is never uploaded to us. An account is optional and is
used only for sign-in; recovery content is never attached to it.

Sign in with Apple and email/password are both available. Google Sign-In is
intentionally hidden in this build because its OAuth client is not yet
configured — we would rather hide it than ship a button that fails.

Privacy policy: https://mpdecker.github.io/fearless_inventory/privacy-policy.html
```

---

## The flow a reviewer will actually see

1. **Onboarding** — 4 intro pages, with a **Skip** link in the top right.
2. **Welcome screen** — *Sign In*, *Create Account*, or **Continue without an account**.
3. **PIN setup** — required, **exactly 6 digits**, entered twice. A local app
   lock, not an account credential.
4. **Biometric prompt** — only when the device supports it, and **Skip** is offered.
5. **Home screen** — full access.

## Points reviewers commonly ask about

- **Why location?** Only to find nearby recovery meetings, and only after the
  user grants permission. Coordinates stay on the device — distances are
  computed locally. Declining leaves the meeting finder usable by typing a city
  or zip.
- **Why contacts?** Optional import into the in-app Rolodex of recovery
  contacts. Imported entries stay in the local encrypted database.
- **Account deletion (Guideline 5.1.1(v))** — in-app at **Settings → Account →
  Delete Account**, with re-authentication.
- **Clearing local data** — **Settings → Clear All Data** wipes the on-device
  database. This is separate from deleting the cloud account: deleting the
  account does **not** erase local recovery content, and clearing local data
  does **not** delete the account.
- **Bundled literature** — the reader shows AA texts included with the app for
  personal study, plus the user's own highlights and notes.
