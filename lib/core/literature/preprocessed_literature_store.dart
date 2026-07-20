import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

import 'literature_book_catalog.dart';
import 'literature_nav_models.dart';
import 'literature_pdf_extraction.dart';

const _engine = 2;

/// Full text + TOC extracted once, then read from disk or bundled JSON.
class BookPrebuildData {
  BookPrebuildData({required this.sections, required this.pages});

  final List<LiteratureNavSection> sections;
  final List<String> pages;
}

/// One-time (per engine version) extraction from bundled PDFs → app support
/// cache, with optional hot assets under `assets/data/` for instant load.
class PreprocessedLiteratureStore {
  PreprocessedLiteratureStore._();
  static final instance = PreprocessedLiteratureStore._();

  final Map<String, BookPrebuildData?> _bookMem = {};
  final Map<String, Future<BookPrebuildData?>> _bookInflight = {};
  List<Map<String, dynamic>>? _reflectionRowsMem;
  final Map<String, Future<List<Map<String, dynamic>>>> _reflectInflight = {};
  Map<String, String>? _dailyMem;
  final Map<String, Future<Map<String, String>>> _dailyInflight = {};

  Future<Directory> _root() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'literature_preprocessed', 'e$_engine'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _file(String name) async {
    final dir = await _root();
    return File(p.join(dir.path, name));
  }

  /// Big Book / 12&12: bundled JSON → disk cache → PDF extract once.
  Future<BookPrebuildData?> getBookPrebuild(String bookKey) async {
    if (_bookMem.containsKey(bookKey)) return _bookMem[bookKey];
    return _bookInflight.putIfAbsent(
      bookKey,
      () => _loadBookPrebuildImpl(bookKey),
    );
  }

  Future<BookPrebuildData?> _loadBookPrebuildImpl(String bookKey) async {
    try {
      final bundledPath = 'assets/data/literature_${bookKey}_prebuilt.json';
      try {
        final s = await rootBundle.loadString(bundledPath);
        final data = jsonDecode(s) as Map<String, dynamic>;
        final parsed = _parsePrebuilt(bookKey, data);
        if (parsed != null) {
          _bookMem[bookKey] = parsed;
          return parsed;
        }
      } catch (_) {}

      final cache = await _file('${bookKey}_prebuilt.json');
      if (await cache.exists()) {
        try {
          final data = jsonDecode(await cache.readAsString()) as Map<String, dynamic>;
          final parsed = _parsePrebuilt(bookKey, data);
          if (parsed != null) {
            _bookMem[bookKey] = parsed;
            return parsed;
          }
        } catch (_) {
          await cache.delete();
        }
      }

      final built = await buildBookPrebuiltJson(bookKey);
      await cache.writeAsString(jsonEncode(built));
      final parsed = _parsePrebuilt(bookKey, built)!;
      _bookMem[bookKey] = parsed;
      return parsed;
    } finally {
      _bookInflight.remove(bookKey);
    }
  }

  BookPrebuildData? _parsePrebuilt(String bookKey, Map<String, dynamic> data) {
    final secRaw = data['sections'];
    final pageRaw = data['pages'];
    if (secRaw is! List || pageRaw is! List) return null;
    if (pageRaw.isEmpty) return null;
    var sections = secRaw
        .map((e) => LiteratureNavSection.fromJson(bookKey, e as Map<String, dynamic>))
        .toList();
    final pages = pageRaw.map((e) => e as String).toList();
    if (sections.isEmpty) {
      sections = [
        LiteratureNavSection(
          key: '${bookKey}_all',
          title: LiteratureBookCatalog.titleForBookKey(bookKey),
          startPage: 1,
          endPage: pages.length,
          text: pages.join('\n\n'),
        ),
      ];
    }
    return BookPrebuildData(sections: sections, pages: pages);
  }

  /// As Bill Sees It → rows for [ReflectionService].
  Future<List<Map<String, dynamic>>> loadReflectionRows() async {
    if (_reflectionRowsMem != null) return _reflectionRowsMem!;
    return _reflectInflight.putIfAbsent(
      '_',
      () => _loadReflectionRowsImpl(),
    );
  }

  Future<List<Map<String, dynamic>>> _loadReflectionRowsImpl() async {
    try {
      try {
        final s = await rootBundle.loadString('assets/data/as_bill_sees_it_reflections.json');
        final list = jsonDecode(s) as List<dynamic>;
        final rows = list
            .whereType<Map<String, dynamic>>()
            .where(
              (r) =>
                  r['theme'] is String &&
                  r['quote'] is String &&
                  r['reflection'] is String,
            )
            .toList();
        if (rows.isNotEmpty) {
          _reflectionRowsMem = rows;
          return rows;
        }
      } catch (_) {}

      final cache = await _file('as_bill_reflections.json');
      if (await cache.exists()) {
        final list = jsonDecode(await cache.readAsString()) as List<dynamic>;
        final rows = list
            .whereType<Map<String, dynamic>>()
            .where(
              (r) =>
                  r['theme'] is String &&
                  r['quote'] is String &&
                  r['reflection'] is String,
            )
            .toList();
        if (rows.isNotEmpty) {
          _reflectionRowsMem = rows;
          return rows;
        }
      }

      final raw = await rootBundle.load(LiteratureBookCatalog.asBillSeesItAsset);
      final doc = await PdfDocument.openData(
        raw.buffer.asUint8List(),
        sourceName: LiteratureBookCatalog.asBillSeesItAsset,
      );
      List<Map<String, dynamic>> rows;
      try {
        rows = await extractAsBillReflectionRows(doc);
      } finally {
        await doc.dispose();
      }
      await cache.writeAsString(jsonEncode(rows));
      _reflectionRowsMem = rows;
      return rows;
    } finally {
      _reflectInflight.remove('_');
    }
  }

  /// Keys `MM-DD` → body text.
  Future<Map<String, String>> loadDailyReflectionBodies() async {
    if (_dailyMem != null) return _dailyMem!;
    return _dailyInflight.putIfAbsent(
      '_',
      () => _loadDailyImpl(),
    );
  }

  Future<Map<String, String>> _loadDailyImpl() async {
    try {
      try {
        final s = await rootBundle.loadString('assets/data/daily_reflections_calendar.json');
        final map = jsonDecode(s) as Map<String, dynamic>;
        final out = <String, String>{};
        for (final e in map.entries) {
          if (e.value is String && RegExp(r'^\d{2}-\d{2}$').hasMatch(e.key)) {
            out[e.key] = e.value as String;
          }
        }
        if (out.isNotEmpty) {
          _dailyMem = out;
          return out;
        }
      } catch (_) {}

      final cache = await _file('daily_reflections.json');
      if (await cache.exists()) {
        final map = jsonDecode(await cache.readAsString()) as Map<String, dynamic>;
        final out = <String, String>{};
        for (final e in map.entries) {
          if (e.value is String && RegExp(r'^\d{2}-\d{2}$').hasMatch(e.key)) {
            out[e.key] = e.value as String;
          }
        }
        if (out.isNotEmpty) {
          _dailyMem = out;
          return out;
        }
      }

      final wf = await _file('daily_reflections.json');
      final raw = await rootBundle.load(LiteratureBookCatalog.dailyReflectionsAsset);
      final doc = await PdfDocument.openData(
        raw.buffer.asUint8List(),
        sourceName: LiteratureBookCatalog.dailyReflectionsAsset,
      );
      Map<String, String> bodies;
      try {
        bodies = await extractDailyReflectionCalendar(doc);
      } finally {
        await doc.dispose();
      }
      await wf.writeAsString(jsonEncode(bodies));
      _dailyMem = bodies;
      return bodies;
    } finally {
      _dailyInflight.remove('_');
    }
  }
}
