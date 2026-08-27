import 'package:brew_path/features/lessons/presentation/cards/multi_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Three correct among five, the shape nine of the ten authored cards take.
  const correct = [true, false, true, false, true];

  group('all-or-nothing', () {
    test('the exact correct set scores', () {
      expect(isMultiCorrect(selected: {0, 2, 4}, isCorrect: correct), isTrue);
    });

    test('order of selection is irrelevant — it is a set', () {
      expect(isMultiCorrect(selected: {4, 0, 2}, isCorrect: correct), isTrue);
    });

    test('a correct subset does not score', () {
      expect(
        isMultiCorrect(selected: {0, 2}, isCorrect: correct),
        isFalse,
        reason: 'missing a correct choice is not a partial pass',
      );
    });

    test('a superset does not score', () {
      expect(
        isMultiCorrect(selected: {0, 1, 2, 4}, isCorrect: correct),
        isFalse,
        reason: 'picking everything must not be a winning strategy',
      );
    });

    test('picking every choice does not score', () {
      expect(
        isMultiCorrect(selected: {0, 1, 2, 3, 4}, isCorrect: correct),
        isFalse,
      );
    });

    test('an empty selection does not score', () {
      expect(isMultiCorrect(selected: const {}, isCorrect: correct), isFalse);
    });

    test('a same-sized but wrong set does not score', () {
      expect(
        isMultiCorrect(selected: {0, 1, 3}, isCorrect: correct),
        isFalse,
        reason: 'right count, wrong members — size alone must not pass it',
      );
    });
  });

  group('choice marks after submit', () {
    test('a picked correct choice reads as correct', () {
      expect(
        markFor(index: 0, selected: {0, 2}, isCorrect: correct),
        MultiMark.correct,
      );
    });

    test('a picked wrong choice reads as incorrect', () {
      expect(
        markFor(index: 1, selected: {0, 1}, isCorrect: correct),
        MultiMark.incorrect,
      );
    });

    test('an unpicked correct choice reads as missed', () {
      expect(
        markFor(index: 4, selected: {0, 2}, isCorrect: correct),
        MultiMark.missed,
        reason: 'the learner must see what they should have picked',
      );
    });

    test('an unpicked wrong choice is left unmarked', () {
      expect(
        markFor(index: 3, selected: {0, 2}, isCorrect: correct),
        MultiMark.none,
      );
    });
  });
}
