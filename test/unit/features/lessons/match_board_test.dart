import 'package:brew_path/features/lessons/presentation/cards/match_board.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:flutter_test/flutter_test.dart';

const _pairs = [
  MatchPair(left: 'Sweeter, more aromatic', right: 'Arabica'),
  MatchPair(left: 'Almost twice the caffeine', right: 'Robusta'),
  MatchPair(left: 'Grown 900–2000m', right: 'Arabica'),
  MatchPair(left: 'Tolerates heat', right: 'Robusta'),
];

void main() {
  group('matchTargets', () {
    test('collapses the pairs to their distinct answers', () {
      expect(matchTargets(_pairs), ['Arabica', 'Robusta']);
    });

    test('keeps first-appearance order, so the seed alone decides display', () {
      const reversed = [
        MatchPair(left: 'a', right: 'Robusta'),
        MatchPair(left: 'b', right: 'Arabica'),
      ];

      expect(matchTargets(reversed), ['Robusta', 'Arabica']);
    });

    test('an empty board has no targets', () {
      expect(matchTargets(const []), isEmpty);
    });
  });

  group('matchBoardCleared', () {
    test('is cleared only once every pair is placed', () {
      expect(matchBoardCleared(solvedCount: 3, total: 4), isFalse);
      expect(matchBoardCleared(solvedCount: 4, total: 4), isTrue);
    });

    test('an empty board is not a cleared board', () {
      expect(matchBoardCleared(solvedCount: 0, total: 0), isFalse);
    });
  });

  group('matchBoardPaysSignal', () {
    test('a clean sweep pays', () {
      expect(matchBoardPaysSignal(cleared: true, faulted: false), isTrue);
    });

    // The rule this card exists to enforce: one wrong drop and the board is
    // worth nothing, however it finishes.
    test('a board finished after a wrong drop pays nothing', () {
      expect(matchBoardPaysSignal(cleared: true, faulted: true), isFalse);
    });

    test('an unfinished board pays nothing either way', () {
      expect(matchBoardPaysSignal(cleared: false, faulted: false), isFalse);
      expect(matchBoardPaysSignal(cleared: false, faulted: true), isFalse);
    });
  });

  group('matchAccepts', () {
    test('accepts the target the pair names', () {
      expect(matchAccepts(_pairs[0], 'Arabica'), isTrue);
    });

    test('rejects any other target', () {
      expect(matchAccepts(_pairs[0], 'Robusta'), isFalse);
    });
  });
}
