import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/models/amends_type.dart';
import 'package:fearless_inventory/data/services/export_service.dart';

/// Device / simulator only (path_provider, file I/O):
/// `flutter test integration_test/export_share_flow_test.dart`
///
/// Covers Phase 7 automation gate: PDF bytes build, Documents/exports,
/// Excel encode, UTF-8 CSV with BOM. Print dialog and UIActivityViewController
/// require manual checks on iOS.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'export: path_provider dirs, Step 4 PDF bytes, xlsx/csv under exports',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    final docs = await getApplicationDocumentsDirectory();
    expect(docs.path, isNotEmpty);
    final tmp = await getTemporaryDirectory();
    expect(tmp.path, isNotEmpty);

    final exports = await ExportService.ensureExportsDirectory();
    expect(exports.path, endsWith('${Platform.pathSeparator}exports'));
    expect(await exports.exists(), isTrue);

    final now = DateTime.now();
    final pdfBytes = await ExportService.buildBigBookWorksheetPdfBytes(
      resentments: [
        Resentment(
          id: 1,
          person: 'Sample person',
          cause: 'Cause',
          affects: 'self_esteem',
          myPart: 'My part',
          flagForReview: false,
          createdAt: now,
        ),
      ],
      fears: <Fear>[],
      harms: <Harm>[],
    );
    expect(pdfBytes.length, greaterThan(100));
    expect(String.fromCharCodes(pdfBytes.take(4)), '%PDF');

    final xlsx = await ExportService.buildAmendsExcelXFile([
      Amend(
        id: 1,
        person: 'Alex',
        amendsType: AmendsType.personal,
        plan: 'Talk honestly',
        priority: 1,
        status: 'pending',
        createdAt: now,
      ),
    ]);
    expect(await File(xlsx.path).exists(), isTrue);
    expect(await File(xlsx.path).length(), greaterThan(50));

    final csvX = await ExportService.buildAmendsCsvXFile([
      Amend(
        id: 2,
        person: 'José',
        amendsType: AmendsType.financial,
        plan: 'Repay €50',
        priority: 2,
        status: 'step8',
        createdAt: now,
      ),
    ]);
    final csvBytes = await File(csvX.path).readAsBytes();
    expect(
      csvBytes.length >= 3 &&
          csvBytes[0] == 0xEF &&
          csvBytes[1] == 0xBB &&
          csvBytes[2] == 0xBF,
      isTrue,
      reason: 'UTF-8 BOM for Excel/Numbers',
    );
    final csvText = utf8.decode(csvBytes);
    expect(csvText, contains('José'));
    expect(csvText, contains('Repay €50'));
  });
}
