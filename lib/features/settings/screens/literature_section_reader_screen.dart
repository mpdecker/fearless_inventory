import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/services/literature_pdf_catalog_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/literature_annotation_repository.dart';
import '../providers/literature_pdf_providers.dart';

/// Named highlight colours. Stored by [name]; rendered as a translucent wash so
/// the underlying text stays readable in the dark theme.
const _highlightColors = <String, Color>{
  'yellow': Color(0xFFFFEB3B),
  'green': Color(0xFF66BB6A),
  'blue': Color(0xFF42A5F5),
  'pink': Color(0xFFEC407A),
};

const _defaultHighlightColor = 'yellow';

Color _washFor(String colorName) =>
    (_highlightColors[colorName] ?? _highlightColors[_defaultHighlightColor]!)
        .withValues(alpha: 0.34);

/// Scrollable extracted plain text for one outline section, with the ability to
/// highlight passages and attach notes.
class LiteratureSectionReaderScreen extends ConsumerStatefulWidget {
  const LiteratureSectionReaderScreen({
    super.key,
    required this.bookKey,
    required this.section,
  });

  final String bookKey;
  final LiteratureNavSection section;

  @override
  ConsumerState<LiteratureSectionReaderScreen> createState() =>
      _LiteratureSectionReaderScreenState();
}

class _LiteratureSectionReaderScreenState
    extends ConsumerState<LiteratureSectionReaderScreen> {
  /// Tap recognizers for note-bearing highlight spans. Rebuilt each paint and
  /// disposed here so they never leak.
  final List<TapGestureRecognizer> _recognizers = [];

  SectionTextRequest get _request => SectionTextRequest(
        bookKey: widget.bookKey,
        startPage: widget.section.startPage,
        endPage: widget.section.endPage,
      );

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  LiteratureAnnotationRepository get _repo =>
      ref.read(literatureAnnotationRepositoryProvider);

  // ── Create ────────────────────────────────────────────────────────────────

  Future<void> _createFromSelection(
    TextSelection selection,
    String fullText, {
    required bool withNote,
  }) async {
    if (selection.isCollapsed) return;
    final start = selection.start.clamp(0, fullText.length);
    final end = selection.end.clamp(0, fullText.length);
    if (end <= start) return;
    final excerpt = fullText.substring(start, end);

    final id = await _repo.add(
      bookKey: widget.bookKey,
      startPage: widget.section.startPage,
      endPage: widget.section.endPage,
      sectionTitle: widget.section.title,
      selectionStart: start,
      selectionEnd: end,
      selectedText: excerpt,
      color: _defaultHighlightColor,
    );

    if (withNote && mounted) {
      // Reload the just-created row and open the editor.
      final rows = await _repo
          .watchForSection(
            bookKey: widget.bookKey,
            startPage: widget.section.startPage,
            endPage: widget.section.endPage,
          )
          .first;
      final created = rows.where((a) => a.id == id).firstOrNull;
      if (created != null && mounted) {
        _openAnnotationSheet(created, startInEdit: true);
      }
    }
  }

  // ── Manage ──────────────────────────────────────────────────────────────

  void _openAnnotationSheet(
    LiteratureAnnotation annotation, {
    bool startInEdit = false,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffold,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AnnotationSheet(
        annotation: annotation,
        startInEdit: startInEdit,
      ),
    );
  }

  void _openAnnotationsList(List<LiteratureAnnotation> annotations) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffold,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AnnotationsList(
        annotations: annotations,
        onTap: (a) {
          Navigator.of(context).pop();
          _openAnnotationSheet(a);
        },
      ),
    );
  }

  // ── Rich text with highlights ──────────────────────────────────────────

  /// Builds the section text as a [TextSpan] with highlight backgrounds. Runs
  /// are cut at annotation boundaries; where annotations overlap, the earliest
  /// one wins for that stretch. Note-bearing runs get a dotted underline and a
  /// tap recognizer that opens the annotation.
  TextSpan _buildSpan(
    String text,
    List<LiteratureAnnotation> annotations,
    TextStyle baseStyle,
  ) {
    _disposeRecognizers();
    if (annotations.isEmpty) return TextSpan(text: text, style: baseStyle);

    // Collect boundary offsets, clamped to the text length.
    final len = text.length;
    final bounds = <int>{0, len};
    for (final a in annotations) {
      bounds.add(a.selectionStart.clamp(0, len));
      bounds.add(a.selectionEnd.clamp(0, len));
    }
    final sorted = bounds.toList()..sort();

    final spans = <InlineSpan>[];
    for (var i = 0; i < sorted.length - 1; i++) {
      final runStart = sorted[i];
      final runEnd = sorted[i + 1];
      if (runEnd <= runStart) continue;

      // Earliest annotation covering this run, if any.
      LiteratureAnnotation? covering;
      for (final a in annotations) {
        final s = a.selectionStart.clamp(0, len);
        final e = a.selectionEnd.clamp(0, len);
        if (s <= runStart && e >= runEnd) {
          covering = a;
          break;
        }
      }

      if (covering == null) {
        spans.add(TextSpan(text: text.substring(runStart, runEnd)));
        continue;
      }

      final hasNote = (covering.note ?? '').trim().isNotEmpty;
      TapGestureRecognizer? recognizer;
      final captured = covering;
      recognizer = TapGestureRecognizer()
        ..onTap = () => _openAnnotationSheet(captured);
      _recognizers.add(recognizer);

      spans.add(TextSpan(
        text: text.substring(runStart, runEnd),
        recognizer: recognizer,
        style: TextStyle(
          backgroundColor: _washFor(covering.color),
          decoration: hasNote ? TextDecoration.underline : null,
          decorationStyle: TextDecorationStyle.dotted,
          decorationColor: baseStyle.color,
        ),
      ));
    }

    return TextSpan(style: baseStyle, children: spans);
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.bookKey == 'twelve_twelve'
        ? AppColors.literatureLinkVisited
        : AppColors.literatureLink;

    final asyncText = ref.watch(literatureSectionTextProvider(_request));
    final annotations =
        ref.watch(literatureSectionAnnotationsProvider(_request)).valueOrNull ??
            const <LiteratureAnnotation>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (annotations.isNotEmpty)
            IconButton(
              tooltip: 'Highlights & notes',
              icon: Badge(
                label: Text('${annotations.length}'),
                child: const Icon(Icons.notes_outlined),
              ),
              onPressed: () => _openAnnotationsList(annotations),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'p. ${widget.section.startPage}–${widget.section.endPage}',
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
          final baseStyle = theme.textTheme.bodyLarge!.copyWith(
            height: 1.45,
            fontSize: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
          );
          return Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: SelectableText.rich(
                _buildSpan(text, annotations, baseStyle),
                contextMenuBuilder: (context, editableState) {
                  final selection =
                      editableState.textEditingValue.selection;
                  return AdaptiveTextSelectionToolbar.buttonItems(
                    anchors: editableState.contextMenuAnchors,
                    buttonItems: <ContextMenuButtonItem>[
                      ...editableState.contextMenuButtonItems,
                      if (!selection.isCollapsed) ...[
                        ContextMenuButtonItem(
                          label: 'Highlight',
                          onPressed: () {
                            editableState.hideToolbar();
                            _createFromSelection(selection, text,
                                withNote: false);
                          },
                        ),
                        ContextMenuButtonItem(
                          label: 'Note',
                          onPressed: () {
                            editableState.hideToolbar();
                            _createFromSelection(selection, text,
                                withNote: true);
                          },
                        ),
                      ],
                    ],
                  );
                },
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
              'Select text to highlight or add a note. Extracted from your '
              'bundled PDF for personal study.',
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

// ─────────────────────────────────────────────────────────────────────────────
// Annotation editor sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AnnotationSheet extends ConsumerStatefulWidget {
  const _AnnotationSheet({
    required this.annotation,
    this.startInEdit = false,
  });

  final LiteratureAnnotation annotation;
  final bool startInEdit;

  @override
  ConsumerState<_AnnotationSheet> createState() => _AnnotationSheetState();
}

class _AnnotationSheetState extends ConsumerState<_AnnotationSheet> {
  late final TextEditingController _noteCtrl;
  late String _color;

  LiteratureAnnotationRepository get _repo =>
      ref.read(literatureAnnotationRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(text: widget.annotation.note ?? '');
    _color = widget.annotation.color;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _repo.setNote(widget.annotation.id, _noteCtrl.text);
    if (_color != widget.annotation.color) {
      await _repo.setColor(widget.annotation.id, _color);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    await _repo.delete(widget.annotation.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Highlighted excerpt.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _washFor(_color),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '“${widget.annotation.selectedText.trim()}”',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          // Colour chips.
          Row(
            children: [
              for (final entry in _highlightColors.entries) ...[
                _ColorDot(
                  color: entry.value,
                  selected: _color == entry.key,
                  onTap: () => setState(() => _color = entry.key),
                ),
                const SizedBox(width: 12),
              ],
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteCtrl,
            autofocus: widget.startInEdit,
            minLines: 2,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Add a note…',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton.icon(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Annotations list sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AnnotationsList extends StatelessWidget {
  const _AnnotationsList({
    required this.annotations,
    required this.onTap,
  });

  final List<LiteratureAnnotation> annotations;
  final void Function(LiteratureAnnotation) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.notes_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Highlights & notes (${annotations.length})',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: annotations.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final a = annotations[i];
                  final hasNote = (a.note ?? '').trim().isNotEmpty;
                  return ListTile(
                    leading: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _washFor(a.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      a.selectedText.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: hasNote
                        ? Text(
                            a.note!.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          )
                        : null,
                    trailing: hasNote
                        ? const Icon(Icons.sticky_note_2_outlined, size: 18)
                        : null,
                    onTap: () => onTap(a),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
