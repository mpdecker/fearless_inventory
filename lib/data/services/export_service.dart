import 'dart:convert';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/database.dart';

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
    child: pw.Text(
      text,
      style: isHeader ? _label() : _body(),
    ),
  );
}

pw.Widget _disclaimer() => pw.Text(
      'This document is for personal use with your sponsor. '
      'Not affiliated with AA World Services, Inc.',
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
  static Future<void> generateBigBookWorksheetPdf({
    required List<Resentment> resentments,
    required List<Fear> fears,
    required List<Harm> harms,
    String title = 'Step Four — Personal Inventory',
  }) async {
    final pdf = pw.Document();
    final dateStr = DateTime.now().toIso8601String().split('T').first;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: _header0()),
            pw.SizedBox(height: 2),
            pw.Text('Date: $dateStr   |   '
                '${resentments.length} resentments · '
                '${fears.length} fears · '
                '${harms.length} harms',
                style: _bodySm()),
            pw.SizedBox(height: 6),
            _disclaimer(),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (context) => [
          // ── Resentments ──────────────────────────────────────────────────
          pw.Text('RESENTMENTS', style: _header1()),
          pw.SizedBox(height: 6),
          if (resentments.isEmpty)
            pw.Text('No resentments recorded.', style: _body())
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
          pw.Text('FEARS', style: _header1()),
          pw.SizedBox(height: 6),
          if (fears.isEmpty)
            pw.Text('No fears recorded.', style: _body())
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
          pw.Text('HARMS TO OTHERS', style: _header1()),
          pw.SizedBox(height: 6),
          if (harms.isEmpty)
            pw.Text('No harms recorded.', style: _body())
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
            pw.Text('Step Five Preparation — Flagged for Sponsor Review',
                style: _header0()),
            pw.SizedBox(height: 2),
            pw.Text('Date: $dateStr   |   $total item(s) flagged',
                style: _bodySm()),
            pw.SizedBox(height: 6),
            _disclaimer(),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (context) => [
          // ── Flagged Resentments ──────────────────────────────────────────
          if (flaggedResentments.isNotEmpty) ...[
            pw.Text('RESENTMENTS', style: _header1()),
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
            pw.Text('FEARS', style: _header1()),
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
            pw.Text('HARMS TO OTHERS', style: _header1()),
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
                pw.Text('Step Five', style: pw.TextStyle(
                    fontSize: 28, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Admitted to God, to ourselves, and to another human being\n'
                  'the exact nature of our wrongs.',
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
            pw.Text('Inventory Reviewed', style: _header1()),
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
            pw.Text('Three Admissions Confirmed', style: _header1()),
            pw.SizedBox(height: 12),
            _admissionRow('1', 'Admitted to myself'),
            pw.SizedBox(height: 8),
            _admissionRow('2', 'Admitted to my Higher Power'),
            pw.SizedBox(height: 8),
            _admissionRow('3', 'Admitted to another person'),
            pw.SizedBox(height: 28),

            if (reflection != null && reflection.isNotEmpty) ...[
              pw.Text('Personal Reflection', style: _header1()),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(4)),
                child: pw.Text(reflection, style: _body()),
              ),
              pw.SizedBox(height: 28),
            ],

            pw.Spacer(),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Completed: $dateStr',
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
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(label, style: _bodySm()),
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
            child: pw.Text(num,
                style: pw.TextStyle(
                    fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(width: 10),
          pw.Text('✓  $text', style: _body()),
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
          pw.Text(
              'Generated on ${DateTime.now().toString().split(' ')[0]}'),
          pw.Divider(),
          pw.Header(level: 1, text: 'Resentments'),
          ...resentments.map((r) => pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text(
                    '• ${r.person}: ${r.cause} (Affects: ${_formatAffects(r.affects)})'),
              )),
          pw.Header(level: 1, text: 'Fears'),
          ...fears.map((f) => pw.Bullet(text: '${f.subject}: ${f.why}')),
          pw.Header(level: 1, text: 'Daily Review Patterns (Last 10 Days)'),
          ...reviews.take(10).map((rev) => pw.Text(
                '${rev.date.toString().split(' ')[0]}: '
                '${rev.wasResentful ? '[Resentment] ' : ''}'
                '${rev.wasAfraid ? '[Fear] ' : ''}',
              )),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. Excel Amends Tracker (preserved)
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> exportToExcel(List<Amend> amends) async {
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

    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/amends_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);

    await Share.shareXFiles([XFile(path)], text: 'My Amends Plan Export');
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

    // Share as a text file so the sponsor can save it and paste it.
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/sponsor_review_${DateTime.now().millisecondsSinceEpoch}.json';
    await File(path).writeAsString(jsonStr);
    await Share.shareXFiles(
      [XFile(path, mimeType: 'application/json')],
      subject: 'Fearless Inventory — Step 4 Review',
      text: 'My Step 4 inventory for sponsor review.',
    );
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
