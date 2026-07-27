import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/literature/literature_nav_models.dart';
import 'package:fearless_inventory/data/repositories/literature_annotation_repository.dart';
import 'package:fearless_inventory/features/settings/providers/literature_pdf_providers.dart';
import 'package:fearless_inventory/features/settings/screens/literature_section_reader_screen.dart';

const _bookKey = 'bigbook';
const _section = LiteratureNavSection(
  key: 'bb_howitworks',
  title: 'How It Works',
  startPage: 58,
  endPage: 60,
);
const _sampleText =
    'Rarely have we seen a person fail who has thoroughly followed our path.';

/// Create + seed the DB. Drift writes never complete under the testWidgets
/// fake-async clock, so callers must run this inside [WidgetTester.runAsync].
Future<AppDatabase> _seed() async {
  final db = AppDatabase.testing(NativeDatabase.memory());
  final repo = LiteratureAnnotationRepository(db);
  await repo.add(
    bookKey: _bookKey,
    startPage: 58,
    endPage: 60,
    sectionTitle: _section.title,
    selectionStart: 0,
    selectionEnd: 19, // "Rarely have we seen"
    selectedText: 'Rarely have we seen',
    color: 'yellow',
  );
  await repo.add(
    bookKey: _bookKey,
    startPage: 58,
    endPage: 60,
    sectionTitle: _section.title,
    selectionStart: 20,
    selectionEnd: 33, // "a person fail"
    selectedText: 'a person fail',
    color: 'green',
    note: 'the core promise',
  );
  return db;
}

Widget _harness(AppDatabase db) {
  final req = SectionTextRequest(
    bookKey: _bookKey,
    startPage: _section.startPage,
    endPage: _section.endPage,
  );
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      literatureSectionTextProvider(req)
          .overrideWith((ref) async => _sampleText),
    ],
    child: const MaterialApp(
      home: LiteratureSectionReaderScreen(
        bookKey: _bookKey,
        section: _section,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppDatabase> seededDb(WidgetTester tester) async {
    late AppDatabase db;
    await tester.runAsync(() async {
      db = await _seed();
    });
    return db;
  }

  // Explicit pumps: pumpAndSettle never settles because Drift's stream store
  // keeps scheduling zero-duration timers.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 350)); // sheet animation
  }

  // Replace the tree so Drift stream teardown timers run before the binding's
  // end-of-test pending-timer assertion.
  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<AppDatabase> emptyDb(WidgetTester tester) async {
    late AppDatabase db;
    await tester.runAsync(() async {
      db = AppDatabase.testing(NativeDatabase.memory());
    });
    return db;
  }

  testWidgets(
      'selecting text and tapping Highlight creates a correctly-anchored annotation',
      (tester) async {
    final db = await emptyDb(tester);
    addTearDown(db.close);
    final repo = LiteratureAnnotationRepository(db);

    await tester.pumpWidget(_harness(db));
    await settle(tester);

    // Select "Rarely have we seen" (offsets 0..19 of the sample text).
    final editable =
        tester.state<EditableTextState>(find.byType(EditableText));
    editable.userUpdateTextEditingValue(
      editable.textEditingValue.copyWith(
        selection: const TextSelection(baseOffset: 0, extentOffset: 19),
      ),
      SelectionChangedCause.tap,
    );
    await tester.pump();

    // Open the selection toolbar (our custom contextMenuBuilder) and Highlight.
    expect(editable.showToolbar(), isTrue);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Highlight'), findsOneWidget);
    await tester.tap(find.text('Highlight'));

    // Let the async DB write settle, then read it back.
    List<LiteratureAnnotation> rows = const [];
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      rows = await repo
          .watchForSection(bookKey: _bookKey, startPage: 58, endPage: 60)
          .first;
    });

    expect(rows, hasLength(1));
    expect(rows.single.selectionStart, 0);
    expect(rows.single.selectionEnd, 19);
    expect(rows.single.selectedText, 'Rarely have we seen');

    await teardownTree(tester);
  });

  testWidgets('renders section text and a badge with the annotation count',
      (tester) async {
    final db = await seededDb(tester);
    addTearDown(db.close);

    await tester.pumpWidget(_harness(db));
    await settle(tester);

    expect(find.text(_sampleText, findRichText: true), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('notes list opens and shows excerpts and notes', (tester) async {
    final db = await seededDb(tester);
    addTearDown(db.close);

    await tester.pumpWidget(_harness(db));
    await settle(tester);

    await tester.tap(find.byTooltip('Highlights & notes'));
    await settle(tester);

    expect(find.text('Highlights & notes (2)'), findsOneWidget);
    expect(find.text('Rarely have we seen'), findsOneWidget);
    expect(find.text('a person fail'), findsOneWidget);
    expect(find.text('the core promise'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('tapping a note opens the editor prefilled, and delete removes it',
      (tester) async {
    final db = await seededDb(tester);
    addTearDown(db.close);

    await tester.pumpWidget(_harness(db));
    await settle(tester);

    await tester.tap(find.byTooltip('Highlights & notes'));
    await settle(tester);
    await tester.tap(find.text('a person fail'));
    await settle(tester);

    expect(find.widgetWithText(TextField, 'the core promise'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await settle(tester);

    // Badge now reflects one remaining annotation.
    expect(find.text('1'), findsOneWidget);

    await teardownTree(tester);
  });
}
