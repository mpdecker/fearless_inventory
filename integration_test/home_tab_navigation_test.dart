import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/services/onboarding_service.dart';
import 'package:fearless_inventory/core/theme/app_theme.dart';
import 'package:fearless_inventory/features/home/home_screen.dart';
import 'package:fearless_inventory/features/meetings/services/meeting_sync_service.dart';

/// Exercises real [HomeScreen] tab switching (IndexedStack + heavy children).
/// Requires device or simulator (`path_provider`, secure storage for tab intros).
///
/// ```bash
/// flutter test integration_test/home_tab_navigation_test.dart
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const testKey =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

  testWidgets('HomeScreen bottom navigation switches primary tabs', (tester) async {
    for (var i = 1; i <= 4; i++) {
      await OnboardingService.markTabVisited(i);
    }

    final docs = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(docs.path, 'integration_home_nav.db'));
    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    final db = AppDatabase.forTesting(dbFile, testKey);
    addTearDown(() async {
      try {
        await db.close();
      } catch (_) {}
      try {
        if (await dbFile.exists()) await dbFile.delete();
      } catch (_) {}
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            ref.onDispose(() {});
            return db;
          }),
          meetingAdaptersProvider.overrideWith((ref) => []),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Recovery Companion'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    Future<void> tap(String label) async {
      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    await tap('Meetings');
    expect(find.text('Meetings'), findsWidgets);

    await tap('Step 12');
    expect(find.text('Step 12'), findsWidgets);

    await tap('Journal');
    expect(find.text('Journal'), findsWidgets);

    await tap('Insights');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Recovery Insights'), findsOneWidget);

    await tap('Dashboard');
    expect(find.text('Recovery Companion'), findsOneWidget);
  });
}
