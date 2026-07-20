import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/repositories/repository_test_support.dart';
import 'widget_encrypted_db_binding.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'openTempEncryptedDbForWidgetTest + SQL completes (regression: no hang)',
    (tester) async {
      final env = await openTempEncryptedDbForWidgetTest(
        tester,
        'fi_widget_binding_regression_',
      );
      addTearDown(
        () => disposeTempDb(
          db: env.db,
          dir: env.dir,
          dbFile: env.dbFile,
        ),
      );

      await tester.pumpWidget(const MaterialApp(home: Text('ok')));
      await tester.pump();

      final rows = await env.db.customSelect('SELECT 1 AS x').get();
      expect(rows.single.data['x'], 1);
      expect(find.text('ok'), findsOneWidget);

      await resetWidgetBindingAfterDriftStreams(tester);
    },
  );

  testWidgets('resetWidgetBindingAfterDriftStreams is safe with no navigator',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('x')));
    await tester.pump();
    await resetWidgetBindingAfterDriftStreams(tester);
    await tester.pumpWidget(const MaterialApp(home: Text('y')));
    await tester.pump();
    expect(find.text('y'), findsOneWidget);
  });
}
