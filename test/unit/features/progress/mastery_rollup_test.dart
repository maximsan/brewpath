import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/mastery_rollup.dart';
import 'package:flutter_test/flutter_test.dart';

/// A clean run — no wrong answers, so [MasteryBand.perfect].
MasteryResult _perfect() => const MasteryResult(correct: 5, total: 5);

/// One wrong — [MasteryBand.mastered], which the design calls "Solid".
MasteryResult _solid() => const MasteryResult(correct: 4, total: 5);

/// Two wrong — [MasteryBand.needsPractice].
MasteryResult _weak() => const MasteryResult(correct: 3, total: 5);

void main() {
  group('the rollup folds bands into the design’s two states', () {
    test('a perfect run and a solid one both count as solid', () {
      final rollup = rollUpMastery([_perfect(), _solid()]);

      expect(
        rollup.solid,
        2,
        reason:
            'the design shows two states, so Perfect is not a third column — '
            'it is the best kind of solid',
      );
      expect(rollup.needsPractice, 0);
      expect(rollup.scored, 2);
    });

    test('two or more wrong is the only thing that needs practice', () {
      final rollup = rollUpMastery([_perfect(), _weak(), _weak()]);

      expect(rollup.needsPractice, 2);
      expect(rollup.solid, 1);
    });

    test('an unscored lesson counts toward neither band', () {
      final rollup = rollUpMastery([
        _solid(),
        MasteryResult.unscored,
        MasteryResult.unscored,
      ]);

      expect(rollup.scored, 1, reason: 'only a stored score can claim a band');
      expect(rollup.solid, 1);
      expect(rollup.needsPractice, 0);
    });

    test('nothing played rolls up to nothing', () {
      final rollup = rollUpMastery(const []);

      expect(rollup.scored, 0);
      expect(rollup.solid, 0);
      expect(rollup.needsPractice, 0);
    });

    test('the two bands always account for every scored lesson', () {
      final rollup = rollUpMastery([
        _perfect(),
        _solid(),
        _weak(),
        MasteryResult.unscored,
      ]);

      expect(rollup.solid + rollup.needsPractice, rollup.scored);
    });
  });

  group('the bar’s segments', () {
    test('leave the unplayed remainder empty', () {
      final rollup = rollUpMastery([_solid(), _weak()]);

      expect(rollup.remainderOf(10), 8);
    });

    test('never go negative when the total is behind the played count', () {
      final rollup = rollUpMastery([_solid(), _weak()]);

      expect(
        rollup.remainderOf(1),
        0,
        reason:
            'a bank edited between runs can leave more played than the course '
            'declares; a negative flex would throw in the layout',
      );
    });
  });
}
