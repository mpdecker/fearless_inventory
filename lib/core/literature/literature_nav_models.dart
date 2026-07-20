/// One navigable block (usually from PDF outline / bookmarks).
class LiteratureNavSection {
  const LiteratureNavSection({
    required this.key,
    required this.title,
    required this.startPage,
    required this.endPage,
    this.text,
  });

  /// Stable within this build; includes book + start page + ordinal.
  final String key;
  final String title;

  /// 1-based inclusive (PDF convention).
  final int startPage;

  /// 1-based inclusive end page for this section.
  final int endPage;

  /// When set (prebuilt JSON), skip PDF text extraction for this section.
  final String? text;

  Map<String, dynamic> toJson() => {
    'key': key,
    'title': title,
    'startPage': startPage,
    'endPage': endPage,
    if (text != null) 'text': text,
  };

  static LiteratureNavSection fromJson(
    String bookKey,
    Map<String, dynamic> j,
  ) => LiteratureNavSection(
    key: j['key'] as String,
    title: j['title'] as String,
    startPage: j['startPage'] as int,
    endPage: j['endPage'] as int,
    text: j['text'] as String?,
  );
}

class LiteratureSearchHit {
  const LiteratureSearchHit({
    required this.page,
    required this.sectionTitle,
    required this.snippet,
    required this.sectionKey,
  });

  final int page;
  final String sectionTitle;
  final String snippet;
  final String sectionKey;
}
