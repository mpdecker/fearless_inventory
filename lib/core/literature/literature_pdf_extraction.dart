import 'package:pdfrx/pdfrx.dart';

import 'literature_book_catalog.dart';
import 'literature_nav_models.dart';

/// Map an "As Bill Sees It" topic title to a [ReflectionService] theme bucket.
String absiTitleToTheme(String title) {
  final t = title.toLowerCase();
  if (t.contains('fear') ||
      t.contains('worry') ||
      t.contains('anxiety') ||
      t.contains('panic')) {
    return 'courage';
  }
  if (t.contains('resent') || t.contains('anger') || t.contains('bitter')) {
    return 'acceptance';
  }
  if (t.contains('relationship') ||
      t.contains('marriage') ||
      t.contains('family') ||
      t.contains('friend') ||
      t.contains('people')) {
    return 'compassion';
  }
  if (t.contains('god') || t.contains('prayer') || t.contains('faith')) {
    return 'faith';
  }
  if (t.contains('service') || t.contains('help others')) {
    return 'service';
  }
  if (t.contains('honest') || t.contains('moral')) {
    return 'honesty';
  }
  if (t.contains('humil')) {
    return 'humility';
  }
  if (t.contains('ego') || t.contains('pride')) {
    return 'humility';
  }
  if (t.contains('gratitude') || t.contains('thank')) {
    return 'gratitude';
  }
  if (t.contains('surrender') || t.contains('will')) {
    return 'willingness';
  }
  if (t.contains('lonely') || t.contains('loneliness')) {
    return 'community';
  }
  if (t.contains('trust')) {
    return 'trust';
  }
  if (t.contains('patience')) {
    return 'patience';
  }
  if (t.contains('peace') || t.contains('calm')) {
    return 'balance';
  }
  if (t.contains('hope')) {
    return 'hope';
  }
  if (t.contains('inventory') || t.contains('self')) {
    return 'self-awareness';
  }
  return 'reflection';
}

String _firstSentenceOrLine(String body, {int max = 220}) {
  final trimmed = body.trim();
  if (trimmed.isEmpty) return 'As Bill Sees It';
  final dot = trimmed.indexOf('.');
  if (dot > 20 && dot < max) {
    return trimmed.substring(0, dot + 1).trim();
  }
  final nl = trimmed.indexOf('\n');
  if (nl > 10 && nl < max) {
    return trimmed.substring(0, nl).trim();
  }
  return trimmed.length <= max
      ? trimmed
      : '${trimmed.substring(0, max).trim()}…';
}

List<LiteratureNavSection> flattenOutlineToSections(
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
      if (n.children.isNotEmpty) walk(n.children);
    }
  }

  walk(nodes);
  if (raw.isEmpty) return [];

  raw.sort((a, b) => a.page.compareTo(b.page));
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

Future<String> extractPageRangeText(
  PdfDocument doc,
  int startPage,
  int endPage,
) async {
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
}

Future<List<String>> extractAllPageTexts(PdfDocument doc) async {
  final out = <String>[];
  for (final page in doc.pages) {
    final text = await page.loadText();
    out.add(text.fullText);
  }
  return out;
}

/// Topics from As Bill Sees It → reflection rows for [ReflectionService].
Future<List<Map<String, dynamic>>> extractAsBillReflectionRows(
  PdfDocument doc,
) async {
  final pageCount = doc.pages.length;
  final outline = await doc.loadOutline();
  var sections = flattenOutlineToSections('absi', outline, pageCount);
  if (sections.isEmpty) {
    const chunk = 24;
    sections = [];
    for (var start = 1; start <= pageCount; start += chunk) {
      final i = sections.length;
      final end = (start + chunk - 1).clamp(1, pageCount);
      sections.add(
        LiteratureNavSection(
          key: 'absi_p${start}_i$i',
          title: 'Pages $start–$end',
          startPage: start,
          endPage: end,
        ),
      );
    }
  }

  final rows = <Map<String, dynamic>>[];
  for (final s in sections) {
    final body = await extractPageRangeText(doc, s.startPage, s.endPage);
    if (body.isEmpty) continue;
    final theme = absiTitleToTheme(s.title);
    final quote = _firstSentenceOrLine(body);
    rows.add({
      'theme': theme,
      'quote': quote,
      'reflection': body,
      'source': 'as_bill_sees_it',
      'sectionTitle': s.title,
    });
  }
  return rows;
}

const _monthNames = [
  'january',
  'february',
  'march',
  'april',
  'may',
  'june',
  'july',
  'august',
  'september',
  'october',
  'november',
  'december',
];

int? _parseMonthDay(String monthStr, String dayStr) {
  final m = _monthNames.indexOf(monthStr.toLowerCase());
  if (m < 0) return null;
  final d = int.tryParse(dayStr);
  if (d == null || d < 1 || d > 31) return null;
  return (m + 1) * 100 + d; // MMDD temp key
}

/// Split AA Daily Reflections PDF text into calendar entries (month/day → body).
Future<Map<String, String>> extractDailyReflectionCalendar(
  PdfDocument doc,
) async {
  final pages = await extractAllPageTexts(doc);
  final full = pages.join('\n\n');
  final re = RegExp(
    r'\b(January|February|March|April|May|June|July|August|September|October|November|December|'
    r'JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)\s+(\d{1,2})\b',
    caseSensitive: false,
  );

  final matches = re.allMatches(full).toList();
  final map = <String, String>{};
  if (matches.isEmpty) return map;

  for (var i = 0; i < matches.length; i++) {
    final m = matches[i];
    final monthToken = m.group(1)!;
    final dayToken = m.group(2)!;
    final md = _parseMonthDay(monthToken, dayToken);
    if (md == null) continue;
    final month = md ~/ 100;
    final day = md % 100;
    final key =
        '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    final start = m.start;
    final end = i + 1 < matches.length ? matches[i + 1].start : full.length;
    var body = full.substring(start, end).trim();
    body = body.replaceFirst(re, '').trim();
    if (body.length < 20) continue;
    map[key] = body;
  }
  return map;
}

Future<Map<String, dynamic>> buildBookPrebuiltJson(String bookKey) async {
  final asset = LiteratureBookCatalog.assetForBookKey(bookKey);
  final doc = await PdfDocument.openAsset(asset);
  try {
    final pageCount = doc.pages.length;
    final outline = await doc.loadOutline();
    var sections = flattenOutlineToSections(bookKey, outline, pageCount);
    if (sections.isEmpty) {
      const chunk = 32;
      sections = [];
      for (var start = 1; start <= pageCount; start += chunk) {
        final i = sections.length;
        final end = (start + chunk - 1).clamp(1, pageCount);
        sections.add(
          LiteratureNavSection(
            key: '${bookKey}_p${start}_i$i',
            title: 'Pages $start–$end',
            startPage: start,
            endPage: end,
          ),
        );
      }
    }

    final sectionMaps = <Map<String, dynamic>>[];
    for (final s in sections) {
      final text = await extractPageRangeText(doc, s.startPage, s.endPage);
      sectionMaps.add({
        ...s.toJson(),
        'text': text,
      });
    }
    final pages = await extractAllPageTexts(doc);
    return {
      'version': 2,
      'bookKey': bookKey,
      'sections': sectionMaps,
      'pages': pages,
    };
  } finally {
    await doc.dispose();
  }
}
