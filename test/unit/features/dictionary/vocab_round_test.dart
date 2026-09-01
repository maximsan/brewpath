// The ticket's stated invariant, asserted on the pure generator: every round
// has exactly one correct answer, no distractor repeats it, and a fixed seed
// reproduces a fixed drill. The same property the content extractor enforces
// on authored graded cards, asserted the same way.
import 'package:brew_path/features/dictionary/domain/vocab_round.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:flutter_test/flutter_test.dart';

DictionaryTerm _term(String id, String category) => DictionaryTerm(
  id: id,
  term: 'Term $id',
  categoryId: category,
  shortExplanation: 'What $id means.',
);

/// Four categories of three, so a same-category draw always has candidates and
/// "elsewhere" is never empty.
final List<DictionaryTerm> _bank = [
  for (final category in ['beans', 'brewing', 'roasting', 'trade'])
    for (var index = 0; index < 3; index++) _term('$category$index', category),
];

const int _seed = 4242;

List<VocabRound> _rounds({
  List<DictionaryTerm>? pool,
  List<DictionaryTerm>? source,
  int length = 5,
  int seed = _seed,
}) => buildVocabRounds(
  pool: pool ?? _bank,
  distractorSource: source ?? _bank,
  length: length,
  seed: seed,
);

void main() {
  group('the invariant every round holds', () {
    test('exactly one choice is the answer', () {
      for (final round in _rounds(length: _bank.length)) {
        final correct = round.choices.where(
          (choice) => choice.id == round.answer.id,
        );

        expect(correct, hasLength(1));
        expect(round.isCorrect(round.answerIndex), isTrue);
      }
    });

    test('no distractor repeats the answer, and no choice repeats another', () {
      for (final round in _rounds(length: _bank.length)) {
        final ids = round.choices.map((choice) => choice.id).toList();

        expect(ids.toSet(), hasLength(ids.length));
      }
    });

    test('a question offers four options', () {
      for (final round in _rounds(length: _bank.length)) {
        expect(round.choices, hasLength(vocabChoiceCount));
      }
    });

    test('no term is asked about twice in one drill', () {
      final asked = _rounds(
        length: _bank.length,
      ).map((round) => round.answer.id).toList();

      expect(asked.toSet(), hasLength(asked.length));
    });
  });

  group('the drill is a function of its seed', () {
    test('the same seed reproduces the same drill, option order included', () {
      List<List<String>> shape(List<VocabRound> rounds) => [
        for (final round in rounds)
          [round.answer.id, ...round.choices.map((choice) => choice.id)],
      ];

      expect(shape(_rounds()), shape(_rounds()));
    });

    test('a fresh seed draws a different drill', () {
      // The point of re-minting on Play again.
      final first = _rounds().map((round) => round.answer.id).toList();
      final second = _rounds(
        seed: _seed + 1,
      ).map((round) => round.answer.id).toList();

      expect(first, isNot(second));
    });

    test('the answer does not sit in one position every round', () {
      final positions = _rounds(
        length: _bank.length,
      ).map((round) => round.answerIndex).toSet();

      expect(
        positions.length,
        greaterThan(1),
        reason: 'a fixed answer position is learnable without knowing the word',
      );
    });
  });

  group('distractor preference', () {
    test("two of the three come from the answer's own category", () {
      for (final round in _rounds(length: _bank.length)) {
        final sameCategory = round.choices.where(
          (choice) =>
              choice.id != round.answer.id &&
              choice.categoryId == round.answer.categoryId,
        );

        expect(sameCategory, hasLength(vocabSameCategoryDistractors));
      }
    });

    test('a thin category degrades to wrong answers from elsewhere', () {
      // One term in its own category: there is no same-category distractor to
      // be had, and the round must still offer four honest options.
      final lonely = _term('lonely', 'sensory');
      final source = [..._bank, lonely];

      final round = _rounds(pool: [lonely], source: source, length: 1).single;

      expect(round.choices, hasLength(vocabChoiceCount));
      expect(round.choices.map((choice) => choice.id), contains(lonely.id));
    });

    test('a single-category pool degrades back to that category', () {
      // Nowhere "else" to draw from, so the shortfall returns to the category
      // rather than shortening the question — the prototype stops at three.
      final beans = [
        for (final term in _bank)
          if (term.categoryId == 'beans') term,
      ];
      final source = [...beans, _term('beans3', 'beans')];

      final round = _rounds(pool: source, source: source, length: 1).single;

      expect(round.choices, hasLength(vocabChoiceCount));
    });
  });

  group('what the pool can honestly fill', () {
    test('a pool shorter than the length runs short rather than repeating', () {
      final pool = _bank.take(3).toList();

      final rounds = _rounds(pool: pool, length: 12);

      expect(rounds, hasLength(pool.length));
    });

    test('an empty pool deals nothing rather than throwing', () {
      expect(_rounds(pool: const []), isEmpty);
    });
  });

  group('eligibility', () {
    test('a term with no explanation cannot be asked about', () {
      const blank = DictionaryTerm(
        id: 'blank',
        term: 'Blank',
        categoryId: 'beans',
        shortExplanation: '   ',
      );

      expect(vocabEligible([..._bank, blank]), isNot(contains(blank)));
      expect(vocabEligible(_bank), hasLength(_bank.length));
    });
  });
}
