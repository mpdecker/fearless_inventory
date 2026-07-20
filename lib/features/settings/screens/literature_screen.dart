import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/literature/literature_book_catalog.dart';
import '../../../core/navigation/adaptive_page_route.dart';
import '../../../core/services/literature_pdf_catalog_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/literature_repository.dart';
import '../providers/literature_pdf_providers.dart';
import 'literature_section_reader_screen.dart';
import '../widgets/literature_search_delegate.dart';

final _allBookmarksProvider = StreamProvider<List<LiteratureBookmark>>(
  (ref) => ref.watch(literatureRepositoryProvider).watchAll(),
);

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
              Tab(icon: Icon(Icons.bookmark, size: 18), text: 'Bookmarks'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BookTab(bookKey: LiteratureBookCatalog.bigBookKey),
            _BookTab(bookKey: LiteratureBookCatalog.twelveTwelveKey),
            _BookmarksTab(),
          ],
        ),
      ),
    );
  }
}

class _BookTab extends ConsumerWidget {
  final String bookKey;
  const _BookTab({required this.bookKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(literatureSectionsProvider(bookKey));
    final bookmarksAsync = ref.watch(_allBookmarksProvider);
    final bookmarkedKeys = bookmarksAsync.maybeWhen(
      data: (list) => {
        for (final b in list)
          if (b.bookKey == bookKey) b.chapterKey,
      },
      orElse: () => <String>{},
    );

    return sectionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load table of contents.\n$e',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (sections) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sections.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _BookHeader(bookKey: bookKey, sections: sections);
            }
            final section = sections[index - 1];
            final isBookmarked = bookmarkedKeys.contains(section.key);
            return _SectionTile(
              bookKey: bookKey,
              section: section,
              isBookmarked: isBookmarked,
            );
          },
        );
      },
    );
  }
}

class _BookHeader extends ConsumerWidget {
  final String bookKey;
  final List<LiteratureNavSection> sections;

  const _BookHeader({required this.bookKey, required this.sections});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = bookKey == LiteratureBookCatalog.twelveTwelveKey
        ? AppColors.literatureLinkVisited
        : AppColors.literatureLink;
    final icon = bookKey == LiteratureBookCatalog.twelveTwelveKey
        ? Icons.menu_book_outlined
        : Icons.auto_stories_outlined;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LiteratureBookCatalog.titleForBookKey(bookKey),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  LiteratureBookCatalog.subtitleForBookKey(bookKey),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Search',
            icon: Icon(Icons.search, color: color),
            onPressed: () {
              showSearch<void>(
                context: context,
                delegate: LiteratureSearchDelegate(
                  catalog: ref.read(literaturePdfCatalogServiceProvider),
                  bookKey: bookKey,
                  sections: sections,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends ConsumerWidget {
  final String bookKey;
  final LiteratureNavSection section;
  final bool isBookmarked;

  const _SectionTile({
    required this.bookKey,
    required this.section,
    required this.isBookmarked,
  });

  Color get _color => bookKey == LiteratureBookCatalog.twelveTwelveKey
      ? AppColors.literatureLinkVisited
      : AppColors.literatureLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(20, 2, 8, 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _color.withValues(alpha: isBookmarked ? 0.15 : 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isBookmarked ? Icons.bookmark : Icons.article_outlined,
          size: 18,
          color: isBookmarked ? _color : Colors.grey.shade500,
        ),
      ),
      title: Text(
        section.title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        'Pages ${section.startPage}–${section.endPage}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: isBookmarked ? _color : Colors.grey.shade400,
              size: 22,
            ),
            tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
            onPressed: () => _toggleBookmark(ref),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          adaptivePageRoute(
            (_) => LiteratureSectionReaderScreen(
              bookKey: bookKey,
              section: section,
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleBookmark(WidgetRef ref) async {
    final repo = ref.read(literatureRepositoryProvider);
    if (isBookmarked) {
      await repo.removeBookmark(bookKey: bookKey, chapterKey: section.key);
    } else {
      await repo.bookmark(
        bookKey: bookKey,
        chapterKey: section.key,
        chapterTitle: section.title,
      );
    }
  }
}

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
                Icon(
                  Icons.bookmark_outline,
                  size: 56,
                  color: Colors.grey.shade300,
                ),
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
                  'Tap the bookmark icon on any section\nto save it here.',
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
    final bookKey = bookmark.bookKey;
    final color = bookKey == LiteratureBookCatalog.twelveTwelveKey
        ? AppColors.literatureLinkVisited
        : AppColors.literatureLink;
    final icon = bookKey == LiteratureBookCatalog.twelveTwelveKey
        ? Icons.menu_book_outlined
        : Icons.auto_stories_outlined;

    final sectionsAsync = ref.watch(literatureSectionsProvider(bookKey));

    return sectionsAsync.when(
      loading: () => ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
        title: Text(bookmark.chapterTitle),
        subtitle: Text(LiteratureBookCatalog.titleForBookKey(bookKey)),
      ),
      error: (_, __) => ListTile(
        leading: Icon(Icons.error_outline, color: color),
        title: Text(bookmark.chapterTitle),
        subtitle: const Text('Could not load book'),
      ),
      data: (sections) {
        final svc = ref.read(literaturePdfCatalogServiceProvider);
        final section = svc.matchBookmarkToSection(
          sections: sections,
          chapterKey: bookmark.chapterKey,
          chapterTitle: bookmark.chapterTitle,
        );

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
            ref
                .read(literatureRepositoryProvider)
                .removeBookmark(
                  bookKey: bookmark.bookKey,
                  chapterKey: bookmark.chapterKey,
                );
          },
          child: ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            title: Text(
              bookmark.chapterTitle,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              LiteratureBookCatalog.titleForBookKey(bookKey),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
            onTap: () {
              if (section == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'This bookmark no longer matches the PDF outline. Remove it and bookmark again.',
                    ),
                  ),
                );
                return;
              }
              Navigator.of(context).push(
                adaptivePageRoute(
                  (_) => LiteratureSectionReaderScreen(
                    bookKey: bookKey,
                    section: section,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
