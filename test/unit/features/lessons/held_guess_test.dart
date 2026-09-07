import 'package:brew_path/features/lessons/domain/held_guess.dart';
import 'package:brew_path/features/lessons/presentation/cards/recall_payoff.dart';
import 'package:flutter_test/flutter_test.dart';

// The guess is compared by string, because that is what the predict card takes
// and what the bank authors: every predict card's `a` is one of its `options`.
void main() {
  group('a held guess', () {
    test('landed when the pick is the authored answer', () {
      expect(
        const HeldGuess(pick: 'Seed', answer: 'Seed').wasRight,
        isTrue,
      );
    });

    test('missed when it is anything else', () {
      expect(
        const HeldGuess(pick: 'Skin', answer: 'Seed').wasRight,
        isFalse,
      );
    });

    test('two guesses of the same pair are the same guess', () {
      expect(
        const HeldGuess(pick: 'Skin', answer: 'Seed'),
        const HeldGuess(pick: 'Skin', answer: 'Seed'),
      );
    });
  });

  group('the spoken payoff', () {
    test('names the guess once when it landed', () {
      expect(
        spokenPayoff(const HeldGuess(pick: 'Seed', answer: 'Seed')),
        'Before the lesson you guessed Seed — and you were right.',
      );
    });

    test('names the guess and then the answer when it missed', () {
      expect(
        spokenPayoff(const HeldGuess(pick: 'Skin', answer: 'Seed')),
        "Before the lesson you guessed Skin. It's Seed — now you know why.",
      );
    });

    test('says nothing a chip would have to carry', () {
      // The flat reading is what a screen reader gets, so both words have to
      // be in it: a `WidgetSpan` announces nothing at all.
      final spoken = spokenPayoff(
        const HeldGuess(pick: 'Skin', answer: 'Seed'),
      );

      expect(spoken, contains('Skin'));
      expect(spoken, contains('Seed'));
    });
  });
}
