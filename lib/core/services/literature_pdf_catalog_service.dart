import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

import '../literature/literature_book_catalog.dart';
import '../literature/literature_nav_models.dart';
import '../literature/preprocessed_literature_store.dart';

export '../literature/literature_nav_models.dart';

/// Loads PDF outline, extracts plain text by page range, and supports search.
class LiteraturePdfCatalogService {
  LiteraturePdfCatalogService();

  final Map<String, List<String>> _pageTextsMem = {};
  final Map<String, Future<List<String>>> _pageTextsInflight = {};

  Future<Directory> _cacheDir() async {
    final root = await getApplicationSupportDirectory();
    final dir = Directory(p.join(root.path, 'literature_cache', 'v1'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _sectionsFile(String bookKey) async {
    final dir = await _cacheDir();
    return File(p.join(dir.path, '${bookKey}_sections.json'));
  }

  /// Outline-based table of contents, cached on disk after first successful parse.
  Future<List<LiteratureNavSection>> loadSections(String bookKey) async {
    try {
      final pb = await PreprocessedLiteratureStore.instance.getBookPrebuild(
        bookKey,
      );
      if (pb != null && pb.pages.isNotEmpty) {
        _pageTextsMem[bookKey] = pb.pages;
        return pb.sections;
      }
    } catch (_) {}

    final file = await _sectionsFile(bookKey);
    if (await file.exists()) {
      try {
        final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
        return raw
            .map(
              (e) => LiteratureNavSection.fromJson(
                bookKey,
                e as Map<String, dynamic>,
              ),
            )
            .toList();
      } catch (_) {
        await file.delete();
      }
    }

    final asset = LiteratureBookCatalog.assetForBookKey(bookKey);
    final doc = await PdfDocument.openAsset(asset);
    try {
      final pageCount = doc.pages.length;
      final outline = await doc.loadOutline();
      var sections = _flattenOutline(bookKey, outline, pageCount);
      if (sections.isEmpty) {
        sections = _syntheticSections(bookKey, pageCount);
      }
      await file.writeAsString(
        jsonEncode(sections.map((s) => s.toJson()).toList()),
      );
      return sections;
    } finally {
      await doc.dispose();
    }
  }

  List<LiteratureNavSection> _flattenOutline(
    String bookKey,
    List<PdfOutlineNode> nodes,
    int pageCount,
  ) {
    final raw = <({String title, int page})>[];

    void walk(List<PdfOutlineNode> list) {
      for (final n in list) {
        final page = n.dest?.pageNumber;
        final title = n.title.trim();
        if (page != null &&
            page >= 1 &&
            page <= pageCount &&
            title.isNotEmpty) {
          raw.add((title: title, page: page));
        }
        if (n.children.isNotEmpty) {
          walk(n.children);
        }
      }
    }

    walk(nodes);
    if (raw.isEmpty) return [];

    raw.sort((a, b) => a.page.compareTo(b.page));
    // Drop consecutive duplicates at same page (keep first title).
    final deduped = <({String title, int page})>[];
    for (final r in raw) {
      if (deduped.isEmpty || deduped.last.page != r.page) {
        deduped.add(r);
      }
    }

    final sections = <LiteratureNavSection>[];
    for (var i = 0; i < deduped.length; i++) {
      final start = deduped[i].page;
      final end = i + 1 < deduped.length ? deduped[i + 1].page - 1 : pageCount;
      if (end < start) continue;
      sections.add(
        LiteratureNavSection(
          key: '${bookKey}_p${start}_i$i',
          title: deduped[i].title,
          startPage: start,
          endPage: end.clamp(1, pageCount),
        ),
      );
    }
    return sections;
  }

  List<LiteratureNavSection> _syntheticSections(String bookKey, int pageCount) {
    const chunk = 32;
    final out = <LiteratureNavSection>[];
    for (var start = 1; start <= pageCount; start += chunk) {
      final i = out.length;
      final end = (start + chunk - 1).clamp(1, pageCount);
      out.add(
        LiteratureNavSection(
          key: '${bookKey}_p${start}_i$i',
          title: 'Pages $start–$end',
          startPage: start,
          endPage: end,
        ),
      );
    }
    return out;
  }

  /// Plain text for a page range (inclusive), joined with blank lines between pages.
  Future<String> loadSectionPlainText({
    required String bookKey,
    required int startPage,
    required int endPage,
  }) async {
    try {
      final pb = await PreprocessedLiteratureStore.instance.getBookPrebuild(
        bookKey,
      );
      if (pb != null && pb.pages.isNotEmpty) {
        for (final s in pb.sections) {
          if (s.startPage == startPage &&
              s.endPage == endPage &&
              (s.text != null && s.text!.trim().isNotEmpty)) {
            return s.text!.trim();
          }
        }
        if (startPage == endPage &&
            startPage >= 1 &&
            startPage <= pb.pages.length) {
          return pb.pages[startPage - 1].trim();
        }
        final buf = StringBuffer();
        for (var p = startPage; p <= endPage; p++) {
          if (p >= 1 && p <= pb.pages.length) {
            if (buf.isNotEmpty) buf.writeln();
            buf.write(pb.pages[p - 1]);
          }
        }
        final joined = buf.toString().trim();
        if (joined.isNotEmpty) return joined;
      }
    } catch (_) {}

    final asset = LiteratureBookCatalog.assetForBookKey(bookKey);
    final doc = await PdfDocument.openAsset(asset);
    try {
      final buf = StringBuffer();
      for (var p = startPage; p <= endPage; p++) {
        final page = doc.pages[p - 1];
        final text = await page.loadText();
        final t = text.fullText.trim();
        if (t.isEmpty) continue;
        if (buf.isNotEmpty) buf.writeln();
        buf.writeln(t);
      }
      return buf.toString().trim();
    } finally {
      await doc.dispose();
    }
  }

  /// All page texts (0-based index → page 1). Cached in memory for the session.
  Future<List<String>> loadAllPageTexts(String bookKey) async {
    if (_pageTextsMem.containsKey(bookKey)) {
      return _pageTextsMem[bookKey]!;
    }
    return _pageTextsInflight.putIfAbsent(
      bookKey,
      () => _loadAllPageTextsImpl(bookKey),
    );
  }

  Future<List<String>> _loadAllPageTextsImpl(String bookKey) async {
    try {
      try {
        final pb = await PreprocessedLiteratureStore.instance.getBookPrebuild(
          bookKey,
        );
        if (pb != null && pb.pages.isNotEmpty) {
          _pageTextsMem[bookKey] = pb.pages;
          return pb.pages;
        }
      } catch (_) {}

      final asset = LiteratureBookCatalog.assetForBookKey(bookKey);
      final doc = await PdfDocument.openAsset(asset);
      try {
        final out = <String>[];
        for (final page in doc.pages) {
          final text = await page.loadText();
          out.add(text.fullText);
        }
        _pageTextsMem[bookKey] = out;
        return out;
      } finally {
        await doc.dispose();
      }
    } finally {
      _pageTextsInflight.remove(bookKey);
    }
  }

  Future<List<LiteratureSearchHit>> search({
    required String bookKey,
    required String query,
    required List<LiteratureNavSection> sections,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final pages = await loadAllPageTexts(bookKey);
    final hits = <LiteratureSearchHit>[];

    String sectionTitleForPage(int page1) {
      LiteratureNavSection? best;
      for (final s in sections) {
        if (page1 >= s.startPage && page1 <= s.endPage) {
          best = s;
          break;
        }
      }
      return best?.title ?? 'Page $page1';
    }

    String sectionKeyForPage(int page1) {
      for (final s in sections) {
        if (page1 >= s.startPage && page1 <= s.endPage) {
          return s.key;
        }
      }
      return '${bookKey}_p$page1';
    }

    for (var i = 0; i < pages.length; i++) {
      final pageNum = i + 1;
      final text = pages[i];
      final lower = text.toLowerCase();
      var from = 0;
      while (true) {
        final idx = lower.indexOf(q, from);
        if (idx < 0) break;
        const radius = 72;
        final start = (idx - radius).clamp(0, text.length);
        final end = (idx + q.length + radius).clamp(0, text.length);
        var snippet = text
            .substring(start, end)
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        if (start > 0) snippet = '… $snippet';
        if (end < text.length) snippet = '$snippet …';
        hits.add(
          LiteratureSearchHit(
            page: pageNum,
            sectionTitle: sectionTitleForPage(pageNum),
            snippet: snippet,
            sectionKey: sectionKeyForPage(pageNum),
          ),
        );
        from = idx + 1;
        if (hits.length >= 200) return hits;
      }
    }
    return hits;
  }

  /// Match seed / legacy bookmark rows to a section when keys differ.
  LiteratureNavSection? matchBookmarkToSection({
    required List<LiteratureNavSection> sections,
    required String chapterKey,
    required String chapterTitle,
  }) {
    for (final s in sections) {
      if (s.key == chapterKey) return s;
    }
    final t = chapterTitle.toLowerCase().trim();
    if (t.isEmpty) return null;

    LiteratureNavSection? best;
    var bestScore = 0;
    for (final s in sections) {
      final st = s.title.toLowerCase();
      var score = 0;
      if (st == t) {
        score = 100;
      } else if (st.contains(t)) {
        score = 80;
      } else if (t.contains(st) && st.length >= 5) {
        score = 50;
      }
      if (score > bestScore) {
        bestScore = score;
        best = s;
      }
    }
    return bestScore >= 50 ? best : null;
  }
}
