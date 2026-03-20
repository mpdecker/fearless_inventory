import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/database.dart';

class ExportService {
  // --- PDF EXPORT: Inventory Summary ---
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
          pw.Header(level: 0, text: "Personal Inventory Report"),
          pw.Text("Generated on ${DateTime.now().toString().split(' ')[0]}"),
          pw.Divider(),
          
          pw.Header(level: 1, text: "Resentments"),
          ...resentments.map((r) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Text("• ${r.person}: ${r.cause} (Affects: ${r.affects})"),
          )),

          pw.Header(level: 1, text: "Fears"),
          ...fears.map((f) => pw.Bullet(text: "${f.subject}: ${f.why}")),

          pw.Header(level: 1, text: "Daily Review Patterns (Last 10 Days)"),
          ...reviews.take(10).map((rev) => pw.Text(
            "${rev.date.toString().split(' ')[0]}: "
            "${rev.wasResentful ? '[Resentment] ' : ''}"
            "${rev.wasAfraid ? '[Fear] ' : ''}"
          )),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // --- EXCEL EXPORT: Amends Tracker ---
  static Future<void> exportToExcel(List<Amend> amends) async {
    var excel = Excel.createExcel();
    // Rename default sheet
    Sheet sheet = excel['Amends Planner'];
    
    // Header Row using TextCellValue
    sheet.appendRow([
      TextCellValue('Person'), 
      TextCellValue('Type'), 
      TextCellValue('Plan'), 
      TextCellValue('Status'), 
      TextCellValue('Priority'),
      TextCellValue('Date Planned')
    ]);
    
    // Data Rows
    for (var a in amends) {
      sheet.appendRow([
        TextCellValue(a.person), 
        TextCellValue(a.amendsType.name), 
        TextCellValue(a.plan), 
        TextCellValue(a.status), 
        IntCellValue(a.priority), 
        DateTimeCellValue.fromDateTime(a.datePlanned),
      ]);
    }

    // Save and Share the file
    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/amends_export_${DateTime.now().millisecondsSinceEpoch}.xlsx";
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);
    
    await Share.shareXFiles([XFile(path)], text: 'My Amends Plan Export');
  }
}