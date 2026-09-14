import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/services/cloud_backup_service.dart';
import 'package:fearless_inventory/features/auth/widgets/reconciliation_dialog.dart';

void main() {
  Future<void> pumpDialog(
    WidgetTester tester, {
    required DateTime remoteUpdatedAt,
    DateTime? localBackedUpAt,
    Future<void> Function(String)? onUseCloudBackup,
    VoidCallback? onKeepLocalData,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => ReconciliationDialog(
                remoteUpdatedAt: remoteUpdatedAt,
                localBackedUpAt: localBackedUpAt,
                onUseCloudBackup: onUseCloudBackup ?? (_) async {},
                onKeepLocalData: onKeepLocalData ?? () {},
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows both the cloud and local dates', (tester) async {
    await pumpDialog(
      tester,
      remoteUpdatedAt: DateTime.utc(2026, 2, 15, 10, 30),
      localBackedUpAt: DateTime.utc(2026, 1, 1, 9),
    );

    expect(find.textContaining('Cloud backup'), findsOneWidget);
    expect(find.textContaining("This device's data"), findsOneWidget);
  });

  testWidgets('shows a fallback when this device has no earlier backup', (tester) async {
    await pumpDialog(
      tester,
      remoteUpdatedAt: DateTime.utc(2026, 2, 15, 10, 30),
      localBackedUpAt: null,
    );

    expect(find.textContaining('no earlier backup'), findsOneWidget);
  });

  testWidgets("Keep this device's data calls onKeepLocalData and closes the dialog", (tester) async {
    var called = false;
    await pumpDialog(
      tester,
      remoteUpdatedAt: DateTime.utc(2026, 2, 15),
      onKeepLocalData: () => called = true,
    );

    await tester.tap(find.text("Keep this device's data"));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    expect(find.byType(ReconciliationDialog), findsNothing);
  });

  testWidgets('Use cloud backup requires a non-empty passphrase', (tester) async {
    var called = false;
    await pumpDialog(
      tester,
      remoteUpdatedAt: DateTime.utc(2026, 2, 15),
      onUseCloudBackup: (_) async => called = true,
    );

    await tester.tap(find.text('Use cloud backup'));
    await tester.pumpAndSettle();

    expect(called, isFalse);
    expect(find.textContaining('Enter the passphrase'), findsOneWidget);
  });

  testWidgets('Use cloud backup calls onUseCloudBackup with the entered passphrase', (tester) async {
    String? received;
    await pumpDialog(
      tester,
      remoteUpdatedAt: DateTime.utc(2026, 2, 15),
      onUseCloudBackup: (p) async => received = p,
    );

    await tester.enterText(find.byType(TextField), 'my-passphrase');
    await tester.tap(find.text('Use cloud backup'));
    await tester.pumpAndSettle();

    expect(received, 'my-passphrase');
  });

  testWidgets('shows an error and stays open when onUseCloudBackup throws', (tester) async {
    await pumpDialog(
      tester,
      remoteUpdatedAt: DateTime.utc(2026, 2, 15),
      onUseCloudBackup: (_) async => throw Exception('wrong passphrase'),
    );

    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.tap(find.text('Use cloud backup'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not decrypt'), findsOneWidget);
    expect(find.byType(ReconciliationDialog), findsOneWidget);
  });

  testWidgets(
    'shows a distinct network error (not "wrong passphrase") when the backup is unreachable',
    (tester) async {
      await pumpDialog(
        tester,
        remoteUpdatedAt: DateTime.utc(2026, 2, 15),
        onUseCloudBackup: (_) async => throw const CloudBackupUnreachable('network error'),
      );

      await tester.enterText(find.byType(TextField), 'correct-passphrase');
      await tester.tap(find.text('Use cloud backup'));
      await tester.pumpAndSettle();

      expect(find.textContaining("Couldn't reach the cloud backup"), findsOneWidget);
      expect(find.textContaining('Could not decrypt'), findsNothing);
      expect(find.byType(ReconciliationDialog), findsOneWidget);
    },
  );
}
