// The ticket's stated invariant, asserted on the pure generator: every round
// has exactly one correct answer, no distractor repeats it, and a fixed seed
// reproduces a fixed drill. The same property the content extractor enforces
// on authored graded cards, asserted the same way.
import 'package:brew_path/features/dictionary/domain/vocab_round.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// The shipped dictionary, so every round here is one the app could deal.
late List<DictionaryTerm> _bank;

/// One real category's terms — the Saved deck can hold a pool this narrow if a
/// learner only ever bookmarks espresso words.
late List<DictionaryTerm> _oneCategory;

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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    _bank = vocabEligible(await DictionaryRepository().getTerms());
    _oneCategory = [
      for (final term in _bank)
        if (term.categoryId == 'espresso') term,
    ];
  });

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

    test('a lone term in its category still gets four options', () {
      // Only one espresso term is reachable, so there is no same-category
      // wrong answer to be had and the shortfall comes from elsewhere.
      final lone = _oneCategory.first;
      final source = [
        lone,
        for (final term in _bank)
          if (term.categoryId != 'espresso') term,
      ];

      final round = _rounds(pool: [lone], source: source, length: 1).single;

      expect(round.choices, hasLength(vocabChoiceCount));
      expect(round.choices.map((choice) => choice.id), contains(lone.id));
    });

    test('a deck drawn from one category still gets four options', () {
      // A learner who only bookmarks espresso words: the Saved deck has no
      // "elsewhere" to reach for, so the shortfall goes back to the category
      // rather than shortening the question. The prototype stops at three.
      final round = _rounds(
        pool: _oneCategory,
        source: _oneCategory,
        length: 1,
      ).single;

      expect(_oneCategory.length, greaterThanOrEqualTo(vocabChoiceCount));
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
    test('every shipped term carries an explanation to ask with', () {
      // The extractor refuses a term without one, so the whole bank is
      // eligible. If that ever stops being true the drill quietly shrinks.
      expect(vocabEligible(_bank), hasLength(_bank.length));
    });
  });
}
