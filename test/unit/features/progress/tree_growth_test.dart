import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/features/progress/domain/tree_growth.dart';
import 'package:flutter_test/flutter_test.dart';

/// Foundations as it ships.
const _courseLessons = 32;

int _stage(int completed, {int total = _courseLessons}) =>
    treeStageForProgress(completed: completed, total: total);

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
      final onSmallCourse = _stage(31);
      final onGrownCourse = _stage(31, total: 36);

      expect(onGrownCourse, lessThan(onSmallCourse));
      expect(onSmallCourse, treeStageCount);
    });
  });

  group('degenerate courses', () {
    test('a course with no lessons is seed, not a divide by zero', () {
      expect(_stage(0, total: 0), freshTreeStage);
      expect(_stage(5, total: 0), freshTreeStage);
    });

    test('a one-lesson course finishes at the last stage', () {
      expect(_stage(1, total: 1), treeStageCount);
    });
  });
}
