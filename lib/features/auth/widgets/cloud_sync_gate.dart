import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/cloud_sync_provider.dart';
import 'reconciliation_dialog.dart';

/// Wraps the signed-in web app shell. Watches [cloudSyncProvider] and shows
/// [ReconciliationDialog] whenever a conflict is detected, without ever
/// blocking or replacing [child] — the dialog floats above it.
class CloudSyncGate extends ConsumerStatefulWidget {
  final Widget child;
  const CloudSyncGate({super.key, required this.child});

  @override
  ConsumerState<CloudSyncGate> createState() => _CloudSyncGateState();
}

class _CloudSyncGateState extends ConsumerState<CloudSyncGate> {
  bool _dialogShowing = false;

  void _maybeShowDialog(CloudSyncState state) {
    if (state.phase != CloudSyncPhase.needsReconciliation) return;
    if (_dialogShowing) return;
    final remoteUpdatedAt = state.remoteUpdatedAt;
    if (remoteUpdatedAt == null) return;

    _dialogShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final notifier = ref.read(cloudSyncProvider.notifier);
      await showDialog<void>(
        context: context,
        builder: (_) => ReconciliationDialog(
          remoteUpdatedAt: remoteUpdatedAt,
          localBackedUpAt: state.localBackedUpAt,
          onUseCloudBackup: notifier.useCloudBackup,
          onKeepLocalData: () => notifier.keepLocalData(),
        ),
      );
      _dialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CloudSyncState>(cloudSyncProvider, (previous, next) {
      _maybeShowDialog(next);
    });
    return widget.child;
  }
}
