# Google Play — Data Safety answers

Transcribe these into **Play Console → App content → Data safety**. The same
facts drive the Apple **App Privacy** questionnaire in App Store Connect.

Derived from an audit of what actually leaves the device (network calls,
adapters, and the Firebase integration), not from assumptions. Verified
2026-07-28. **Re-check if a new SDK or network call is added.**

Google's definition of *collected* is "transmitted off the device". Data that
stays local is **not** collected, even when it is sensitive — which is most of
what this app stores.

---

## Summary

| Data type | Collected? | Notes |
|---|---|---|
| Email address | **Yes** — optional | Only if the user creates an account |
| Name | **Yes** — optional | Optional display name at registration |
| User IDs | **Yes** — optional | Firebase Auth UID |
| Approximate location | **Decision needed** | See the note below |
| Precise location | **No** | Coordinates never leave the device |
| Contacts | **No** | Imported into the local encrypted database only |
| Health / "other" personal info (recovery content) | **No** | Encrypted on device, never uploaded |
| App activity, crash logs, diagnostics, ads | **No** | No analytics, ads, or crash SDK |

---

## Data collected

All three are **optional**, because the app is fully usable via "Continue
without an account". Declare them as collected but not required.

### Email address
- **Collected:** Yes · **Shared:** No
- **Optional:** Yes — only when the user creates an account
- **Purpose:** Account management (authentication)
- Handled by Google Firebase Authentication.

### Name
- **Collected:** Yes · **Shared:** No
- **Optional:** Yes — the display name field at registration is optional
- **Purpose:** Account management

### User IDs
- **Collected:** Yes · **Shared:** No
- **Optional:** Yes — only exists once an account is created
- **Purpose:** Account management
- The Firebase Auth UID. Never associated with recovery content.

---

## Decision needed: approximate location

**The facts.** GPS coordinates never leave the device — distances to meetings
are computed locally. But if the user *types* a city or zip to search, that
text is sent to Nominatim (OpenStreetMap) to geocode it:

```
https://nominatim.openstreetmap.org/search?q=<what the user typed>&...
```

**Why it's ambiguous.** The transmitted value is text the user typed, not a
device-derived location. It is also sent to a third party, so it is arguably
*shared* approximate location.

**Recommendation:** declare **Approximate location — collected, shared, optional,
purpose: App functionality**. It is the conservative reading, and an
under-declaration is the expensive kind of mistake. Note in the form that
precise location is **not** collected.

Do not declare **Precise location** — verified that coordinates are never
transmitted.

---

## Data explicitly NOT collected

Worth being deliberate here, since a reviewer may expect otherwise from a
recovery app.

- **Recovery content** — Step 4 inventory, Step 10 reviews, amends, journal
  entries, literature highlights and notes, meditation history, sponsee
  records. Stored in a SQLCipher-encrypted local database. Never uploaded.
  This is the most sensitive data the app holds and it is never collected.
- **Contacts** — optional import into the local Rolodex. Stays on device.
- **Sobriety date** and **app-lock PIN** — device secure storage; the PIN is
  stored as a hash.
- **Crash logs / diagnostics / analytics / advertising** — no such SDK is
  present in the dependency tree.

---

## Security practices

- **Encrypted in transit:** **Yes.** All network calls are HTTPS. Android sets
  `usesCleartextTraffic="false"`; iOS uses default App Transport Security with
  no exceptions.
- **Users can request data deletion:** **Yes.** In-app account deletion at
  **Settings → Account → Delete Account**, and **Settings → Clear All Data**
  erases the local database.
- **Data can be deleted without deleting the account:** Yes — the two are
  separate actions.
- **Committed to Play Families policy:** No — the app targets adults.
- **Independent security review:** No.

---

## Things that are easy to get wrong here

- Meeting listings are fetched from public directories (AA intergroup, NA
  meeting search). No user data is sent — but those services see the device IP,
  as with any request. This is not "collection" by the app.
- The support link opens Ko-fi and directions open the device maps app. Both
  are outside the app and governed by their own policies.
- Recovery/sobriety information could be read as health data. It is genuinely
  never transmitted, so it is not declared — but be ready to explain that the
  encryption and local-only storage are what make that true.
