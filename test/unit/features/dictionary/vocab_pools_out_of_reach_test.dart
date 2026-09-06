// When the drill should say "you saved terms, and none of them are yours to
// practise" rather than the design's "bookmark some" (#468).
import 'package:brew_path/features/dictionary/domain/vocab_providers.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:flutter_test/flutter_test.dart';

const _term = DictionaryTerm(
  id: 'arabica',
  term: 'Arabica',
  categoryId: 'beans',
  shortExplanation: 'The species behind most specialty coffee.',
);

VocabPools _pools({
  required int savedEligible,
  required bool hasCourse,
  List<DictionaryTerm> saved = const [],
}) => VocabPools(
  accessible: const [_term],
  saved: saved,
  missed: const [],
  savedEligible: savedEligible,
  hasCourse: hasCourse,
);

void main() {
  test('saved terms none of which can be drilled', () {
    expect(
      _pools(savedEligible: 1, hasCourse: false).savedIsOutOfReach,
      isTrue,
    );
  });

  test("nothing saved is the design's own empty state, not this one", () {
    expect(
      _pools(savedEligible: 0, hasCourse: false).savedIsOutOfReach,
      isFalse,
    );
  });

  test('a deck with cards in it is not an empty state at all', () {
    expect(
      _pools(
        savedEligible: 2,
        hasCourse: false,
        saved: const [_term],
      ).savedIsOutOfReach,
      isFalse,
      reason: 'one reachable save is a deck; the rest are simply not dealt',
    );
  });

  test('someone who owns the course never reads the free-lessons line', () {
    // Unreachable today — every shipped term carries the explanation a drill
    // needs — but a term authored without one would land a paid learner here,
    // and the copy would be false for them.
    expect(
      _pools(savedEligible: 1, hasCourse: true).savedIsOutOfReach,
      isFalse,
    );
  });

  test('a bookmark no drill could ask about does not raise the line', () {
    // The copy says the full course would put the saved terms in reach. A
    // bookmark on a term the bank dropped, or one authored without the short
    // explanation a question needs, is not reachable at any tier — so it is
    // not counted, and the learner is not promised something buying cannot
    // deliver.
    expect(
      _pools(savedEligible: 0, hasCourse: false).savedIsOutOfReach,
      isFalse,
    );
  });
}
