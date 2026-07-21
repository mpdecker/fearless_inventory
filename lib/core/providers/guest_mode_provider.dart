import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/guest_mode_service.dart';

/// Whether the user is in local-only ("guest") mode — using the app without a
/// Firebase account. Seeded in `main()` from [GuestModeService] and overridden
/// at the root [ProviderScope] to avoid a first-frame flicker, mirroring
/// `appLockProvider`.
class GuestModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Opt into local-only use. Persists the choice and updates state so
  /// [BootstrapShell] rebuilds past the sign-in gate.
  Future<void> enterGuestMode() async {
    await GuestModeService.enable();
    state = true;
  }

  /// Leave local-only mode (e.g. after creating a real account), so the
  /// sign-in gate applies again on the next signed-out launch.
  Future<void> exitGuestMode() async {
    await GuestModeService.disable();
    state = false;
  }
}

final guestModeProvider =
    NotifierProvider<GuestModeNotifier, bool>(GuestModeNotifier.new);
