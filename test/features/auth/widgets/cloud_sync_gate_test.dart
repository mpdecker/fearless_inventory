import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/providers/cloud_sync_provider.dart';
import 'package:fearless_inventory/features/auth/widgets/cloud_sync_gate.dart';
import 'package:fearless_inventory/features/auth/widgets/reconciliation_dialog.dart';

class _FakeCloudSyncNotifier extends CloudSyncNotifier {
  final CloudSyncState initial;
  _FakeCloudSyncNotifier(this.initial);

  @override
  CloudSyncState build() => initial;
}

Future<void> pumpGate(WidgetTester tester, CloudSyncState state) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cloudSyncProvider.overrideWith(() => _FakeCloudSyncNotifier(state)),
      ],
      child: const MaterialApp(
        home: CloudSyncGate(child: Text('home content')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the child and no dialog when synced', (tester) async {
    await pumpGate(tester, const CloudSyncState(phase: CloudSyncPhase.synced));

    expect(find.text('home content'), findsOneWidget);
    expect(find.byType(ReconciliationDialog), findsNothing);
  });

  testWidgets('renders the child and no dialog when idle', (tester) async {
    await pumpGate(tester, const CloudSyncState(phase: CloudSyncPhase.idle));

    expect(find.text('home content'), findsOneWidget);
    expect(find.byType(ReconciliationDialog), findsNothing);
  });

  testWidgets('always renders the child even under the dialog', (tester) async {
    await pumpGate(
      tester,
      CloudSyncState(
        phase: CloudSyncPhase.needsReconciliation,
        remoteUpdatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    expect(find.text('home content'), findsOneWidget);
  });
}
