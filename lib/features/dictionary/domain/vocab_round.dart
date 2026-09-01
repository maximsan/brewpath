/// One drill of *Guess the term*: the rounds it plays, decided from a seed.
///
/// A pure function of (pool, distractor source, length, seed), so the ticket's
/// invariant is assertable without pumping a widget: every round has exactly
/// one correct answer, no distractor repeats it, and the same seed replays the
/// same drill.
///
/// Every shuffle is the app's seeded Fisher–Yates. The prototype's
/// `sort(() => Math.random() - 0.5)` is a recorded defect (#66), and a biased
/// shuffle is worst in the one surface whose whole job is variety.
library;

import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';

/// How many options a question offers, the answer included.
const int vocabChoiceCount = 4;

/// How many wrong answers come from the answer's own category before the rest
/// come from elsewhere.
///
/// Four words from four unrelated subjects is a reading test; four from one
/// category is a trick. Two and one is the design's split.
const int vocabSameCategoryDistractors = 2;

/// One question: a definition, four term names, and exactly one right one.
class VocabRound {
  /// Creates a [VocabRound].
  const VocabRound({required this.answer, required this.choices});

  /// The term being asked about. Its short explanation is the question.
  final DictionaryTerm answer;

  /// The options as displayed, already in their shuffled order.
  final List<DictionaryTerm> choices;

  /// Where [answer] sits among [choices].
  int get answerIndex => choices.indexWhere((choice) => choice.id == answer.id);

  /// Whether the choice at [index] is the right one.
  bool isCorrect(int index) => index == answerIndex;
}

/// The terms a drill can ask about: those carrying an explanation to ask with.
///
/// The authored self-checks stay on term detail — a drill mixing generated
/// rounds with authored ones would be two games wearing one name.
List<DictionaryTerm> vocabEligible(List<DictionaryTerm> terms) => [
  for (final term in terms)
    if (term.shortExplanation.trim().isNotEmpty) term,
];

/// The rounds a drill plays, in order.
///
/// [pool] is what may be *asked*; [distractorSource] what may be *offered* as
/// a wrong answer. The Saved deck asks about bookmarks while drawing wrong
/// answers from everything the tier reaches, and both must be tier-scoped by
/// the caller — scoping only one is the leak #57 named.
///
/// Shorter than [length] when the pool cannot fill it, never padded.
List<VocabRound> buildVocabRounds({
  required List<DictionaryTerm> pool,
  required List<DictionaryTerm> distractorSource,
  required int length,
  required int seed,
}) {
  final asked = shuffledBySeed(pool, seed).take(length).toList();

  return [
    for (var index = 0; index < asked.length; index++)
      _round(
        answer: asked[index],
        source: distractorSource,
        seed: cardSeed(nonce: seed, cardIndex: index),
      ),
  ];
}

/// One round: the wrong answers drawn, then the four options ordered.
VocabRound _round({
  required DictionaryTerm answer,
  required List<DictionaryTerm> source,
  required int seed,
}) {
  final distractors = _distractorsFor(
    answer: answer,
    source: source,
    seed: seed,
  );
  return VocabRound(
    answer: answer,
    // The answer's own position is drawn from a seed of its own, so a learner
    // cannot learn to expect it anywhere.
    choices: shuffledBySeed([...distractors, answer], derivedSeed(seed)),
  );
}

/// The wrong answers for [answer]: two from its category, then one from
/// elsewhere.
///
/// The shortfall on either side is taken from the other, so the round keeps
/// four options wherever four terms exist. The prototype slices both lists and
/// stops, leaving a three-option question when one category holds the pool.
List<DictionaryTerm> _distractorsFor({
  required DictionaryTerm answer,
  required List<DictionaryTerm> source,
  required int seed,
}) {
  final others = [
    for (final term in source)
      if (term.id != answer.id) term,
  ];
  final sameCategory = shuffledBySeed([
    for (final term in others)
      if (term.categoryId == answer.categoryId) term,
  ], seed);
  final elsewhere = shuffledBySeed([
    for (final term in others)
      if (term.categoryId != answer.categoryId) term,
  ], derivedSeed(seed));

  const wanted = vocabChoiceCount - 1;
  return [
    ...sameCategory.take(vocabSameCategoryDistractors),
    ...elsewhere,
    // Only reached when there was no "elsewhere" to prefer.
    ...sameCategory.skip(vocabSameCategoryDistractors),
  ].take(wanted).toList();
}

/// Mints the seed for one drill. Re-minted by Play again and stored nowhere:
/// a stored seed would re-fix the answer positions across replays.
int mintVocabSeed() => mintLessonNonce();
