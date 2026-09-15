import 'package:web/web.dart' as web;

/// After a successful cloud restore, the currently-running app instance
/// still has the *old* local database loaded in memory — a full reload
/// re-runs `main()`, which re-reads the just-overwritten IndexedDB envelope
/// from scratch via the normal `WebPassphraseScreen` boot path.
void reloadPage() => web.window.location.reload();
