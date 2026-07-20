import 'package:flutter/material.dart';

import '../../../core/navigation/adaptive_page_route.dart';
import '../../../core/services/literature_pdf_catalog_service.dart';
import '../screens/literature_section_reader_screen.dart';

class LiteratureSearchDelegate extends SearchDelegate<void> {
  LiteratureSearchDelegate({
    required this.catalog,
    required this.bookKey,
    required this.sections,
  });

  final LiteraturePdfCatalogService catalog;
  final String bookKey;
  final List<LiteratureNavSection> sections;

  @override
  String get searchFieldLabel => 'Search in book';

  @override
  List<Widget>? buildActions(BuildContext context) {
    if (query.isEmpty) return null;
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const BackButtonIcon(),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Type a word or phrase from the book.'));
    }
    return buildResults(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    final q = query.trim();
    if (q.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<LiteratureSearchHit>>(
      future: catalog.search(bookKey: bookKey, query: q, sections: sections),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Search failed: ${snap.error}'));
        }
        final hits = snap.data ?? [];
        if (hits.isEmpty) {
          return const Center(child: Text('No matches.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: hits.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final h = hits[i];
            return ListTile(
              title: Text(
                h.sectionTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'p. ${h.page} — ${h.snippet}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                close(context, null);
                final section = LiteratureNavSection(
                  key: h.sectionKey,
                  title: '${h.sectionTitle} (p. ${h.page})',
                  startPage: h.page,
                  endPage: h.page,
                );
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
          },
        );
      },
    );
  }
}
