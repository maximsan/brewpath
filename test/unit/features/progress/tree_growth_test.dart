import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/features/progress/domain/tree_growth.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

/// Foundations as it ships: five modules, thirty-two core lessons.
const _sizes = [7, 7, 6, 6, 6];
const _courseLessons = 32;

int _stage(int completed, {List<int> sizes = _sizes}) =>
    treeStageForProgress(completed: completed, moduleSizes: sizes);

int? _toNext(int completed, {List<int> sizes = _sizes}) =>
    lessonsToNextStage(completed: completed, moduleSizes: sizes);

void main() {
  group('both ends', () {
    test('a fresh install is at seed', () {
      expect(_stage(0), freshTreeStage);
    });

    test('a finished course is the last stage', () {
      expect(_stage(_courseLessons), treeStageCount);
    });

    test('one lesson has already left the fresh value', () {
      expect(_stage(1), greaterThan(freshTreeStage));
    });
  });

  // The design's own sentence, beside its table: "The 10 stages are pinned to
  // the 5 modules so a module boundary is always a visible jump. Each module
  // owns two growth steps — one at its halfway point, one on completion —
  // except the last, whose single step IS the harvest."
  group('the stage is pinned to the modules', () {
    test("a module's halfway point is a step", () {
      expect(_stage(3), 1);
      expect(_stage(4), 2); // ceil(7/2)
    });

    test("a module's completion is a step", () {
      expect(_stage(6), 2);
      expect(_stage(7), 3);
    });

    test('every module boundary lands on the design table', () {
      // start 1 · M1 2→3 · M2 4→5 · M3 6→7 · M4 8→9 · M5 →10
      expect(_stage(7), 3);
      expect(_stage(14), 5);
      expect(_stage(20), 7);
      expect(_stage(26), 9);
      expect(_stage(32), treeStageCount);
    });
  });

  // The bug this replaced: the stage was a lesson ratio rounded up, so the
  // tree reached the last stage at lesson 29 and the final three lessons of
  // the course grew nothing — the completion the course is built toward moved
  // no picture at all (#376).
  group('harvest waits for the end', () {
    test('the last stage arrives only on the final lesson', () {
      expect(_stage(31), lessThan(treeStageCount));
      expect(_stage(32), treeStageCount);
    });

    test('the lessons before the end each still have somewhere to go', () {
      for (final completed in [29, 30, 31]) {
        expect(
          _stage(completed),
          lessThan(treeStageCount),
          reason: 'lesson $completed reached harvest early',
        );
      }
    });
  });

  group('every boundary', () {
    test('the stage never goes backwards as lessons accumulate', () {
      var previous = freshTreeStage;
      for (var completed = 0; completed <= _courseLessons; completed++) {
        final stage = _stage(completed);
        expect(stage, greaterThanOrEqualTo(previous));
        previous = stage;
      }
    });

    test('it covers every stage from the first to the last, and no more', () {
      final reached = {
        for (var completed = 0; completed <= _courseLessons; completed++)
          _stage(completed),
      };

      expect(reached, containsAll([for (var s = 0; s <= 10; s++) s]));
      expect(reached.reduce((a, b) => a > b ? a : b), treeStageCount);
    });

    test('it never exceeds the art that exists', () {
      expect(_stage(_courseLessons + 20), treeStageCount);
    });
  });

  group('growing the course', () {
    // The bug this shape exists to prevent, stated as a test: the derivation
    // returns *less* for the same learner once the course grows, which is why
    // the stored stage is a floor and this is only ever allowed to raise it.
    test('the same learner derives lower on a bigger course', () {
      const grown = [7, 7, 6, 6, 10];

      expect(_stage(32, sizes: grown), lessThan(_stage(32)));
      expect(_stage(32), treeStageCount);
    });

    test('and never higher, at any point in the course', () {
      const grown = [7, 7, 6, 6, 10];
      for (var completed = 0; completed <= _courseLessons; completed++) {
        expect(
          _stage(completed, sizes: grown),
          lessThanOrEqualTo(_stage(completed)),
        );
      }
    });
  });

  group('degenerate courses', () {
    test('a course with no modules is fresh, not a divide by zero', () {
      expect(_stage(0, sizes: const []), freshTreeStage);
      expect(_stage(5, sizes: const []), freshTreeStage);
    });

    // Faithful to the design's walk rather than forced: a course with one
    // module holds one growth step — its completion — so it ends at the stage
    // after the seed. Only the five-module shape the course actually ships
    // climbs the whole ladder.
    test('a one-module course ends one step past the seed', () {
      expect(_stage(1, sizes: const [1]), 2);
    });

    test('a module with no lessons cannot stall the walk', () {
      expect(_stage(3, sizes: const [0, 4]), greaterThanOrEqualTo(1));
    });
  });

  // The still-tree line: most completions cross no threshold, so the screen
  // says how far the next one is rather than showing a tree that did not move.
  group('how far the next stage is', () {
    test('counts down to the next threshold', () {
      expect(_toNext(0), 4);
      expect(_toNext(3), 1);
    });

    test('a completion that just crossed one looks to the one after', () {
      expect(_toNext(4), 3); // 4 → 7, the end of module one
    });

    test('the finished course has nowhere further to go', () {
      expect(_toNext(32), isNull);
      expect(_toNext(99), isNull);
    });

    test('every threshold it names is a stage the tree actually reaches', () {
      var completed = 0;
      final crossings = <int>[];
      while (crossings.length < treeStageCount) {
        final toNext = _toNext(completed);
        if (toNext == null) break;
        completed += toNext;
        crossings.add(completed);
        expect(
          _stage(completed),
          greaterThan(_stage(completed - 1)),
          reason: 'crossing $completed did not move the tree',
        );
      }
      expect(_stage(crossings.last), treeStageCount);
    });
  });

  group('the module sizes the walk folds over', () {
    test('are the design table, derived rather than listed', () {
      expect(treeStageThresholds(_sizes), [4, 7, 11, 14, 17, 20, 23, 26, 32]);
    });

    // The walk is positional, so two modules swapped in the bank would move
    // every threshold after them.
    test('are read in course position, not bank order', () {
      final shuffled = [
        testModule(id: 'm3', n: 3, lessonIds: const ['a', 'b', 'c']),
        testModule(lessonIds: const ['d']),
        testModule(id: 'm2', n: 2, lessonIds: const ['e', 'f']),
      ];

      expect(moduleSizesInOrder(shuffled), [1, 2, 3]);
    });
  });
}
