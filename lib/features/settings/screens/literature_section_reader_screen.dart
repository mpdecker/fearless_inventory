import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/literature_pdf_catalog_service.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/literature_pdf_providers.dart';

/// Scrollable extracted plain text for one outline section.
class LiteratureSectionReaderScreen extends ConsumerWidget {
  const LiteratureSectionReaderScreen({
    super.key,
    required this.bookKey,
    required this.section,
  });

  final String bookKey;
  final LiteratureNavSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = bookKey == 'twelve_twelve'
        ? AppColors.literatureLinkVisited
        : AppColors.literatureLink;

    final asyncText = ref.watch(
      literatureSectionTextProvider(
        SectionTextRequest(
          bookKey: bookKey,
          startPage: section.startPage,
          endPage: section.endPage,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          section.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'p. ${section.startPage}–${section.endPage}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),
        ],
      ),
      body: asyncText.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not read this section.\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (text) {
          if (text.isEmpty) {
            return const Center(
              child: Text('No extractable text on these pages.'),
            );
          }
          return Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: SelectableText(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Material(
        elevation: 8,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Text extracted from your bundled PDF for personal study.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color.withValues(alpha: 0.85),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
