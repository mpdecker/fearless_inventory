import 'dart:convert';
import 'dart:io';

import 'package:fearless_inventory/core/literature/literature_book_catalog.dart';
import 'package:fearless_inventory/core/literature/literature_pdf_extraction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pdfrx/pdfrx.dart';

/// Maintainer-only: writes `assets/data/*.json` from bundled PDFs.
///
/// ```bash
/// flutter test integration_test/literature_generate_assets_test.dart -d macos \
///   --dart-define=GENERATE_LITERATURE_ASSETS=true
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const gen = bool.fromEnvironment(
    'GENERATE_LITERATURE_ASSETS',
    defaultValue: false,
  );

  testWidgets(
    'generate literature JSON assets from PDFs',
    (WidgetTester tester) async {
      final root = Directory.current.path;

      Future<void> writeJson(String relativePath, Object obj) async {
        final f = File('$root/$relativePath');
        await f.parent.create(recursive: true);
        await f.writeAsString(const JsonEncoder.withIndent('  ').convert(obj));
      }

      Future<PdfDocument> openLit(String relativePath) async {
        final f = File('$root/$relativePath');
        final bytes = await f.readAsBytes();
        return PdfDocument.openData(bytes, sourceName: relativePath);
      }

      // As Bill Sees It → reflection rows
      final absiDoc = await openLit(LiteratureBookCatalog.asBillSeesItAsset);
      List<Map<String, dynamic>> absiRows;
      try {
        absiRows = await extractAsBillReflectionRows(absiDoc);
      } finally {
        await absiDoc.dispose();
      }
      await writeJson('assets/data/as_bill_sees_it_reflections.json', absiRows);

      // Daily Reflections → calendar map
      final dailyDoc = await openLit(LiteratureBookCatalog.dailyReflectionsAsset);
      Map<String, String> dailyMap;
      try {
        dailyMap = await extractDailyReflectionCalendar(dailyDoc);
      } finally {
        await dailyDoc.dispose();
      }
      await writeJson('assets/data/daily_reflections_calendar.json', dailyMap);

      // Big Book + 12&12 prebuilt (uses Flutter asset bundle internally).
      for (final bookKey in [
        LiteratureBookCatalog.bigBookKey,
        LiteratureBookCatalog.twelveTwelveKey,
      ]) {
        final built = await buildBookPrebuiltJson(bookKey);
        await writeJson('assets/data/literature_${bookKey}_prebuilt.json', built);
      }

      expect(absiRows, isNotEmpty);
      expect(dailyMap, isNotEmpty);
    },
    skip: !gen,
  );
}
