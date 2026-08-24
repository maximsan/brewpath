import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:brew_path/features/lessons/presentation/cards/bagpick_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/features/lessons/presentation/cards/concept_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/graded_picker.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_board.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_board_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/predict_card_view.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:flutter/widgets.dart';

/// Builds the widget for [card], or null where no renderer exists yet.
///
/// A single exhaustive switch over the sealed union — no registry, no builder
/// map, no factory indirection. Adding a kind to [ContentCard] breaks this
/// function until the kind is handled, which is the guarantee the union was
/// chosen for.
///
/// Seven kinds render today: the five lesson kinds that are the eight cards
/// of the first lesson and 185 of the course's 257, plus `quiz` and
/// `match`, which the free mini-game pair needs. The rest return null rather
/// than a placeholder, so a host meets an honest absence instead of a card
/// that pretends.
///
/// [nonce] identifies the lesson attempt and [cardIndex] the card's place in
/// it; together they seed the choice order. See `card_seed.dart` for why
/// neither is stored.
Widget? contentCardView(
  ContentCard card, {
  required int nonce,
  required int cardIndex,
  required CardSolved onSolved,
  required CardAdvance onContinue,
}) {
  final seed = cardSeed(nonce: nonce, cardIndex: cardIndex);

  return switch (card) {
    final PredictCard predict => PredictCardView(
      card: predict,
      options: shuffledBySeed(_predictOptions(predict), seed),
      onContinue: onContinue,
    ),
    final ConceptCard concept => ConceptCardView(
      card: concept,
      onContinue: onContinue,
    ),
    final McqCard mcq => GradedPicker(
      options: shuffledBySeed(_fromChoices(mcq.choices), seed),
      copy: PickerCopy(
        prompt: mcq.prompt,
        explain: ({required wasCorrect}) => mcq.explanation,
      ),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    final RecallCard recall => GradedPicker(
      options: shuffledBySeed(_fromChoices(recall.choices), seed),
      copy: PickerCopy(
        label: recall.label,
        prompt: recall.question,
        explain: ({required wasCorrect}) => recall.explanation,
        footnote: recall.takeaway,
      ),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    final DecisionCard decision => GradedPicker(
      options: shuffledBySeed(_decisionOptions(decision), seed),
      copy: PickerCopy(
        label: decision.label,
        title: decision.title,
        scenario: decision.scenario,
        prompt: decision.question,
        // The one kind that authors a separate reading per outcome: being
        // wrong here has its own lesson, not a softer version of being right.
        explain: ({required wasCorrect}) =>
            wasCorrect ? decision.rightExplanation : decision.wrongExplanation,
        footnote: decision.note,
      ),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    final QuizCard quiz => GradedPicker(
      options: shuffledBySeed(_quizOptions(quiz), seed),
      copy: PickerCopy(
        prompt: quiz.statement,
        explain: ({required wasCorrect}) => quiz.explanation,
      ),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    final BagpickCard bagpick => BagpickCardView(
      card: bagpick,
      // Display order only. The option's identity is the process key, so the
      // shuffle can move it freely and nothing keys off an index.
      options: shuffledBySeed(bagpick.options, seed),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    final TastefixCard tastefix => GradedPicker(
      // Marked on the choice, unlike `flavor` directly below. The two kinds
      // hold the same type and mean different things — see `_flavorOptions`.
      options: shuffledBySeed(_fromChoices(tastefix.choices), seed),
      copy: PickerCopy(
        label: _tastefixSymptoms(tastefix),
        scenario: tastefix.scenario,
        prompt: tastefix.prompt,
        explain: ({required wasCorrect}) => tastefix.explanation,
      ),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    final FlavorCard flavor => GradedPicker(
      // Marked *before* the shuffle, never after. See `_flavorOptions`.
      options: shuffledBySeed(_flavorOptions(flavor), seed),
      copy: PickerCopy(
        scenario: flavor.clue,
        prompt: flavor.prompt,
        explain: ({required wasCorrect}) => flavor.explanation,
      ),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    final MatchCard match => MatchBoardView(
      prompt: match.prompt,
      // Both sides are seeded from the card's own seed, so a replay moves the
      // facts and the answers together rather than leaving either fixed.
      pairs: shuffledBySeed(match.pairs, seed),
      targets: shuffledBySeed(matchTargets(match.pairs), seed),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    VisualCard() ||
    PracticalCard() ||
    MultiCard() ||
    SequenceCard() ||
    SliderCard() => null,
  };
}

/// Whether [card] can be drawn today.
///
/// The same partition as [contentCardView]'s final arm, stated separately so a
/// host can decide what to play *before* it builds anything. Both switches are
/// exhaustive over the sealed union, so a new kind breaks both at once and
/// neither can quietly drift out of step with the other — a unit test pins the
/// two together for the cases that exist now.
bool hasRenderer(ContentCard card) => switch (card) {
  PredictCard() ||
  ConceptCard() ||
  McqCard() ||
  RecallCard() ||
  DecisionCard() ||
  QuizCard() ||
  FlavorCard() ||
  TastefixCard() ||
  BagpickCard() ||
  MatchCard() => true,
  VisualCard() ||
  PracticalCard() ||
  MultiCard() ||
  SequenceCard() ||
  SliderCard() => false,
};

/// The cards of [cards] that can actually be played, in authored order.
///
/// Eight of the fifteen kinds have no renderer yet, and they are scattered
/// through thirty of the thirty-two lessons. Filtering here keeps every lesson
/// finishable instead of stranding the learner on a card that cannot draw
/// itself; the alternative — a placeholder that says so — puts unfinished
/// scaffolding in front of a learner on the way to the next real card.
///
/// This is a temporary shape. It disappears on its own as the remaining
/// renderers land, without a caller changing.
List<ContentCard> playableCards(List<ContentCard> cards) => [
  for (final card in cards)
    if (hasRenderer(card)) card,
];

/// True and False, marked from the statement's own answer. The pair is
/// seeded like every other card's choices, so a run cannot be passed by
/// learning that True always sits first.
List<ChoiceOption> _quizOptions(QuizCard card) => [
  ChoiceOption(text: 'True', isCorrect: card.answer),
  ChoiceOption(text: 'False', isCorrect: !card.answer),
];

/// What is wrong with the cup, as the eyebrow above the question.
///
/// The tags are symptoms — `SOUR`, `THIN` — and they are framing rather than
/// part of the question: they say how the cup tastes before the learner is
/// asked what to do about it. So they take the picker's existing eyebrow slot
/// instead of adding a parameter only one kind of the five would ever pass.
///
/// ⚠️ **A visual deferral, recorded rather than hidden.** The design draws
/// these as berry-tinted pill chips that dim when a wrong fix makes the cup
/// worse. This renders them as one smallcaps line, which carries the same words
/// and none of the reaction. Reinstating the chips means composing around the
/// shared picker rather than filling its slots, which is a bigger change than
/// making the kind render and belongs to whoever takes the cup's reaction on.
String _tastefixSymptoms(TastefixCard card) => card.tags.join(' · ');

/// A flavor round's notes, marked from the card's answer **index**.
///
/// Deliberately not [_fromChoices], which the tastefix kind uses, even though
/// both kinds hold `List<Choice>` and the two lines would look interchangeable
/// in review.
///
/// A tastefix round marks its correct choice *on the choice*. A flavor round
/// does not — its notes are authored bare and correctness lives in a separate
/// index into the authored order. Passing them through [_fromChoices] compiles,
/// renders, and yields a round where every note reads as wrong: success can
/// never fire and the learner scores zero on a game that looks perfect. Nothing
/// throws.
///
/// So the index is resolved here, and the result is shuffled *after*. Once an
/// option carries its own correctness the seeded order is free to move it;
/// shuffling first would leave the index pointing at whatever landed in that
/// position.
List<ChoiceOption> _flavorOptions(FlavorCard card) => [
  for (final (index, choice) in card.choices.indexed)
    ChoiceOption(text: choice.text, isCorrect: index == card.answer),
];

List<ChoiceOption> _fromChoices(List<Choice> choices) => [
  for (final choice in choices)
    ChoiceOption(text: choice.text, isCorrect: choice.isCorrect),
];

List<ChoiceOption> _decisionOptions(DecisionCard card) => [
  for (final option in card.options)
    ChoiceOption(
      text: option.text,
      subtitle: option.subtitle,
      isCorrect: option.isCorrect,
    ),
];

/// A predict card's two guesses are bare strings, and its answer is held back
/// rather than marked — so `isCorrect` is recorded but never revealed.
List<ChoiceOption> _predictOptions(PredictCard card) => [
  for (final option in card.options)
    ChoiceOption(text: option, isCorrect: option == card.answer),
];
