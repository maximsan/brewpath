// The rules that decide whether a drill can be offered at all. They have to
// give the setup screen and the start action the same answers, or Start runs a
// deck the screen greyed.
import 'package:brew_path/features/dictionary/domain/vocab_setup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the lengths a pool can fill', () {
    test('a full pool is offered all three', () {
      expect(vocabLengthsFor(20), vocabLengths);
    });

    test('a pool offers only the lengths it can honestly fill', () {
      expect(vocabLengthsFor(8), [5, 8]);
      expect(vocabLengthsFor(7), [5]);
    });

    test('a pool below the shortest round is offered none', () {
      expect(vocabLengthsFor(vocabMinimumPool), isEmpty);
    });
  });

  group('the deck actually in play', () {
    test('a deck with enough on it is kept', () {
      for (final deck in [VocabDeck.saved, VocabDeck.misses]) {
        expect(
          resolveVocabDeck(chosen: deck, chosenPoolSize: vocabMinimumPool),
          deck,
        );
      }
    });

    test('a deck below the minimum falls back to all', () {
      // Un-saving a term mid-session — or answering the last missed one
      // correctly — must not leave a drill the rules say cannot exist as the
      // live selection.
      for (final deck in [VocabDeck.saved, VocabDeck.misses]) {
        expect(
          resolveVocabDeck(chosen: deck, chosenPoolSize: vocabMinimumPool - 1),
          VocabDeck.all,
          reason: '$deck must not survive below the minimum',
        );
      }
    });

    test('all is never redirected, however empty the shelf is', () {
      expect(
        resolveVocabDeck(chosen: VocabDeck.all, chosenPoolSize: 0),
        VocabDeck.all,
      );
    });

    test('a deck is available at the minimum, not one above it', () {
      expect(vocabDeckAvailable(vocabMinimumPool), isTrue);
      expect(vocabDeckAvailable(vocabMinimumPool - 1), isFalse);
    });
  });

  group('the length actually played', () {
    test('a length the pool can fill is kept', () {
      expect(resolveVocabLength(chosen: 8, poolSize: 20), 8);
    });

    test('a length the pool cannot fill drops to the longest that fits', () {
      expect(resolveVocabLength(chosen: 12, poolSize: 9), 8);
    });

    test('a pool below the shortest round plays the whole deck', () {
      expect(resolveVocabLength(chosen: 5, poolSize: 4), 4);
    });

    test('the length never exceeds the pool, so no term is asked twice', () {
      for (var size = 1; size < 20; size++) {
        for (final chosen in vocabLengths) {
          expect(
            resolveVocabLength(chosen: chosen, poolSize: size),
            lessThanOrEqualTo(size),
          );
        }
      }
    });
  });
}
