import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/features/settings/screens/literature_annotation_spans.dart';

/// Builds a real [LiteratureAnnotation] row without a DB, for offset math tests.
LiteratureAnnotation _ann({
  required int id,
  required int start,
  required int end,
  String color = 'yellow',
  String? note,
}) {
  return LiteratureAnnotation(
    id: id,
    bookKey: 'bigbook',
    startPage: 1,
    endPage: 2,
    sectionTitle: 'S',
    selectionStart: start,
    selectionEnd: end,
    selectedText: 'x',
    color: color,
    note: note,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

/// Reconstructs the text a set of runs would render, to assert the tiling
/// invariant that keeps selection offsets valid.
String _flatten(String text, List<AnnotationRun> runs) =>
    runs.map((r) => text.substring(r.start, r.end)).join();

void main() {
  // A drift row requires generated code; make sure it links in this test target.
  setUpAll(() => AppDatabase.testing(NativeDatabase.memory()).close());

  group('computeAnnotationRuns tiling invariant', () {
    const text = 'Rarely have we seen a person fail who has followed our path.';
    final len = text.length;

    void expectTiles(List<AnnotationRun> runs) {
      expect(runs, isNotEmpty);
      expect(runs.first.start, 0);
      expect(runs.last.end, len);
      for (var i = 0; i < runs.length; i++) {
        expect(runs[i].end, greaterThan(runs[i].start),
            reason: 'run $i must be non-empty');
        if (i > 0) {
          expect(runs[i].start, runs[i - 1].end,
              reason: 'runs must be contiguous');
        }
      }
      // The whole point: concatenating runs reproduces the source exactly.
      expect(_flatten(text, runs), text);
    }

    test('no annotations → one uncovered run over the whole text', () {
      final runs = computeAnnotationRuns(len, const []);
      expectTiles(runs);
      expect(runs.single.annotation, isNull);
    });

    test('single annotation tiles and covers its range', () {
      final runs = computeAnnotationRuns(len, [_ann(id: 1, start: 0, end: 6)]);
      expectTiles(runs);
      final covered =
          runs.where((r) => r.annotation != null).toList();
      expect(covered, hasLength(1));
      expect(covered.single.start, 0);
      expect(covered.single.end, 6);
    });

    test('adjacent annotations both tile', () {
      final runs = computeAnnotationRuns(len, [
        _ann(id: 1, start: 0, end: 6),
        _ann(id: 2, start: 6, end: 12),
      ]);
      expectTiles(runs);
      expect(runs.where((r) => r.annotation != null), hasLength(2));
    });

    test('overlapping annotations: earliest-start wins the shared run', () {
      final runs = computeAnnotationRuns(len, [
        _ann(id: 2, start: 5, end: 20, color: 'green'),
        _ann(id: 1, start: 0, end: 10, color: 'yellow'),
      ]);
      expectTiles(runs);
      // The [5,10) overlap belongs to the earliest-starting annotation (id 1).
      final overlap = runs.firstWhere((r) => r.start == 5 && r.end == 10);
      expect(overlap.annotation!.id, 1);
      expect(overlap.annotation!.color, 'yellow');
    });

    test('out-of-range offsets are clamped, still tiling', () {
      final runs = computeAnnotationRuns(len, [
        _ann(id: 1, start: -5, end: 8),
        _ann(id: 2, start: len - 3, end: len + 999),
      ]);
      expectTiles(runs);
    });

    test('empty text yields no runs', () {
      expect(computeAnnotationRuns(0, [_ann(id: 1, start: 0, end: 3)]), isEmpty);
    });
  });

  group('resolveSelectionRange', () {
    test('collapsed selection → null', () {
      expect(resolveSelectionRange(4, 4, 100), isNull);
    });

    test('normal selection passes through', () {
      final r = resolveSelectionRange(3, 9, 100);
      expect(r, isNotNull);
      expect(r!.start, 3);
      expect(r.end, 9);
    });

    test('offsets clamp to text length', () {
      final r = resolveSelectionRange(90, 500, 100);
      expect(r!.start, 90);
      expect(r.end, 100);
    });

    test('range that clamps to empty → null', () {
      expect(resolveSelectionRange(100, 120, 100), isNull);
    });
  });
}
