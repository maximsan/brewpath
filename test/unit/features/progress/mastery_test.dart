import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:flutter_test/flutter_test.dart';

MasteryResult _r(int correct, int total) =>
    MasteryResult(correct: correct, total: total);

void main() {
  group('band', () {
    test('a clean run is perfect', () {
      expect(_r(5, 5).band, MasteryBand.perfect);
    });

    test('exactly one wrong is Solid', () {
      expect(_r(4, 5).band, MasteryBand.mastered);
    });

    test('two or more wrong needs practice', () {
      expect(_r(3, 5).band, MasteryBand.needsPractice);
      expect(_r(0, 5).band, MasteryBand.needsPractice);
    });

    test('an unscored result claims no band at all', () {
      expect(MasteryResult.unscored.band, isNull);
      expect(_r(0, 0).band, isNull);
    });
  });

  group('every graded count has a reachable Solid band', () {
    // The regression that motivated banding on wrong answers: under
    // MASTERY_PASS = 0.8, graded counts of 3 and 4 have no reachable 80–99%
    // score, so 14 of 31 lessons could never be Solid — one mistake dropped
    // the learner from Perfect straight to Needs Practice.
    for (final total in const [3, 4, 5, 6, 7]) {
      test('$total graded cards', () {
        expect(_r(total, total).band, MasteryBand.perfect);
        expect(_r(total - 1, total).band, MasteryBand.mastered);
        expect(_r(total - 2, total).band, MasteryBand.needsPractice);
      });
    }
  });

  group('ratio', () {
    test('is the completed fraction', () {
      expect(_r(4, 5).ratio, 0.8);
      expect(_r(5, 5).ratio, 1.0);
    });

    test('is zero for an unscored result rather than dividing by zero', () {
      expect(MasteryResult.unscored.ratio, 0);
    });
  });

  group('isScored', () {
    test('a stored pair is scored', () {
      expect(_r(0, 3).isScored, isTrue);
    });

    test('a lesson with no stored result is not', () {
      // Renders as the deliberately neutral empty node, never a full one.
      expect(MasteryResult.unscored.isScored, isFalse);
    });
  });

  group('construction is total', () {
    test('correct cannot exceed total', () {
      expect(_r(9, 5).correct, 5);
    });

    test('negatives floor at zero', () {
      expect(_r(-3, 5).correct, 0);
      expect(_r(0, -1).total, 0);
    });
  });

  group('best — never downgrade', () {
    test('prefers the higher band even when its ratio is lower', () {
      // 90% with two wrong loses to 80% with one wrong: ratio alone would
      // pick the worse badge across different denominators.
      final twoWrongHighRatio = _r(18, 20);
      final oneWrongLowRatio = _r(4, 5);

      expect(twoWrongHighRatio.ratio, greaterThan(oneWrongLowRatio.ratio));
      expect(
        MasteryResult.best(twoWrongHighRatio, oneWrongLowRatio),
        oneWrongLowRatio,
      );
    });

    test('falls back to ratio within one band', () {
      expect(MasteryResult.best(_r(6, 7), _r(4, 5)), _r(6, 7));
    });

    test('any scored result beats an unscored one', () {
      expect(MasteryResult.best(MasteryResult.unscored, _r(0, 5)), _r(0, 5));
      expect(MasteryResult.best(_r(0, 5), MasteryResult.unscored), _r(0, 5));
    });

    test('is order-independent', () {
      final a = _r(18, 20);
      final b = _r(4, 5);
      expect(MasteryResult.best(a, b), MasteryResult.best(b, a));
    });

    test('two unscored results stay unscored', () {
      expect(
        MasteryResult.best(
          MasteryResult.unscored,
          MasteryResult.unscored,
        ).isScored,
        isFalse,
      );
    });
  });
}
