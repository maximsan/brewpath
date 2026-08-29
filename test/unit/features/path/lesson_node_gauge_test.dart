import 'package:brew_path/features/path/domain/lesson_node_gauge.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('complete and scored', () {
    test('fills to the score ratio in sage', () {
      final gauge = lessonNodeGauge(
        isComplete: true,
        isCurrent: false,
        mastery: const MasteryResult(correct: 4, total: 5),
      );

      expect(gauge.fill, 0.8);
      expect(gauge.tone, LessonNodeTone.sage);
    });

    test('a perfect run fills the bean', () {
      final gauge = lessonNodeGauge(
        isComplete: true,
        isCurrent: false,
        mastery: const MasteryResult(correct: 5, total: 5),
      );

      expect(gauge.fill, 1.0);
      expect(gauge.tone, LessonNodeTone.sage);
    });

    test('needs-practice takes the accent, not sage', () {
      // Two or more wrong. The design puts this on accent alongside the
      // current lesson: it is the state asking to be replayed.
      final gauge = lessonNodeGauge(
        isComplete: true,
        isCurrent: false,
        mastery: const MasteryResult(correct: 3, total: 5),
      );

      expect(gauge.tone, LessonNodeTone.accent);
      expect(gauge.fill, 0.6);
    });

    test('a zero score still shows the floor rather than an empty bean', () {
      final gauge = lessonNodeGauge(
        isComplete: true,
        isCurrent: false,
        mastery: const MasteryResult(correct: 0, total: 5),
      );

      expect(gauge.fill, LessonNodeGauge.scoredFloor);
      expect(gauge.tone, LessonNodeTone.accent);
    });
  });

  group('complete but unscored', () {
    test('is a muted empty bean, never a full sage one', () {
      // The deliberately neutral arm: only a lesson with a stored score can
      // claim mastery.
      final gauge = lessonNodeGauge(isComplete: true, isCurrent: false);

      expect(gauge.fill, 0);
      expect(gauge.tone, LessonNodeTone.muted);
    });

    test('stays neutral even when it is also the current lesson', () {
      final gauge = lessonNodeGauge(isComplete: true, isCurrent: true);

      expect(gauge.tone, LessonNodeTone.muted);
    });
  });

  group('current', () {
    test('an unplayed current lesson shows the nudge fill in accent', () {
      final gauge = lessonNodeGauge(isComplete: false, isCurrent: true);

      expect(gauge.fill, LessonNodeGauge.unplayedCurrentFill);
      expect(gauge.tone, LessonNodeTone.accent);
    });
  });

  group('upcoming', () {
    test('an untouched lesson is an empty sage bean', () {
      final gauge = lessonNodeGauge(isComplete: false, isCurrent: false);

      expect(gauge.fill, 0);
      expect(gauge.tone, LessonNodeTone.sage);
    });

    test('a stored score does not count until the lesson is complete', () {
      final gauge = lessonNodeGauge(
        isComplete: false,
        isCurrent: false,
        mastery: const MasteryResult(correct: 5, total: 5),
      );

      expect(gauge.fill, 0);
      expect(gauge.tone, LessonNodeTone.sage);
    });
  });
}
