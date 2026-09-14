import 'dart:async';

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
  }

  void _onLocalWrite() {
    if (state.phase != CloudSyncPhase.synced) return;
    final uid = _uid;
    if (uid == null) return;
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => unawaited(_backupNow(uid)));
  }

  Future<void> _backupNow(String uid) async {
    final updatedAt = await _service.backup(uid);
    state = state.copyWith(
      phase: CloudSyncPhase.synced,
      localBackedUpAt: updatedAt,
      remoteUpdatedAt: updatedAt,
    );
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
