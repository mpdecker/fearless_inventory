import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/connection/connection_stub.dart'
    if (dart.library.html) '../database/connection/connection_web.dart'
    if (dart.library.io) '../database/connection/connection_native.dart'
    as conn;
import '../services/cloud_backup_service.dart';
import '../services/cloud_backup_service_factory_stub.dart'
    if (dart.library.html) '../services/cloud_backup_service_factory_web.dart'
    if (dart.library.io) '../services/cloud_backup_service_factory_native.dart'
    as backup_factory;
import '../services/page_reload_stub.dart'
    if (dart.library.html) '../services/page_reload_web.dart'
    if (dart.library.io) '../services/page_reload_native.dart'
    as page_reload;
import 'auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service provider
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton [CloudBackupService] — override in tests to inject a mock.
/// Resolves to a real [WebCloudBackupService] on web, and throws if
/// anything on native ever actually calls it (it shouldn't — see the
/// design spec's "Scope" section).
final cloudBackupServiceProvider = Provider<CloudBackupService>(
  (_) => backup_factory.createCloudBackupService(),
);

/// Reloads the page after a successful restore — override in tests to
/// inject a no-op/spy, matching [cloudBackupServiceProvider].
final pageReloadProvider = Provider<void Function()>((_) => page_reload.reloadPage);

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

enum CloudSyncPhase {
  /// No account signed in, or sign-in status not yet resolved.
  idle,

  /// A cloud backup exists that this device hasn't reconciled with — the
  /// reconciliation dialog should be shown.
  needsReconciliation,

  /// Normal steady state: local writes are debounced into cloud backups.
  synced,
}

class CloudSyncState {
  final CloudSyncPhase phase;

  /// This device's local marker timestamp — "This device's data from
  /// [date]" in the reconciliation dialog. `null` if this device has never
  /// synced with the current account before.
  final DateTime? localBackedUpAt;

  /// The cloud backup's `updated` timestamp — "Cloud backup from [date]"
  /// in the reconciliation dialog. `null` before the first check completes.
  final DateTime? remoteUpdatedAt;

  const CloudSyncState({
    this.phase = CloudSyncPhase.idle,
    this.localBackedUpAt,
    this.remoteUpdatedAt,
  });

  CloudSyncState copyWith({
    CloudSyncPhase? phase,
    DateTime? localBackedUpAt,
    DateTime? remoteUpdatedAt,
  }) =>
      CloudSyncState(
        phase: phase ?? this.phase,
        localBackedUpAt: localBackedUpAt ?? this.localBackedUpAt,
        remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class CloudSyncNotifier extends Notifier<CloudSyncState> {
  Timer? _debounce;
  String? _uid;
  bool _isChecking = false;

  static const _debounceDelay = Duration(seconds: 30);

  @override
  CloudSyncState build() {
    conn.onLocalDbPersisted = _onLocalWrite;

    // `ref.listen` only fires on a *future* change to firebaseUserProvider —
    // it does not replay the value already current at registration time. In
    // real usage this notifier is only ever built once CloudSyncGate mounts,
    // which is always well after sign-in already completed (WebPassphraseScreen,
    // email verification, etc. all happen first) — so relying on `ref.listen`
    // alone meant the sign-in transition had always already happened and this
    // notifier silently never ran _checkOnSignIn. Read the current value
    // directly here to cover that already-signed-in-at-build-time case; ref.listen
    // below still covers later transitions (sign-out, then a different sign-in).
    final currentUser = ref.read(firebaseUserProvider).valueOrNull;
    if (currentUser != null) {
      _uid = currentUser.uid;
      unawaited(_checkOnSignIn(currentUser.uid));
    }

    ref.listen(firebaseUserProvider, (previous, next) {
      final user = next.valueOrNull;
      _uid = user?.uid;
      if (user == null) {
        _debounce?.cancel();
        state = const CloudSyncState();
        return;
      }
      unawaited(_checkOnSignIn(user.uid));
    });

    ref.onDispose(() {
      _debounce?.cancel();
      conn.onLocalDbPersisted = null;
    });

    return const CloudSyncState();
  }

  CloudBackupService get _service => ref.read(cloudBackupServiceProvider);

  Future<void> _checkOnSignIn(String uid) async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final marker = await _service.readMarker(uid);
      final remoteUpdatedAt = await _service.remoteBackupUpdatedAt(uid);

      if (_uid != uid) return; // signed out or switched accounts while this check was in flight

      if (remoteUpdatedAt == null) {
        // Nothing in the cloud yet for this account — this device's data
        // becomes the seed.
        final backedUpAt = await _service.backup(uid);
        state = CloudSyncState(
          phase: CloudSyncPhase.synced,
          localBackedUpAt: backedUpAt,
          remoteUpdatedAt: backedUpAt,
        );
        return;
      }

      final needsReconciliation =
          marker == null || marker.lastSeenCloudUpdatedAt.isBefore(remoteUpdatedAt);

      state = CloudSyncState(
        phase: needsReconciliation ? CloudSyncPhase.needsReconciliation : CloudSyncPhase.synced,
        localBackedUpAt: marker?.backedUpAt,
        remoteUpdatedAt: remoteUpdatedAt,
      );
    } catch (_) {
      // Swallow — matches the spec's "offline / storage rules not deployed
      // yet: treat as offline, silent retry" requirement. Deliberately do
      // NOT fall back to `synced`: we don't actually know whether this
      // account needs reconciliation, and guessing wrong could let a
      // debounced write silently overwrite a cloud backup this device
      // never actually reconciled with (violates "never silently overwrite
      // data"). Instead leave state as-is (still `idle` on the common
      // first-check-ever-fails case) — _onLocalWrite below re-attempts
      // this same check on the next local write rather than dead-ending.
    } finally {
      _isChecking = false;
    }
  }

  // Deliberately NOT a trailing-edge debounce (cancel-and-reschedule on every
  // write): a real device can produce a near-continuous stream of local
  // writes for tens of seconds at a time (e.g. the meeting-finder sync
  // fanning out to ~15 sources, each writing its own sync-metadata row on
  // completion) — cancel-and-reschedule would push the backup out on every
  // one of those writes and could starve it indefinitely. Scheduling only
  // when no timer is already pending guarantees a backup fires within
  // _debounceDelay of the *first* write in any burst, no matter how long
  // the burst continues.
  void _onLocalWrite() {
    final uid = _uid;
    if (uid == null) return;
    if (state.phase == CloudSyncPhase.idle) {
      // The sign-in check hasn't completed yet, or a prior attempt failed
      // and was swallowed (see _checkOnSignIn) — re-attempt it now rather
      // than silently dropping this write's chance to eventually trigger
      // a backup. _isChecking (inside _checkOnSignIn) already prevents
      // piling up concurrent attempts.
      unawaited(_checkOnSignIn(uid));
      return;
    }
    if (state.phase != CloudSyncPhase.synced) return; // needsReconciliation — wait for the user's choice
    if (_debounce != null) return;
    _debounce = Timer(_debounceDelay, () {
      _debounce = null;
      unawaited(_backupNow(uid));
    });
  }

  /// Test-only hook for exercising the debounce/throttle behavior above —
  /// `conn.onLocalDbPersisted` (the real caller) lives in a web-only file
  /// that can't be imported under `flutter test` (see Task 2's note).
  @visibleForTesting
  void debugTriggerLocalWrite() => _onLocalWrite();

  Future<void> _backupNow(String uid) async {
    try {
      final updatedAt = await _service.backup(uid);
      state = state.copyWith(
        phase: CloudSyncPhase.synced,
        localBackedUpAt: updatedAt,
        remoteUpdatedAt: updatedAt,
      );
    } catch (_) {
      // Swallow — matches the spec's "offline / upload failure: swallow
      // and let the next debounced write retry" requirement. _debounce is
      // already null by the time this runs, so the next local write
      // schedules a fresh attempt.
    }
  }

  // ── Called by the reconciliation dialog ──────────────────────────────────

  /// Restores the cloud backup after verifying [passphrase] decrypts it.
  /// Rethrows on a wrong passphrase — the dialog stays open and shows an
  /// error rather than this device's data being touched. On success,
  /// reloads the page so the app re-boots against the just-restored data.
  Future<void> useCloudBackup(String passphrase) async {
    final uid = _uid;
    if (uid == null) return;
    final updatedAt = await _service.restoreVerifyingPassphrase(uid, passphrase);
    state = CloudSyncState(
      phase: CloudSyncPhase.synced,
      localBackedUpAt: updatedAt,
      remoteUpdatedAt: updatedAt,
    );
    ref.read(pageReloadProvider)();
  }

  /// Re-runs the sign-in check against the cloud — per the design spec,
  /// called whenever the Account screen is opened while signed in, so a
  /// newer backup from another device ("occasionally opening the laptop")
  /// is detected without requiring a full page reload. A no-op while
  /// signed out or while a check is already in flight ([_isChecking]).
  Future<void> recheck() async {
    final uid = _uid;
    if (uid == null) return;
    await _checkOnSignIn(uid);
  }

  Future<void> keepLocalData() async {
    final uid = _uid;
    final remoteUpdatedAt = state.remoteUpdatedAt;
    if (uid == null || remoteUpdatedAt == null) return;
    await _service.markResolvedKeepingLocal(uid, remoteUpdatedAt);
    state = state.copyWith(phase: CloudSyncPhase.synced);
  }
}

final cloudSyncProvider = NotifierProvider<CloudSyncNotifier, CloudSyncState>(
  CloudSyncNotifier.new,
);
