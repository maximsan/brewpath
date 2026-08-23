import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_run.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rounds = ['a', 'b', 'c', 'd', 'e', 'f'];

  group('roundsForRun', () {
    test('plays every round exactly once', () {
      final played = roundsForRun(rounds, 12345);

      expect(played, hasLength(rounds.length));
      expect(played.toSet(), rounds.toSet());
    });

    test('is reproducible from the nonce alone', () {
      expect(roundsForRun(rounds, 999), roundsForRun(rounds, 999));
    });

    test('a fresh run draws a different order', () {
      // Two nonces that must not agree; the point of re-minting on Play again.
      expect(roundsForRun(rounds, 1), isNot(roundsForRun(rounds, 2)));
    });

    test('an empty bank yields an empty run rather than throwing', () {
      expect(roundsForRun(const <String>[], 7), isEmpty);
    });
  });

  group('isCelebratoryRun', () {
    test('four in five is celebratory — the mark itself counts', () {
      expect(isCelebratoryRun(score: 4, total: 5), isTrue);
    });

    test('below the mark is ordinary', () {
      expect(isCelebratoryRun(score: 3, total: 5), isFalse);
    });

    test('a perfect run celebrates', () {
      expect(isCelebratoryRun(score: 6, total: 6), isTrue);
    });

    test('a scoreless run is ordinary', () {
      expect(isCelebratoryRun(score: 0, total: 6), isFalse);
    });

    test(
      'a run with no rounds never celebrates, and never divides by zero',
      () {
        expect(isCelebratoryRun(score: 0, total: 0), isFalse);
      },
    );
  });

  group('runEncouragement', () {
    test('every band has words, and the bands differ', () {
      final lines = {
        runEncouragement(score: 6, total: 6),
        runEncouragement(score: 5, total: 6),
        runEncouragement(score: 3, total: 6),
        runEncouragement(score: 0, total: 6),
      };

      expect(lines, hasLength(4));
      expect(lines.every((line) => line.isNotEmpty), isTrue);
    });
  });

  // The quiz renders True/False through the same seeded shuffle every card
  // uses, so the pair is pinned here as the player composes it — no widget
  // pumped, per the ticket's "proved by pure-function tests".
  group('choice order within a run', () {
    const pair = ['True', 'False'];
    List<String> choicesFor(int nonce, int round) =>
        shuffledBySeed(pair, cardSeed(nonce: nonce, cardIndex: round));

    test('the same round of the same run repeats its order', () {
      expect(choicesFor(4242, 3), choicesFor(4242, 3));
    });

    test('both options always survive the shuffle', () {
      for (var round = 0; round < 6; round++) {
        expect(choicesFor(99, round).toSet(), pair.toSet());
      }
    });

    test('a fresh run reshuffles: some round moves', () {
      final before = [for (var i = 0; i < 6; i++) choicesFor(1, i)];
      final after = [for (var i = 0; i < 6; i++) choicesFor(2, i)];

      expect(before, isNot(after));
    });
  });

  group('playableMiniGameIds', () {
    test('the free pair plays', () {
      // Two different games make a streak day, so this pair is load-bearing.
      expect(playableMiniGameIds, containsAll(['g-quiz', 'g-match']));
    });

    test('a kind with no renderer yet does not play', () {
      // Retargeted: this named `g-bagpick` until its renderer landed. The two
      // kinds still waiting are `slider` and `sequence`, and naming one of
      // their games keeps the assertion about *a game that cannot be drawn*
      // rather than about whichever game happened to be unfinished.
      //
      // The general rule — anything that renders is playable or says why not —
      // belongs to `mini_game_playable_test.dart`, which checks it against the
      // real banks rather than against a name written here.
      expect(playableMiniGameIds, isNot(contains('g-calibrate')));
      expect(playableMiniGameIds, isNot(contains('g-sequence')));
    });
  });
}
