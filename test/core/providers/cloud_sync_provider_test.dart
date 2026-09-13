import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fearless_inventory/core/providers/auth_provider.dart';
import 'package:fearless_inventory/core/providers/cloud_sync_provider.dart';
import 'package:fearless_inventory/core/services/cloud_backup_service.dart';
import 'package:fearless_inventory/core/services/firebase_auth_service.dart';

class MockCloudBackupService extends Mock implements CloudBackupService {}

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class MockUser extends Mock implements User {}

void main() {
  late StreamController<User?> authController;
  late MockFirebaseAuthService mockAuth;
  late MockCloudBackupService mockBackup;
  late ProviderContainer container;

  const uid = 'test-uid';

  setUp(() {
    authController = StreamController<User?>.broadcast();
    mockAuth = MockFirebaseAuthService();
    when(() => mockAuth.userChanges).thenAnswer((_) => authController.stream);
    mockBackup = MockCloudBackupService();

    container = ProviderContainer(
      overrides: [
        firebaseAuthServiceProvider.overrideWithValue(mockAuth),
        cloudBackupServiceProvider.overrideWithValue(mockBackup),
        pageReloadProvider.overrideWithValue(() {}),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(authController.close);
  });

  MockUser signedInUser() {
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    return user;
  }

  test('starts idle before any sign-in', () {
    final state = container.read(cloudSyncProvider);
    expect(state.phase, CloudSyncPhase.idle);
  });

  test('seeds a backup and becomes synced when no remote backup exists yet', () async {
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => null);
    final seededAt = DateTime.utc(2026, 1, 1);
    when(() => mockBackup.backup(uid)).thenAnswer((_) async => seededAt);

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.synced);
    verify(() => mockBackup.backup(uid)).called(1);
  });

  test('enters needsReconciliation when the cloud has no local marker but does have a backup', () async {
    final remoteUpdatedAt = DateTime.utc(2026, 2, 1);
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => remoteUpdatedAt);

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    final state = container.read(cloudSyncProvider);
    expect(state.phase, CloudSyncPhase.needsReconciliation);
    expect(state.remoteUpdatedAt, remoteUpdatedAt);
    verifyNever(() => mockBackup.backup(uid));
  });

  test('enters needsReconciliation when the cloud is newer than this device\'s marker', () async {
    final localMarker = CloudSyncMarker(
      backedUpAt: DateTime.utc(2026, 1, 1),
      lastSeenCloudUpdatedAt: DateTime.utc(2026, 1, 1),
    );
    final remoteUpdatedAt = DateTime.utc(2026, 2, 1); // newer
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => localMarker);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => remoteUpdatedAt);

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.needsReconciliation);
  });

  test('goes straight to synced when this device\'s marker already matches the cloud', () async {
    final sameTime = DateTime.utc(2026, 1, 1);
    final localMarker = CloudSyncMarker(backedUpAt: sameTime, lastSeenCloudUpdatedAt: sameTime);
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => localMarker);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => sameTime);

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.synced);
    verifyNever(() => mockBackup.backup(uid));
  });

  test('resets to idle on sign-out', () async {
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.backup(uid)).thenAnswer((_) async => DateTime.utc(2026, 1, 1));

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();
    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.synced);

    authController.add(null);
    await pumpEventQueue();
    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.idle);
  });

  test('does not overwrite state or call backup for a stale sign-in check after sign-out', () async {
    final markerCompleter = Completer<CloudSyncMarker?>();
    final remoteCompleter = Completer<DateTime?>();
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) => markerCompleter.future);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) => remoteCompleter.future);

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    // Sign out while the check is still in flight.
    authController.add(null);
    await pumpEventQueue();
    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.idle);

    // Now let the stale check's futures resolve as the seed-backup path
    // (no remote backup yet) — this is the branch that would otherwise
    // call `_service.backup(uid)` for the now-signed-out account.
    markerCompleter.complete(null);
    remoteCompleter.complete(null);
    await pumpEventQueue();

    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.idle);
    verifyNever(() => mockBackup.backup(uid));
  });

  test('useCloudBackup restores and transitions to synced', () async {
    final remoteUpdatedAt = DateTime.utc(2026, 2, 1);
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => remoteUpdatedAt);
    when(() => mockBackup.restoreVerifyingPassphrase(uid, 'correct-passphrase'))
        .thenAnswer((_) async => remoteUpdatedAt);

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();
    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.needsReconciliation);

    await container.read(cloudSyncProvider.notifier).useCloudBackup('correct-passphrase');

    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.synced);
    verify(() => mockBackup.restoreVerifyingPassphrase(uid, 'correct-passphrase')).called(1);
  });

  test('useCloudBackup with a wrong passphrase propagates the error and stays in needsReconciliation', () async {
    final remoteUpdatedAt = DateTime.utc(2026, 2, 1);
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => remoteUpdatedAt);
    when(() => mockBackup.restoreVerifyingPassphrase(uid, 'wrong'))
        .thenThrow(Exception('bad passphrase'));

    var reloadCalled = false;
    final localContainer = ProviderContainer(
      overrides: [
        firebaseAuthServiceProvider.overrideWithValue(mockAuth),
        cloudBackupServiceProvider.overrideWithValue(mockBackup),
        pageReloadProvider.overrideWithValue(() => reloadCalled = true),
      ],
    );
    addTearDown(localContainer.dispose);

    localContainer.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    await expectLater(
      localContainer.read(cloudSyncProvider.notifier).useCloudBackup('wrong'),
      throwsException,
    );
    expect(localContainer.read(cloudSyncProvider).phase, CloudSyncPhase.needsReconciliation);
    expect(reloadCalled, isFalse);
  });

  test('useCloudBackup reloads the page exactly once after a successful restore', () async {
    final remoteUpdatedAt = DateTime.utc(2026, 2, 1);
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => remoteUpdatedAt);
    when(() => mockBackup.restoreVerifyingPassphrase(uid, 'correct-passphrase'))
        .thenAnswer((_) async => remoteUpdatedAt);

    var reloadCount = 0;
    final localContainer = ProviderContainer(
      overrides: [
        firebaseAuthServiceProvider.overrideWithValue(mockAuth),
        cloudBackupServiceProvider.overrideWithValue(mockBackup),
        pageReloadProvider.overrideWithValue(() => reloadCount++),
      ],
    );
    addTearDown(localContainer.dispose);

    localContainer.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();
    expect(localContainer.read(cloudSyncProvider).phase, CloudSyncPhase.needsReconciliation);

    await localContainer.read(cloudSyncProvider.notifier).useCloudBackup('correct-passphrase');

    expect(localContainer.read(cloudSyncProvider).phase, CloudSyncPhase.synced);
    expect(reloadCount, 1);
  });

  test('keepLocalData records the resolution and transitions to synced', () async {
    final remoteUpdatedAt = DateTime.utc(2026, 2, 1);
    when(() => mockBackup.readMarker(uid)).thenAnswer((_) async => null);
    when(() => mockBackup.remoteBackupUpdatedAt(uid)).thenAnswer((_) async => remoteUpdatedAt);
    when(() => mockBackup.markResolvedKeepingLocal(uid, remoteUpdatedAt))
        .thenAnswer((_) async {});

    container.listen(cloudSyncProvider, (_, __) {});
    authController.add(signedInUser());
    await pumpEventQueue();

    await container.read(cloudSyncProvider.notifier).keepLocalData();

    expect(container.read(cloudSyncProvider).phase, CloudSyncPhase.synced);
    verify(() => mockBackup.markResolvedKeepingLocal(uid, remoteUpdatedAt)).called(1);
  });
}
