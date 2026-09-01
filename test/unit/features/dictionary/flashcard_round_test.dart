import 'package:brew_path/features/dictionary/domain/flashcard_round.dart';
import 'package:flutter_test/flutter_test.dart';

/// A round with a known deal, so a move can be asserted against a position
/// rather than against whatever a nonce happened to shuffle.
FlashcardRound _round(
  List<int> order, {
  int position = 0,
  bool isRevealed = false,
  bool isFinished = false,
}) => FlashcardRound(
  order: order,
  position: position,
  isRevealed: isRevealed,
  isFinished: isFinished,
);

void main() {
  group('a fresh deal', () {
    test('starts on the first card, face down, unfinished', () {
      final round = FlashcardRound.deal(4, nonce: 12);

      expect(round.position, 0);
      expect(round.isRevealed, isFalse);
      expect(round.isFinished, isFalse);
      expect(round.length, 4);
    });

    test('deals every card exactly once', () {
      expect(FlashcardRound.deal(5, nonce: 3).order.toSet(), {0, 1, 2, 3, 4});
    });
  });

  group('turning the card', () {
    test('flips it, and flips it back', () {
      final front = _round([0, 1]);

      expect(front.flipped().isRevealed, isTrue);
      expect(front.flipped().flipped().isRevealed, isFalse);
    });

    test('does not move through the deck', () {
      final round = _round([2, 0, 1], position: 1).flipped();

      expect(round.position, 1);
      expect(round.card, 0);
    });
  });

  group('walking the deck', () {
    test('the next card comes up face down', () {
      final round = _round([0, 1, 2], isRevealed: true).forward();

      expect(round.position, 1);
      expect(
        round.isRevealed,
        isFalse,
        reason: 'a card the learner has not asked to see must not open',
      );
    });

    test('the previous card does too', () {
      final round = _round([0, 1, 2], position: 2, isRevealed: true).back();

      expect(round.position, 1);
      expect(round.isRevealed, isFalse);
    });

    test('there is nothing before the first card', () {
      final first = _round([0, 1, 2]);

      expect(first.isOnFirst, isTrue);
      expect(first.back().position, 0);
    });

    test('stepping on from the last card finishes the review', () {
      final last = _round([0, 1], position: 1);

      expect(last.isOnLast, isTrue);
      expect(last.forward().isFinished, isTrue);
    });

    test('a one-card deck is already on its last card', () {
      expect(_round([0]).isOnLast, isTrue);
    });

    test('nothing steps past the finish', () {
      // The finish is reachable once per deal, which is what lets the screen
      // record a review exactly once.
      final done = _round([0, 1], position: 1).forward();

      expect(done.forward().isFinished, isTrue);
      expect(done.forward().position, 1);
    });
  });

  group('the deck moving under an open round', () {
    test('a shrunk deck leaves the learner on a card that exists', () {
      final round = _round([3, 1, 4, 0, 2], position: 4).reconciled(4);

      expect(round.order, [3, 1, 0, 2]);
      expect(
        round.position,
        lessThan(round.length),
        reason: 'a position past the end is what would throw on the next card',
      );
      expect(round.card, isNonNegative);
    });

    test('the side showing survives a reconcile', () {
      final round = _round(
        [0, 1, 2],
        position: 1,
        isRevealed: true,
      ).reconciled(2);

      expect(
        round.isRevealed,
        isTrue,
        reason: 'a card the learner is reading must not close under them',
      );
    });

    test('an emptied deck leaves a round with nothing in it', () {
      final round = _round([2, 0, 1], position: 2).reconciled(0);

      expect(round.order, isEmpty);
      expect(round.position, 0);
    });

    test('a valid round is left exactly as it was', () {
      final round = _round([2, 0, 1], position: 2, isRevealed: true);
      final same = round.reconciled(3);

      expect(same.order, round.order);
      expect(same.position, round.position);
      expect(same.isRevealed, round.isRevealed);
    });

    test('every card can still be reached after any number of un-saves', () {
      var round = FlashcardRound.deal(8, nonce: 42);

      for (var size = 8; size >= 1; size--) {
        round = round.reconciled(size);

        expect(round.length, size);
        // Walk the whole deck from wherever the reconcile left the learner.
        for (var step = 0; step < size; step++) {
          expect(round.card, lessThan(size));
          round = round.forward();
        }
        expect(round.isFinished, isTrue);
        round = FlashcardRound(
          order: round.order,
          position: 0,
          isRevealed: false,
          isFinished: false,
        );
      }
    });
  });
}
