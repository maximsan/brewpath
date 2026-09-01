import 'package:brew_path/features/dictionary/domain/flashcard_deck.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:flutter_test/flutter_test.dart';

/// A term with only the fields the deck rules read.
DictionaryTerm _term(String id, {String? lesson}) => DictionaryTerm(
  id: id,
  term: id,
  categoryId: 'beans',
  shortExplanation: 'short',
  lessonId: lesson,
);

/// The saved keys for [ids], written through the key grammar rather than
/// spelled here — a test that hardcodes `t:` stops testing the real deck.
Set<String> _saved(List<String> ids) => {
  for (final id in ids) formatSavedKey(SavedKind.term, id),
};

final List<DictionaryTerm> _bank = [
  _term('cherry', lesson: 'm1l1'),
  _term('gesha', lesson: 'm4l2'),
  _term('tds'),
  _term('bloom', lesson: 'm1l2'),
];

void main() {
  group('what a learner can reach', () {
    test('Plus reaches every term, reference ones included', () {
      final reach = accessibleTermIds(
        _bank,
        completedLessonIds: const {},
        isPlus: true,
      );

      expect(reach, {'cherry', 'gesha', 'tds', 'bloom'});
    });

    test('free reaches only what its lessons have taught', () {
      final reach = accessibleTermIds(
        _bank,
        completedLessonIds: const {'m1l1'},
        isPlus: false,
      );

      expect(
        reach,
        {'cherry'},
        reason:
            'gesha and bloom are still ahead, and no lesson teaches tds at all',
      );
    });

    test('a reference term is out of reach for free however much is done', () {
      final reach = accessibleTermIds(
        _bank,
        completedLessonIds: const {'m1l1', 'm1l2', 'm4l2'},
        isPlus: false,
      );

      expect(
        reach.contains('tds'),
        isFalse,
        reason: 'no lesson teaches it, so no amount of finishing reaches it',
      );
    });
  });

  group('the deck', () {
    test('is the intersection, and nothing falls back into it', () {
      final deck = deriveFlashcardDeck(
        savedKeys: _saved(['cherry', 'gesha']),
        accessibleIds: const {'cherry', 'tds', 'bloom'},
        terms: _bank,
      );

      expect(
        deck.map((term) => term.id),
        ['cherry'],
        reason:
            'gesha is saved but out of reach; tds and bloom are in reach but '
            'were never saved — an accessible term is not a fallback card',
      );
    });

    test('deals in bank order, not in the order the keys arrived', () {
      final deck = deriveFlashcardDeck(
        savedKeys: _saved(['bloom', 'cherry']),
        accessibleIds: const {'cherry', 'bloom'},
        terms: _bank,
      );

      expect(deck.map((term) => term.id), ['cherry', 'bloom']);
    });

    test('a saved id the bank no longer carries is skipped, not broken', () {
      final deck = deriveFlashcardDeck(
        savedKeys: _saved(['cherry', 'retired-term']),
        accessibleIds: const {'cherry', 'retired-term'},
        terms: _bank,
      );

      expect(deck.map((term) => term.id), ['cherry']);
    });

    test('a saved key of another kind never deals a term', () {
      final deck = deriveFlashcardDeck(
        // A lesson keyed with the same id as a term: the prefix is the only
        // thing keeping these apart, which is why the deck asks for the whole
        // key rather than for the id.
        savedKeys: {formatSavedKey(SavedKind.lesson, 'cherry')},
        accessibleIds: const {'cherry'},
        terms: _bank,
      );

      expect(deck, isEmpty);
    });

    test('nothing saved is an empty deck, never a substitute one', () {
      expect(
        deriveFlashcardDeck(
          savedKeys: const {},
          accessibleIds: const {'cherry', 'gesha', 'tds', 'bloom'},
          terms: _bank,
        ),
        isEmpty,
      );
    });
  });

  group('the deal', () {
    test('is every card exactly once', () {
      final deal = flashcardDeal(4, nonce: 7);

      expect(deal.toSet(), {0, 1, 2, 3});
    });

    test('the same nonce deals the same order', () {
      expect(flashcardDeal(6, nonce: 99), flashcardDeal(6, nonce: 99));
    });

    test('an empty deck deals nothing rather than throwing', () {
      expect(flashcardDeal(0, nonce: 1), isEmpty);
    });
  });

  group('the deck shrinking under an open round', () {
    test('keeps the shuffle when what survives still covers the deck', () {
      // Five cards dealt, then one un-saved: index 4 is past the end now.
      final reconciled = reconcileFlashcardOrder([3, 1, 4, 0, 2], 4);

      expect(reconciled, [3, 1, 0, 2]);
      expect(
        reconciled.toSet(),
        {0, 1, 2, 3},
        reason: 'still every card of the smaller deck, exactly once',
      );
    });

    test('re-deals in order when the deck grew', () {
      expect(reconcileFlashcardOrder([1, 0], 4), [0, 1, 2, 3]);
    });

    test('an emptied deck reconciles to nothing', () {
      expect(reconcileFlashcardOrder([2, 0, 1], 0), isEmpty);
    });

    test('a valid deal is left exactly as it was', () {
      expect(reconcileFlashcardOrder([2, 0, 1], 3), [2, 0, 1]);
    });

    test(
      'every prefix of un-saves leaves a round that can still be walked',
      () {
        var order = flashcardDeal(8, nonce: 42);

        // Un-save one card at a time, all the way down: at no size may the deal
        // hold an index the deck cannot answer for.
        for (var size = 8; size >= 0; size--) {
          order = reconcileFlashcardOrder(order, size);

          expect(order, hasLength(size));
          expect(
            order.toSet(),
            List<int>.generate(size, (index) => index).toSet(),
            reason: 'the deal must stay a permutation of a $size-card deck',
          );
        }
      },
    );
  });
}
