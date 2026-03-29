import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/database.dart';
import '../../../data/repositories/literature_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data: book & chapter definitions
// ─────────────────────────────────────────────────────────────────────────────

class _ChapterDef {
  final String key;
  final String title;
  final String? subtitle;
  final String url;
  const _ChapterDef({
    required this.key,
    required this.title,
    this.subtitle,
    required this.url,
  });
}

class _BookDef {
  final String id; // 'bigbook' | 'twelve_twelve'
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<_ChapterDef> chapters;
  const _BookDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.chapters,
  });
}

// ── Big Book chapter URLs (official AA PDFs) ──────────────────────────────

const _kBigBook = _BookDef(
  id: 'bigbook',
  title: 'The Big Book',
  subtitle: 'Alcoholics Anonymous — Fourth Edition',
  icon: Icons.auto_stories_outlined,
  color: Color(0xFF1A56DB),
  chapters: [
    _ChapterDef(
      key: 'bb_forewords',
      title: 'Forewords',
      subtitle: 'First, Second & Third Editions',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_foreword.pdf',
    ),
    _ChapterDef(
      key: 'bb_doctors_opinion',
      title: 'The Doctor\'s Opinion',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_doctors_opinion.pdf',
    ),
    _ChapterDef(
      key: 'bb_ch1',
      title: 'Chapter 1',
      subtitle: 'Bill\'s Story',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_chapt1.pdf',
    ),
    _ChapterDef(
      key: 'bb_ch2',
      title: 'Chapter 2',
      subtitle: 'There Is a Solution',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_chapt2.pdf',
    ),
    _ChapterDef(
      key: 'bb_ch3',
      title: 'Chapter 3',
      subtitle: 'More About Alcoholism',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_chapt3.pdf',
    ),
    _ChapterDef(
      key: 'bb_ch4',
      title: 'Chapter 4',
      subtitle: 'We Agnostics',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_chapt4.pdf',
    ),
    _ChapterDef(
      key: 'bb_ch5',
      title: 'Chapter 5',
      subtitle: 'How It Works',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_chapt5.pdf',
    ),
    _ChapterDef(
      key: 'bb_ch6',
      title: 'Chapter 6',
      subtitle: 'Into Action',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_chapt6.pdf',
    ),
    _ChapterDef(
      key: 'bb_ch7',
      title: 'Chapter 7',
      subtitle: 'Working With Others',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_chapt7.pdf',
    ),
    _ChapterDef(
      key: 'bb_ch8',
      title: 'Chapter 8',
      subtitle: 'To Wives',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_chapt8.pdf',
    ),
    _ChapterDef(
      key: 'bb_ch9',
      title: 'Chapter 9',
      subtitle: 'The Family Afterward',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_chapt9.pdf',
    ),
    _ChapterDef(
      key: 'bb_ch10',
      title: 'Chapter 10',
      subtitle: 'To Employers',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_chapt10.pdf',
    ),
    _ChapterDef(
      key: 'bb_ch11',
      title: 'Chapter 11',
      subtitle: 'A Vision for You',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_chapt11.pdf',
    ),
    _ChapterDef(
      key: 'bb_appendices',
      title: 'Appendices',
      subtitle: 'I–VI',
      url: 'https://www.aa.org/assets/en_US/en_bigbook_appenduice.pdf',
    ),
  ],
);

// ── Twelve Steps & Twelve Traditions chapter URLs ─────────────────────────

const _kTwelveTwelve = _BookDef(
  id: 'twelve_twelve',
  title: 'Twelve Steps and Twelve Traditions',
  subtitle: 'The "12 & 12"',
  icon: Icons.menu_book_outlined,
  color: Color(0xFF6D28D9),
  chapters: [
    _ChapterDef(
      key: 'tt_intro',
      title: 'Foreword',
      url: 'https://www.aa.org/assets/en_US/en_step_and_tradition_foreword.pdf',
    ),
    _ChapterDef(
      key: 'tt_step1',
      title: 'Step 1',
      subtitle: 'We admitted we were powerless…',
      url: 'https://www.aa.org/assets/en_US/en_step1.pdf',
    ),
    _ChapterDef(
      key: 'tt_step2',
      title: 'Step 2',
      subtitle: 'Came to believe…',
      url: 'https://www.aa.org/assets/en_US/en_step2.pdf',
    ),
    _ChapterDef(
      key: 'tt_step3',
      title: 'Step 3',
      subtitle: 'Made a decision…',
      url: 'https://www.aa.org/assets/en_US/en_step3.pdf',
    ),
    _ChapterDef(
      key: 'tt_step4',
      title: 'Step 4',
      subtitle: 'Made a searching and fearless moral inventory…',
      url: 'https://www.aa.org/assets/en_US/en_step4.pdf',
    ),
    _ChapterDef(
      key: 'tt_step5',
      title: 'Step 5',
      subtitle: 'Admitted to God, to ourselves…',
      url: 'https://www.aa.org/assets/en_US/en_step5.pdf',
    ),
    _ChapterDef(
      key: 'tt_step6',
      title: 'Step 6',
      subtitle: 'Were entirely ready…',
      url: 'https://www.aa.org/assets/en_US/en_step6.pdf',
    ),
    _ChapterDef(
      key: 'tt_step7',
      title: 'Step 7',
      subtitle: 'Humbly asked Him…',
      url: 'https://www.aa.org/assets/en_US/en_step7.pdf',
    ),
    _ChapterDef(
      key: 'tt_step8',
      title: 'Step 8',
      subtitle: 'Made a list of all persons we had harmed…',
      url: 'https://www.aa.org/assets/en_US/en_step8.pdf',
    ),
    _ChapterDef(
      key: 'tt_step9',
      title: 'Step 9',
      subtitle: 'Made direct amends…',
      url: 'https://www.aa.org/assets/en_US/en_step9.pdf',
    ),
    _ChapterDef(
      key: 'tt_step10',
      title: 'Step 10',
      subtitle: 'Continued to take personal inventory…',
      url: 'https://www.aa.org/assets/en_US/en_step10.pdf',
    ),
    _ChapterDef(
      key: 'tt_step11',
      title: 'Step 11',
      subtitle: 'Sought through prayer and meditation…',
      url: 'https://www.aa.org/assets/en_US/en_step11.pdf',
    ),
    _ChapterDef(
      key: 'tt_step12',
      title: 'Step 12',
      subtitle: 'Having had a spiritual awakening…',
      url: 'https://www.aa.org/assets/en_US/en_step12.pdf',
    ),
    _ChapterDef(
      key: 'tt_tradition1',
      title: 'Tradition 1',
      subtitle: 'Our common welfare should come first…',
      url: 'https://www.aa.org/assets/en_US/en_tradition1.pdf',
    ),
    _ChapterDef(
      key: 'tt_tradition2',
      title: 'Tradition 2',
      subtitle: 'For our group purpose there is but one ultimate authority…',
      url: 'https://www.aa.org/assets/en_US/en_tradition2.pdf',
    ),
    _ChapterDef(
      key: 'tt_tradition3',
      title: 'Tradition 3',
      subtitle: 'The only requirement for AA membership…',
      url: 'https://www.aa.org/assets/en_US/en_tradition3.pdf',
    ),
    _ChapterDef(
      key: 'tt_tradition4',
      title: 'Tradition 4',
      subtitle: 'Each group should be autonomous…',
      url: 'https://www.aa.org/assets/en_US/en_tradition4.pdf',
    ),
    _ChapterDef(
      key: 'tt_tradition5',
      title: 'Tradition 5',
      subtitle: 'Each group has but one primary purpose…',
      url: 'https://www.aa.org/assets/en_US/en_tradition5.pdf',
    ),
    _ChapterDef(
      key: 'tt_tradition6',
      title: 'Tradition 6',
      subtitle: 'An AA group ought never endorse, finance…',
      url: 'https://www.aa.org/assets/en_US/en_tradition6.pdf',
    ),
    _ChapterDef(
      key: 'tt_tradition7',
      title: 'Tradition 7',
      subtitle: 'Every AA group ought to be fully self-supporting…',
      url: 'https://www.aa.org/assets/en_US/en_tradition7.pdf',
    ),
    _ChapterDef(
      key: 'tt_tradition8',
      title: 'Tradition 8',
      subtitle: 'Alcoholics Anonymous should remain forever nonprofessional…',
      url: 'https://www.aa.org/assets/en_US/en_tradition8.pdf',
    ),
    _ChapterDef(
      key: 'tt_tradition9',
      title: 'Tradition 9',
      subtitle: 'AA, as such, ought never be organized…',
      url: 'https://www.aa.org/assets/en_US/en_tradition9.pdf',
    ),
    _ChapterDef(
      key: 'tt_tradition10',
      title: 'Tradition 10',
      subtitle: 'Alcoholics Anonymous has no opinion on outside issues…',
      url: 'https://www.aa.org/assets/en_US/en_tradition10.pdf',
    ),
    _ChapterDef(
      key: 'tt_tradition11',
      title: 'Tradition 11',
      subtitle: 'Our public relations policy is based on attraction…',
      url: 'https://www.aa.org/assets/en_US/en_tradition11.pdf',
    ),
    _ChapterDef(
      key: 'tt_tradition12',
      title: 'Tradition 12',
      subtitle: 'Anonymity is the spiritual foundation of all our Traditions…',
      url: 'https://www.aa.org/assets/en_US/en_tradition12.pdf',
    ),
  ],
);

const _kBooks = [_kBigBook, _kTwelveTwelve];

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final _allBookmarksProvider = StreamProvider<List<LiteratureBookmark>>(
  (ref) => ref.watch(literatureRepositoryProvider).watchAll(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Root screen
// ─────────────────────────────────────────────────────────────────────────────

class LiteratureScreen extends ConsumerWidget {
  /// 0 = Big Book, 1 = 12 & 12, 2 = Bookmarks
  final int initialTab;
  const LiteratureScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Literature'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Big Book'),
              Tab(text: '12 & 12'),
              Tab(
                icon: Icon(Icons.bookmark, size: 18),
                text: 'Bookmarks',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BookTab(book: _kBigBook),
            _BookTab(book: _kTwelveTwelve),
            _BookmarksTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Book tab: chapter list
// ─────────────────────────────────────────────────────────────────────────────

class _BookTab extends ConsumerWidget {
  final _BookDef book;
  const _BookTab({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(_allBookmarksProvider);
    final bookmarkedKeys = bookmarksAsync.maybeWhen(
      data: (list) => {
        for (final b in list)
          if (b.bookKey == book.id) b.chapterKey,
      },
      orElse: () => <String>{},
    );

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: book.chapters.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) return _BookHeader(book: book);
        final chapter = book.chapters[index - 1];
        final isBookmarked = bookmarkedKeys.contains(chapter.key);
        return _ChapterTile(
          book: book,
          chapter: chapter,
          isBookmarked: isBookmarked,
        );
      },
    );
  }
}

class _BookHeader extends StatelessWidget {
  final _BookDef book;
  const _BookHeader({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: book.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: book.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: book.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(book.icon, color: book.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: book.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  book.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterTile extends ConsumerWidget {
  final _BookDef book;
  final _ChapterDef chapter;
  final bool isBookmarked;

  const _ChapterTile({
    required this.book,
    required this.chapter,
    required this.isBookmarked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(20, 2, 8, 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: book.color.withOpacity(isBookmarked ? 0.15 : 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isBookmarked ? Icons.bookmark : Icons.article_outlined,
          size: 18,
          color: isBookmarked ? book.color : Colors.grey.shade500,
        ),
      ),
      title: Text(
        chapter.title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: chapter.subtitle != null
          ? Text(
              chapter.subtitle!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: isBookmarked ? book.color : Colors.grey.shade400,
              size: 22,
            ),
            tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
            onPressed: () => _toggleBookmark(ref),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
      onTap: () => _openChapter(context),
    );
  }

  Future<void> _openChapter(BuildContext context) async {
    final uri = Uri.parse(chapter.url);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
    );
    if (!launched && context.mounted) {
      // Fallback: try external browser
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _toggleBookmark(WidgetRef ref) async {
    final repo = ref.read(literatureRepositoryProvider);
    if (isBookmarked) {
      await repo.removeBookmark(bookKey: book.id, chapterKey: chapter.key);
    } else {
      await repo.bookmark(
        bookKey: book.id,
        chapterKey: chapter.key,
        chapterTitle: _fullTitle,
      );
    }
  }

  String get _fullTitle =>
      chapter.subtitle != null
          ? '${chapter.title} — ${chapter.subtitle}'
          : chapter.title;
}

// ─────────────────────────────────────────────────────────────────────────────
// Bookmarks tab
// ─────────────────────────────────────────────────────────────────────────────

class _BookmarksTab extends ConsumerWidget {
  const _BookmarksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(_allBookmarksProvider);

    return bookmarksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (bookmarks) {
        if (bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark_outline,
                    size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 14),
                Text(
                  'No bookmarks yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap the bookmark icon on any chapter\nto save it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final b = bookmarks[index];
            return _BookmarkTile(bookmark: b);
          },
        );
      },
    );
  }
}

class _BookmarkTile extends ConsumerWidget {
  final LiteratureBookmark bookmark;
  const _BookmarkTile({required this.bookmark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = _kBooks.firstWhere(
      (b) => b.id == bookmark.bookKey,
      orElse: () => _kBigBook,
    );

    // Find the chapter def to get its URL (null if bookmark is stale)
    final matches = book.chapters.where((c) => c.key == bookmark.chapterKey);
    final _ChapterDef? chapterDef =
        matches.isEmpty ? null : matches.first;

    return Dismissible(
      key: ValueKey('${bookmark.bookKey}_${bookmark.chapterKey}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(literatureRepositoryProvider).removeBookmark(
              bookKey: bookmark.bookKey,
              chapterKey: bookmark.chapterKey,
            );
      },
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: book.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(book.icon, size: 18, color: book.color),
        ),
        title: Text(
          bookmark.chapterTitle,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          book.title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: () async {
          if (chapterDef == null) return;
          final uri = Uri.parse(chapterDef.url);
          final launched =
              await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
          if (!launched && context.mounted) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}
