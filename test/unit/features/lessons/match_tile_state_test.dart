import 'package:brew_path/features/lessons/presentation/cards/card_tints.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_standing.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_tile_state.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter_test/flutter_test.dart';

const MoodColors _mood = MoodColors.darkRoast;

MatchBoardStanding _standing({
  Set<int> placed = const {},
  Set<String> linked = const {},
  int? selected,
  MatchMiss? miss,
}) => MatchBoardStanding(
  placed: placed,
  linked: linked,
  selected: selected,
  dragging: null,
  miss: miss,
  cleared: false,
  snapTarget: null,
  snapTick: 0,
  shakeTick: 0,
);

void main() {
  group('what the design paints', () {
    test('an unmarked tile takes the plain rule, and no wash', () {
      expect(MatchTileState.plain.border(_mood), _mood.rule);
      expect(MatchTileState.plain.fill(_mood), isNull);
    });

    test('both accent states double the outline, and nothing else does', () {
      for (final state in MatchTileState.values) {
        expect(
          state.isDoubled,
          state == MatchTileState.held || state == MatchTileState.hot,
          reason: '$state',
        );
      }
    });

    test('a landed trait washes sage, a linked answer does not', () {
      expect(MatchTileState.matched.border(_mood), _mood.sage);
      expect(
        MatchTileState.matched.fill(_mood),
        _mood.sage.withValues(alpha: CardTints.wash),
      );

      expect(MatchTileState.linked.border(_mood), _mood.sage);
      expect(
        MatchTileState.linked.fill(_mood),
        isNull,
        reason:
            'several traits fan into one answer, which would otherwise '
            'darken as the board fills',
      );
    });

    test('a wrong tile washes lighter than a right one', () {
      expect(MatchTileState.wrong.border(_mood), _mood.berry);
      expect(
        matchWrongWash,
        lessThan(CardTints.wash),
        reason: 'the design puts 8% behind a miss against 12% behind an answer',
      );
    });

    test('only the answer under a held trait swells', () {
      for (final state in MatchTileState.values) {
        expect(state.swells, state == MatchTileState.hot, reason: '$state');
        expect(
          state.restingScale,
          state == MatchTileState.hot ? greaterThan(1) : 1,
          reason: '$state',
        );
      }
    });
  });

  group('how the board reads a trait', () {
    test('it is plain until it is picked up', () {
      expect(_standing().traitState(0), MatchTileState.plain);
    });

    test('the one tapped is held', () {
      expect(_standing(selected: 0).traitState(0), MatchTileState.held);
      expect(_standing(selected: 0).traitState(1), MatchTileState.plain);
    });

    test('one that landed is matched', () {
      expect(_standing(placed: {0}).traitState(0), MatchTileState.matched);
    });

    test('a miss outranks everything, so a bad drop is never read as held', () {
      final standing = _standing(
        selected: 0,
        miss: (fact: 0, target: 'Robusta'),
      );

      expect(standing.traitState(0), MatchTileState.wrong);
    });
  });

  group('how the board reads an answer', () {
    test('it is plain with nothing on it and nothing over it', () {
      expect(
        _standing().answerState('Arabica', hot: false),
        MatchTileState.plain,
      );
    });

    test('a trait held over it makes it hot, landed or not', () {
      expect(
        _standing().answerState('Arabica', hot: true),
        MatchTileState.hot,
      );
      expect(
        _standing(linked: {'Arabica'}).answerState('Arabica', hot: true),
        MatchTileState.hot,
        reason: 'an answer already linked still takes another trait',
      );
    });

    test('one with a trait on it is linked', () {
      expect(
        _standing(linked: {'Arabica'}).answerState('Arabica', hot: false),
        MatchTileState.linked,
      );
    });

    test('a miss outranks a hold, so the bad drop is what is shown', () {
      final standing = _standing(miss: (fact: 0, target: 'Robusta'));

      expect(
        standing.answerState('Robusta', hot: true),
        MatchTileState.wrong,
      );
    });
  });
}
