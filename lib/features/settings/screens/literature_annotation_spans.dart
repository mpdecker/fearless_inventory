import '../../../core/database/database.dart';

/// A contiguous stretch of section text, optionally covered by one annotation.
/// Runs returned by [computeAnnotationRuns] tile the whole text with no gaps or
/// overlaps, so concatenating their substrings reproduces the source text
/// exactly — which is what keeps `SelectableText` selection offsets valid.
class AnnotationRun {
  final int start;
  final int end;
  final LiteratureAnnotation? annotation;
  const AnnotationRun(this.start, this.end, this.annotation);
}

/// Splits `[0, textLength)` at every annotation boundary and labels each run
/// with the annotation covering it, if any. Where annotations overlap, the one
/// starting earliest (ties broken by end, then id) wins the shared run.
///
/// Offsets are clamped to `[0, textLength]`, so annotations whose stored
/// offsets drift past the current text never produce out-of-range runs.
List<AnnotationRun> computeAnnotationRuns(
  int textLength,
  List<LiteratureAnnotation> annotations,
) {
  if (textLength <= 0) return const [];
  if (annotations.isEmpty) {
    return [AnnotationRun(0, textLength, null)];
  }

  // Deterministic "earliest wins" order, independent of query ordering.
  final ordered = [...annotations]..sort((a, b) {
      final byStart = a.selectionStart.compareTo(b.selectionStart);
      if (byStart != 0) return byStart;
      final byEnd = a.selectionEnd.compareTo(b.selectionEnd);
      if (byEnd != 0) return byEnd;
      return a.id.compareTo(b.id);
    });

  final bounds = <int>{0, textLength};
  for (final a in ordered) {
    bounds.add(a.selectionStart.clamp(0, textLength));
    bounds.add(a.selectionEnd.clamp(0, textLength));
  }
  final sorted = bounds.toList()..sort();

  final runs = <AnnotationRun>[];
  for (var i = 0; i < sorted.length - 1; i++) {
    final runStart = sorted[i];
    final runEnd = sorted[i + 1];
    if (runEnd <= runStart) continue;

    LiteratureAnnotation? covering;
    for (final a in ordered) {
      final s = a.selectionStart.clamp(0, textLength);
      final e = a.selectionEnd.clamp(0, textLength);
      if (s <= runStart && e >= runEnd) {
        covering = a;
        break;
      }
    }
    runs.add(AnnotationRun(runStart, runEnd, covering));
  }
  return runs;
}

/// Normalizes a text selection into a valid, in-range `[start, end)` for
/// creating an annotation, or null when there is nothing to annotate.
///
/// [start] is the character offset the highlight begins at and [end] where it
/// ends (exclusive). Returns null for a collapsed/invalid selection or one that
/// clamps to an empty range.
({int start, int end})? resolveSelectionRange(int selStart, int selEnd, int textLength) {
  final start = selStart.clamp(0, textLength);
  final end = selEnd.clamp(0, textLength);
  if (end <= start) return null;
  return (start: start, end: end);
}

/// Builds the text-selection toolbar items for the literature reader.
///
/// The screen's own actions are returned **before** [platformItems] on purpose:
/// iOS shows only the first few entries and hides the rest behind an overflow
/// arrow, so appending them put Highlight and Note one tap deeper than the
/// platform's Copy / Look Up / Search Web — the wrong priority on a screen
/// whose whole purpose is annotating.
List<T> annotationMenuItemsFirst<T>({
  required bool hasSelection,
  required T highlightItem,
  required T noteItem,
  required List<T> platformItems,
}) {
  return [
    if (hasSelection) ...[highlightItem, noteItem],
    ...platformItems,
  ];
}
