import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/database.dart';
import '../../features/journal/data/step_tradition_content.dart';

/// dart_pdf's default Helvetica is a Type1 base font with no Unicode coverage,
/// so em dashes, ellipses and smart quotes render as blanks in exports. Map the
/// common typographic forms onto ASCII before they reach the page.
///
/// Text outside Latin-1 (CJK, Cyrillic, emoji) still cannot render; that needs
/// a bundled Unicode TTF.
String _pdfSafe(String s) => s
    .replaceAll('\u2014', '--')
    .replaceAll('\u2013', '-')
    .replaceAll('\u2026', '...')
    .replaceAll('\u2018', "'")
    .replaceAll('\u2019', "'")
    .replaceAll('\u201C', '"')
    .replaceAll('\u201D', '"')
    .replaceAll('\u00A0', ' ');


// Affects lookup: DB value → human-readable label
const _affectsLabels = {
  'self_esteem': 'Self-Esteem',
  'security': 'Security',
  'ambitions': 'Ambitions',
  'personal_relations': 'Personal Relations',
  'sex_relations': 'Sex Relations',
  'pride': 'Pride',
  'pocketbook': 'Pocketbook',
  'fears': 'Fears',
};

String _formatAffects(String raw) {
  if (raw.isEmpty) return '—';
  return raw
      .split(',')
      .where((s) => s.isNotEmpty)
      .map((k) => _affectsLabels[k] ?? k)
      .join('\n');
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared style helpers
// ─────────────────────────────────────────────────────────────────────────────

pw.TextStyle _header0() =>
    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold);

pw.TextStyle _header1() =>
    pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold);

pw.TextStyle _body() => const pw.TextStyle(fontSize: 9);

pw.TextStyle _bodySm() => const pw.TextStyle(fontSize: 8);

pw.TextStyle _label() =>
    pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold,
        color: PdfColors.grey700);

pw.Widget _tableCell(String text,
    {bool isHeader = false,
    PdfColor? bg,
    pw.Alignment align = pw.Alignment.topLeft}) {
  return pw.Container(
    color: bg,
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
    alignment: align,
    child: pw.Text(_pdfSafe(
      text),
      style: isHeader ? _label() : _body(),
    ),
  );
}

pw.Widget _disclaimer() => pw.Text(_pdfSafe(
      'This document is for personal use with your sponsor. '
      'Not affiliated with AA World Services, Inc.'),
      style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500,
          fontStyle: pw.FontStyle.italic),
    );

// ─────────────────────────────────────────────────────────────────────────────
// 1. Big Book 4-Column Step 4 Worksheet PDF
// ─────────────────────────────────────────────────────────────────────────────

/// Generates the classic Big Book Step Four worksheet:
///   Col 1  I'm resentful at…
///   Col 2  The cause
///   Col 3  Affects my…
///   Col 4  My part / Where was I to blame?
///
/// Followed by fears and harms in their own 3-column tables.
/// Outputs via the system print/share dialog so it can be printed or
/// saved to Files without any cloud upload.
class ExportService {
  /// App documents subdirectory for shareable exports (persists across sessions;
  /// visible under the app’s Documents in Files on iOS).
  static Future<Directory> ensureExportsDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'exports'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static pw.Document _bigBookWorksheetDocument({
    required List<Resentment> resentments,
    required List<Fear> fears,
    required List<Harm> harms,
    String title = 'Step Four — Personal Inventory',
  }) {
    final pdf = pw.Document();
    final dateStr = DateTime.now().toIso8601String().split('T').first;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(_pdfSafe(title), style: _header0()),
            pw.SizedBox(height: 2),
            pw.Text(_pdfSafe('Date: $dateStr   |   '
                '${resentments.length} resentments · '
                '${fears.length} fears · '
                '${harms.length} harms'),
                style: _bodySm()),
            pw.SizedBox(height: 6),
            _disclaimer(),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (context) => [
          // ── Resentments ──────────────────────────────────────────────────
          pw.Text(_pdfSafe('RESENTMENTS'), style: _header1()),
          pw.SizedBox(height: 6),
          if (resentments.isEmpty)
            pw.Text(_pdfSafe('No resentments recorded.'), style: _body())
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.2), // Person
                1: const pw.FlexColumnWidth(3.0), // Cause
                2: const pw.FlexColumnWidth(2.0), // Affects
                3: const pw.FlexColumnWidth(2.8), // My Part
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.blueGrey100),
                  children: [
                    _tableCell("I'M RESENTFUL AT", isHeader: true),
                    _tableCell('THE CAUSE', isHeader: true),
                    _tableCell('AFFECTS MY…', isHeader: true),
                    _tableCell('WHERE WAS I TO BLAME?', isHeader: true),
                  ],
                ),
                // Data rows with alternating tint
                ...resentments.asMap().entries.map((entry) {
                  final i = entry.key;
                  final r = entry.value;
                  final bg =
                      i.isOdd ? PdfColors.grey50 : PdfColors.white;
                  return pw.TableRow(
                    children: [
                      _tableCell(r.person, bg: bg),
                      _tableCell(r.cause, bg: bg),
                      _tableCell(_formatAffects(r.affects), bg: bg),
                      _tableCell(r.myPart, bg: bg),
                    ],
                  );
                }),
              ],
            ),

          pw.SizedBox(height: 24),

          // ── Fears ────────────────────────────────────────────────────────
          pw.Text(_pdfSafe('FEARS'), style: _header1()),
          pw.SizedBox(height: 6),
          if (fears.isEmpty)
            pw.Text(_pdfSafe('No fears recorded.'), style: _body())
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5),
                1: const pw.FlexColumnWidth(3.5),
                2: const pw.FlexColumnWidth(4.0),
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.blueGrey100),
                  children: [
                    _tableCell('WHAT AM I AFRAID OF?', isHeader: true),
                    _tableCell('WHY DO I HAVE THIS FEAR?', isHeader: true),
                    _tableCell('MY PART / SELF-RELIANCE SHOWN', isHeader: true),
                  ],
                ),
                ...fears.asMap().entries.map((entry) {
                  final i = entry.key;
                  final f = entry.value;
                  final bg = i.isOdd ? PdfColors.grey50 : PdfColors.white;
                  return pw.TableRow(children: [
                    _tableCell(f.subject, bg: bg),
                    _tableCell(f.why, bg: bg),
                    _tableCell(f.myPart, bg: bg),
                  ]);
                }),
              ],
            ),

          pw.SizedBox(height: 24),

          // ── Harms ────────────────────────────────────────────────────────
          pw.Text(_pdfSafe('HARMS TO OTHERS'), style: _header1()),
          pw.SizedBox(height: 6),
          if (harms.isEmpty)
            pw.Text(_pdfSafe('No harms recorded.'), style: _body())
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.2),
                1: const pw.FlexColumnWidth(3.5),
                2: const pw.FlexColumnWidth(3.0),
                3: const pw.FlexColumnWidth(1.3),
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.blueGrey100),
                  children: [
                    _tableCell('WHO DID I HARM?', isHeader: true),
                    _tableCell('WHAT WAS THE CONDUCT?', isHeader: true),
                    _tableCell('MY PART', isHeader: true),
                    _tableCell('AMENDS DONE?', isHeader: true,
                        align: pw.Alignment.topCenter),
                  ],
                ),
                ...harms.asMap().entries.map((entry) {
                  final i = entry.key;
                  final h = entry.value;
                  final bg = i.isOdd ? PdfColors.grey50 : PdfColors.white;
                  return pw.TableRow(children: [
                    _tableCell(h.person, bg: bg),
                    _tableCell(h.conduct, bg: bg),
                    _tableCell(h.myPart, bg: bg),
                    _tableCell(h.isAmendsDone ? '✓' : '',
                        bg: bg, align: pw.Alignment.topCenter),
                  ]);
                }),
              ],
            ),
        ],
      ),
    );

    return pdf;
  }

  /// Step 4 worksheet PDF bytes (no system print dialog). Use for tests and tooling.
  static Future<List<int>> buildBigBookWorksheetPdfBytes({
    required List<Resentment> resentments,
    required List<Fear> fears,
    required List<Harm> harms,
    String title = 'Step Four — Personal Inventory',
  }) {
    final doc = _bigBookWorksheetDocument(
      resentments: resentments,
      fears: fears,
      harms: harms,
      title: title,
    );
    return doc.save();
  }

  static Future<void> generateBigBookWorksheetPdf({
    required List<Resentment> resentments,
    required List<Fear> fears,
    required List<Harm> harms,
    String title = 'Step Four — Personal Inventory',
  }) async {
    final pdf = _bigBookWorksheetDocument(
      resentments: resentments,
      fears: fears,
      harms: harms,
      title: title,
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. Sponsor Review PDF — flagged entries only
  // ─────────────────────────────────────────────────────────────────────────

  /// Exports only entries where flagForReview is true across all three
  /// Step 4 tables.  Includes a blank "Sponsor notes" column so the sponsor
  /// can print and write directly on the sheet during the Step 5 conversation.
  static Future<void> generateSponsorReviewPdf({
    required List<Resentment> resentments,
    required List<Fear> fears,
    required List<Harm> harms,
  }) async {
    final flaggedResentments =
        resentments.where((r) => r.flagForReview).toList();
    final flaggedFears = fears.where((f) => f.flagForReview).toList();
    final flaggedHarms = harms.where((h) => h.flagForReview).toList();

    final total =
        flaggedResentments.length + flaggedFears.length + flaggedHarms.length;

    if (total == 0) {
      // Return early — the settings screen should guard against this,
      // but a silent no-op is safer than a crash.
      return;
    }

    final pdf = pw.Document();
    final dateStr = DateTime.now().toIso8601String().split('T').first;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(_pdfSafe('Step Five Preparation — Flagged for Sponsor Review'),
                style: _header0()),
            pw.SizedBox(height: 2),
            pw.Text(_pdfSafe('Date: $dateStr   |   $total item(s) flagged'),
                style: _bodySm()),
            pw.SizedBox(height: 6),
            _disclaimer(),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (context) => [
          // ── Flagged Resentments ──────────────────────────────────────────
          if (flaggedResentments.isNotEmpty) ...[
            pw.Text(_pdfSafe('RESENTMENTS'), style: _header1()),
            pw.SizedBox(height: 6),
            pw.Table(
              border:
                  pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.8),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(1.8),
                3: const pw.FlexColumnWidth(2.2),
                4: const pw.FlexColumnWidth(2.7), // sponsor notes column
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.blueGrey100),
                  children: [
                    _tableCell("I'M RESENTFUL AT", isHeader: true),
                    _tableCell('THE CAUSE', isHeader: true),
                    _tableCell('AFFECTS MY…', isHeader: true),
                    _tableCell('MY PART', isHeader: true),
                    _tableCell('SPONSOR NOTES', isHeader: true),
                  ],
                ),
                ...flaggedResentments.asMap().entries.map((entry) {
                  final i = entry.key;
                  final r = entry.value;
                  final bg =
                      i.isOdd ? PdfColors.grey50 : PdfColors.white;
                  return pw.TableRow(children: [
                    _tableCell(r.person, bg: bg),
                    _tableCell(r.cause, bg: bg),
                    _tableCell(_formatAffects(r.affects), bg: bg),
                    _tableCell(r.myPart, bg: bg),
                    // Show any recorded sponsor note; otherwise leave blank
                    // for in-session annotation
                    _tableCell(r.sponsorNote ?? '', bg: bg),
                  ]);
                }),
              ],
            ),
            pw.SizedBox(height: 24),
          ],

          // ── Flagged Fears ────────────────────────────────────────────────
          if (flaggedFears.isNotEmpty) ...[
            pw.Text(_pdfSafe('FEARS'), style: _header1()),
            pw.SizedBox(height: 6),
            pw.Table(
              border:
                  pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.0),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FlexColumnWidth(3.0),
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.blueGrey100),
                  children: [
                    _tableCell('WHAT AM I AFRAID OF?', isHeader: true),
                    _tableCell('WHY?', isHeader: true),
                    _tableCell('MY PART', isHeader: true),
                    _tableCell('SPONSOR NOTES', isHeader: true),
                  ],
                ),
                ...flaggedFears.asMap().entries.map((entry) {
                  final i = entry.key;
                  final f = entry.value;
                  final bg =
                      i.isOdd ? PdfColors.grey50 : PdfColors.white;
                  return pw.TableRow(children: [
                    _tableCell(f.subject, bg: bg),
                    _tableCell(f.why, bg: bg),
                    _tableCell(f.myPart, bg: bg),
                    _tableCell(f.sponsorNote ?? '', bg: bg),
                  ]);
                }),
              ],
            ),
            pw.SizedBox(height: 24),
          ],

          // ── Flagged Harms ────────────────────────────────────────────────
          if (flaggedHarms.isNotEmpty) ...[
            pw.Text(_pdfSafe('HARMS TO OTHERS'), style: _header1()),
            pw.SizedBox(height: 6),
            pw.Table(
              border:
                  pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.8),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FlexColumnWidth(3.2),
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.blueGrey100),
                  children: [
                    _tableCell('WHO DID I HARM?', isHeader: true),
                    _tableCell('WHAT WAS THE CONDUCT?', isHeader: true),
                    _tableCell('MY PART', isHeader: true),
                    _tableCell('SPONSOR NOTES', isHeader: true),
                  ],
                ),
                ...flaggedHarms.asMap().entries.map((entry) {
                  final i = entry.key;
                  final h = entry.value;
                  final bg =
                      i.isOdd ? PdfColors.grey50 : PdfColors.white;
                  return pw.TableRow(children: [
                    _tableCell(h.person, bg: bg),
                    _tableCell(h.conduct, bg: bg),
                    _tableCell(h.myPart, bg: bg),
                    _tableCell(h.sponsorNote ?? '', bg: bg),
                  ]);
                }),
              ],
            ),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. Step 5 Completion Certificate PDF
  // ─────────────────────────────────────────────────────────────────────────

  /// A dated record of the Step 5 ceremony: inventory counts, the three
  /// admissions confirmed, and any personal reflection.  Print and keep
  /// with your sponsor or store with your Step 4 papers.
  static Future<void> generateStep5CompletionPdf({
    required List<Resentment> resentments,
    required List<Fear> fears,
    required List<Harm> harms,
    required DateTime completedAt,
    String? reflection,
  }) async {
    final pdf = pw.Document();
    final dateStr = completedAt.toIso8601String().split('T').first;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(56),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(children: [
                pw.Text(_pdfSafe('Step Five'), style: pw.TextStyle(
                    fontSize: 28, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text(_pdfSafe(
                  'Admitted to God, to ourselves, and to another human being\n'
                  'the exact nature of our wrongs.'),
                  style: pw.TextStyle(
                      fontSize: 12, fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ]),
            ),
            pw.SizedBox(height: 36),
            pw.Divider(),
            pw.SizedBox(height: 24),

            // Inventory summary
            pw.Text(_pdfSafe('Inventory Reviewed'), style: _header1()),
            pw.SizedBox(height: 10),
            pw.Row(children: [
              pw.Expanded(child: _summaryBox(
                  '${resentments.length}', 'Resentments')),
              pw.SizedBox(width: 12),
              pw.Expanded(child: _summaryBox('${fears.length}', 'Fears')),
              pw.SizedBox(width: 12),
              pw.Expanded(child: _summaryBox('${harms.length}', 'Harms')),
            ]),
            pw.SizedBox(height: 28),

            // Three admissions
            pw.Text(_pdfSafe('Three Admissions Confirmed'), style: _header1()),
            pw.SizedBox(height: 12),
            _admissionRow('1', 'Admitted to myself'),
            pw.SizedBox(height: 8),
            _admissionRow('2', 'Admitted to my Higher Power'),
            pw.SizedBox(height: 8),
            _admissionRow('3', 'Admitted to another person'),
            pw.SizedBox(height: 28),

            if (reflection != null && reflection.isNotEmpty) ...[
              pw.Text(_pdfSafe('Personal Reflection'), style: _header1()),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(4)),
                child: pw.Text(_pdfSafe(reflection), style: _body()),
              ),
              pw.SizedBox(height: 28),
            ],

            pw.Spacer(),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(_pdfSafe('Completed: $dateStr'),
                    style: _bodySm()
                        .copyWith(color: PdfColors.grey600)),
                _disclaimer(),
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  static pw.Widget _summaryBox(String value, String label) =>
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(6)),
        child: pw.Column(
          children: [
            pw.Text(_pdfSafe(value),
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(_pdfSafe(label), style: _bodySm()),
          ],
        ),
      );

  static pw.Widget _admissionRow(String num, String text) => pw.Row(
        children: [
          pw.Container(
            width: 24,
            height: 24,
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              shape: pw.BoxShape.circle,
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(_pdfSafe(num),
                style: pw.TextStyle(
                    fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(width: 10),
          pw.Text(_pdfSafe('✓  $text'), style: _body()),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────
  // 4. Original inventory summary PDF (preserved)
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> generateInventoryPdf({
    required List<Resentment> resentments,
    required List<Fear> fears,
    required List<Harm> harms,
    required List<DailyReview> reviews,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, text: 'Personal Inventory Report'),
          pw.Text(_pdfSafe(
              'Generated on ${DateTime.now().toString().split(' ')[0]}')),
          pw.Divider(),
          pw.Header(level: 1, text: 'Resentments'),
          ...resentments.map((r) => pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text(_pdfSafe(
                    '• ${r.person}: ${r.cause} (Affects: ${_formatAffects(r.affects)})')),
              )),
          pw.Header(level: 1, text: 'Fears'),
          ...fears.map((f) => pw.Bullet(text: '${f.subject}: ${f.why}')),
          pw.Header(level: 1, text: 'Daily Review Patterns (Last 10 Days)'),
          ...reviews.take(10).map((rev) => pw.Text(_pdfSafe(
                '${rev.date.toString().split(' ')[0]}: '
                '${rev.wasResentful ? '[Resentment] ' : ''}'
                '${rev.wasAfraid ? '[Fear] ' : ''}'),
              )),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. Excel / CSV Amends Tracker
  // ─────────────────────────────────────────────────────────────────────────

  static const _xlsxMime =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  /// Writes the amends workbook under Documents/exports and returns an [XFile]
  /// with a MIME type suitable for Numbers / Sheets / Mail.
  static Future<XFile> buildAmendsExcelXFile(List<Amend> amends) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Amends Planner'];

    sheet.appendRow([
      TextCellValue('Person'),
      TextCellValue('Type'),
      TextCellValue('Plan'),
      TextCellValue('Status'),
      TextCellValue('Priority'),
      TextCellValue('Date Planned'),
      TextCellValue('Date Completed'),
    ]);

    for (var a in amends) {
      sheet.appendRow([
        TextCellValue(a.person),
        TextCellValue(a.amendsType?.name ?? 'unspecified'),
        TextCellValue(a.plan ?? ''),
        TextCellValue(a.status),
        IntCellValue(a.priority),
        TextCellValue(
            a.datePlanned?.toIso8601String().split('T').first ?? ''),
        TextCellValue(
            a.dateCompleted?.toIso8601String().split('T').first ?? ''),
      ]);
    }

    final directory = await ensureExportsDirectory();
    final path = p.join(
      directory.path,
      'amends_export_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);

    return XFile(path, mimeType: _xlsxMime);
  }

  static Future<void> exportToExcel(List<Amend> amends) async {
    final xFile = await buildAmendsExcelXFile(amends);
    await Share.shareXFiles([xFile], text: 'My Amends Plan Export');
  }

  /// UTF-8 CSV with BOM (helps Excel detect encoding); same columns as Excel.
  static Future<XFile> buildAmendsCsvXFile(List<Amend> amends) async {
    const converter = ListToCsvConverter(eol: '\r\n');
    final rows = <List<dynamic>>[
      [
        'Person',
        'Type',
        'Plan',
        'Status',
        'Priority',
        'Date Planned',
        'Date Completed',
      ],
    ];
    for (final a in amends) {
      rows.add([
        a.person,
        a.amendsType?.name ?? 'unspecified',
        a.plan ?? '',
        a.status,
        a.priority,
        a.datePlanned?.toIso8601String().split('T').first ?? '',
        a.dateCompleted?.toIso8601String().split('T').first ?? '',
      ]);
    }
    final csvBody = converter.convert(rows);
    final directory = await ensureExportsDirectory();
    final path = p.join(
      directory.path,
      'amends_export_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    const bom = '\uFEFF';
    await File(path).writeAsString('$bom$csvBody', encoding: utf8);
    return XFile(path, mimeType: 'text/csv');
  }

  static Future<void> exportToCsv(List<Amend> amends) async {
    final xFile = await buildAmendsCsvXFile(amends);
    await Share.shareXFiles([xFile], text: 'My Amends Plan Export (CSV)');
  }

  // ── Sponsee Review JSON export ──────────────────────────────────────────

  /// Serialises the user's Step 4 inventory as a compact JSON string and
  /// shares it via the system share sheet.  Sponsors can paste this into
  /// the "Review Import" panel on the Sponsees tab to read the inventory.
  static Future<void> exportSponsorReviewJson({
    required List<Resentment> resentments,
    required List<Fear> fears,
    required List<Harm> harms,
  }) async {
    final payload = {
      'appVersion': '1.0',
      'exportedAt': DateTime.now().toIso8601String().split('T').first,
      'resentments': resentments
          .map((r) => {
                'person': r.person,
                'cause': r.cause,
                'affects': r.affects,
                'myPart': r.myPart,
                'flagForReview': r.flagForReview,
              })
          .toList(),
      'fears': fears
          .map((f) => {
                'subject': f.subject,
                'why': f.why,
                'myPart': f.myPart,
                'flagForReview': f.flagForReview,
              })
          .toList(),
      'harms': harms
          .map((h) => {
                'person': h.person,
                'conduct': h.conduct,
                'myPart': h.myPart,
                'flagForReview': h.flagForReview,
              })
          .toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(payload);

    final dir = await ensureExportsDirectory();
    final path = p.join(
      dir.path,
      'sponsor_review_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await File(path).writeAsString(jsonStr, encoding: utf8);
    await Share.shareXFiles(
      [XFile(path, mimeType: 'application/json')],
      subject: 'Fearless Inventory — Step 4 Review',
      text: 'My Step 4 inventory for sponsor review.',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5. Recovery Journal PDF
  // ─────────────────────────────────────────────────────────────────────────

  /// Generates a beautifully formatted personal journal PDF from all
  /// [JournalEntry] records, styled to read like a physical journal.
  ///
  /// Layout:
  ///   • Cover page with title, date range, and entry count
  ///   • Entries grouped and sorted by Step → Tradition → Uncategorised
  ///   • Within each group, entries appear in chronological order
  ///   • Each entry occupies its own "page section" with date, optional title,
  ///     and body text
  ///   • Footer on every page: page number + disclaimer
  static Future<void> generateJournalPdf(
    List<JournalEntry> entries, {
    String journalTitle = 'My Recovery Journal',
  }) async {
    if (entries.isEmpty) return;

    final pdf = pw.Document();
    final _dateFmtLong = DateFormat('MMMM d, yyyy');
    final _dateFmtShort = DateFormat('MMM d, yyyy');

    // Sort: Step 1..12 first, then Tradition 1..12, then uncategorised.
    final sorted = List<JournalEntry>.from(entries);
    sorted.sort((a, b) {
      int groupA = _entryGroup(a);
      int groupB = _entryGroup(b);
      if (groupA != groupB) return groupA.compareTo(groupB);
      return a.createdAt.compareTo(b.createdAt);
    });

    final dateRange = sorted.isNotEmpty
        ? '${_dateFmtShort.format(sorted.first.createdAt)} – '
          '${_dateFmtShort.format(sorted.last.createdAt)}'
        : '';

    // ── Cover page ──────────────────────────────────────────────────────────
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(72),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Spacer(),
            pw.Text(_pdfSafe(
              journalTitle),
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey800,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              width: 60,
              height: 2,
              color: PdfColors.blueGrey300,
            ),
            pw.SizedBox(height: 20),
            pw.Text(_pdfSafe(
              dateRange),
              style: pw.TextStyle(
                fontSize: 13,
                color: PdfColors.blueGrey500,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(_pdfSafe(
              '${sorted.length} ${sorted.length == 1 ? "entry" : "entries"}'),
              style: const pw.TextStyle(
                  fontSize: 12, color: PdfColors.blueGrey400),
            ),
            pw.Spacer(),
            pw.Spacer(),
            _disclaimer(),
          ],
        ),
      ),
    );

    // ── Group entries ───────────────────────────────────────────────────────
    final groups = <String, List<JournalEntry>>{};
    for (final e in sorted) {
      final key = _entryGroupKey(e);
      groups.putIfAbsent(key, () => []).add(e);
    }

    // ── Entry pages ─────────────────────────────────────────────────────────
    for (final groupEntry in groups.entries) {
      final groupLabel = groupEntry.key;
      final groupEntries = groupEntry.value;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.fromLTRB(72, 56, 72, 56),
          header: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(_pdfSafe(
                    groupLabel.toUpperCase()),
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  pw.Text(_pdfSafe(
                    journalTitle),
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.blueGrey400,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.blueGrey200, thickness: 0.5),
              pw.SizedBox(height: 12),
            ],
          ),
          footer: (ctx) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(_pdfSafe(
                'Personal use only. Not affiliated with AA World Services.'),
                style: const pw.TextStyle(
                    fontSize: 7, color: PdfColors.blueGrey300),
              ),
              pw.Text(_pdfSafe(
                'Page ${ctx.pageNumber}'),
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.blueGrey400),
              ),
            ],
          ),
          build: (ctx) {
            final widgets = <pw.Widget>[];
            for (int i = 0; i < groupEntries.length; i++) {
              final e = groupEntries[i];
              widgets.addAll(_buildEntryBlock(e, _dateFmtLong));
              if (i < groupEntries.length - 1) {
                widgets.add(pw.SizedBox(height: 32));
                widgets.add(pw.Divider(
                    color: PdfColors.blueGrey100, thickness: 0.5));
                widgets.add(pw.SizedBox(height: 32));
              }
            }
            return widgets;
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  /// Formats a single journal entry as PDF widgets.
  static List<pw.Widget> _buildEntryBlock(
      JournalEntry e, DateFormat dateFmt) {
    return [
      // Date header
      pw.Text(_pdfSafe(
        dateFmt.format(e.createdAt)),
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.blueGrey400,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
      pw.SizedBox(height: 8),
      // Optional title
      if (e.title != null && e.title!.isNotEmpty) ...[
        pw.Text(_pdfSafe(
          e.title!),
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 10),
      ],
      // Body
      pw.Text(_pdfSafe(
        e.content),
        style: const pw.TextStyle(
          fontSize: 11,
          color: PdfColors.blueGrey900,
          lineSpacing: 4,
        ),
      ),
    ];
  }

  /// Sort key: Steps 0–11, Traditions 100–111, Uncategorised 200.
  static int _entryGroup(JournalEntry e) {
    if (e.stepNumber != null) return e.stepNumber! - 1;
    if (e.traditionNumber != null) return 100 + e.traditionNumber! - 1;
    return 200;
  }

  static String _entryGroupKey(JournalEntry e) {
    if (e.stepNumber != null) {
      final content = StepTraditionContent.forStep(e.stepNumber!);
      return content != null ? 'Step ${e.stepNumber}: ${content.title}' : 'Step ${e.stepNumber}';
    }
    if (e.traditionNumber != null) {
      final content = StepTraditionContent.forTradition(e.traditionNumber!);
      return content != null
          ? 'Tradition ${e.traditionNumber}: ${content.title}'
          : 'Tradition ${e.traditionNumber}';
    }
    return 'General Reflections';
  }

  /// Parses a JSON string previously created by [exportSponsorReviewJson].
  /// Returns null and a human-readable [error] string on failure.
  static ({
    String? error,
    List<Map<String, dynamic>>? resentments,
    List<Map<String, dynamic>>? fears,
    List<Map<String, dynamic>>? harms,
    String? exportedAt,
  }) parseSponsorReviewJson(String raw) {
    try {
      final Map<String, dynamic> data = json.decode(raw) as Map<String, dynamic>;
      List<Map<String, dynamic>> castList(String key) =>
          (data[key] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .toList();
      return (
        error: null,
        resentments: castList('resentments'),
        fears: castList('fears'),
        harms: castList('harms'),
        exportedAt: data['exportedAt'] as String?,
      );
    } catch (e) {
      return (
        error: 'Could not parse the import data. Make sure you pasted the '
            'complete JSON text from your sponsee\'s export. ($e)',
        resentments: null,
        fears: null,
        harms: null,
        exportedAt: null,
      );
    }
  }
}
