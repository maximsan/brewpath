/// One drill of *Guess the term*: the rounds it plays, decided from a seed.
///
/// Everything here is pure. A drill writes nothing but the fact that it
/// finished, so the whole of it is a function of (pool, distractor source,
/// length, seed) — which is what lets the ticket's invariant be asserted
/// without pumping a widget: **every round has exactly one correct answer, no
/// distractor repeats it, and the same seed replays the same drill.**
///
/// Every shuffle is the app's seeded Fisher–Yates. The prototype reaches for
/// `sort(() => Math.random() - 0.5)` here, which is measurably non-uniform —
/// a recorded defect (#66), not a design, and on a small pool it would make
/// some terms surface far more often than others in the one surface whose
/// whole job is variety.
library;

import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';

/// How many options a question offers, the answer included.
const int vocabChoiceCount = 4;

/// How many of a round's wrong answers are drawn from the answer's own
/// category before the rest come from elsewhere.
///
/// Same-category distractors are the ones that make a question worth asking —
/// four words from four unrelated subjects is a reading test, not a drill —
/// while an all-same-category round starts to read as a trick. Two and one is
/// the design's split.
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
/// The eligibility rule in full. The authored self-checks are deliberately not
/// used — they stay on term detail, and a drill that mixed generated rounds
/// with authored ones would be two games wearing one name.
List<DictionaryTerm> vocabEligible(List<DictionaryTerm> terms) => [
  for (final term in terms)
    if (term.shortExplanation.trim().isNotEmpty) term,
];

/// The rounds a drill plays, in order.
///
/// [pool] is what may be *asked*; [distractorSource] is what may be *offered*
/// as a wrong answer. They are separate arguments because the Saved deck asks
/// about a handful of bookmarked terms while drawing its wrong answers from
/// everything the learner can reach — and because keeping them separate is
/// what makes it impossible to scope one and forget the other. Both are
/// already tier-scoped by the caller; a premium term name reaching a free
/// learner as a wrong option is the leak #57 named.
///
/// Shorter than [length] when the pool cannot fill it, never padded from
/// anywhere else.
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
/// elsewhere, degrading gracefully when either side runs short.
///
/// **The degradation is the part worth reading.** When the answer's category
/// cannot supply two, the shortfall is taken from elsewhere; when *elsewhere*
/// is empty — a pool drawn from one category — the shortfall goes back to the
/// category. So the round keeps four options wherever four terms exist, which
/// the prototype's version does not: it slices the two lists and stops,
/// leaving a three-option question whenever the answer's category holds the
/// whole pool.
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

/// Mints the seed for one drill. Re-minted by Play again, and stored nowhere —
/// a stored seed would re-fix the answer positions across replays, which is
/// the thing the shuffle exists to prevent.
int mintVocabSeed() => mintLessonNonce();
