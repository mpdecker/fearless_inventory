import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/literature_pdf_catalog_service.dart';

final literaturePdfCatalogServiceProvider =
    Provider<LiteraturePdfCatalogService>((ref) {
      return LiteraturePdfCatalogService();
    });

final literatureSectionsProvider =
    FutureProvider.family<List<LiteratureNavSection>, String>((ref, bookKey) {
      return ref
          .watch(literaturePdfCatalogServiceProvider)
          .loadSections(bookKey);
    });

@immutable
class SectionTextRequest {
  const SectionTextRequest({
    required this.bookKey,
    required this.startPage,
    required this.endPage,
  });

  final String bookKey;
  final int startPage;
  final int endPage;

  @override
  bool operator ==(Object other) =>
      other is SectionTextRequest &&
      other.bookKey == bookKey &&
      other.startPage == startPage &&
      other.endPage == endPage;

  @override
  int get hashCode => Object.hash(bookKey, startPage, endPage);
}

final literatureSectionTextProvider =
    FutureProvider.family<String, SectionTextRequest>((ref, req) {
      return ref
          .watch(literaturePdfCatalogServiceProvider)
          .loadSectionPlainText(
            bookKey: req.bookKey,
            startPage: req.startPage,
            endPage: req.endPage,
          );
    });
