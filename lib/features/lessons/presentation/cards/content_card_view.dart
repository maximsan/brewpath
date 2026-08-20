import 'package:brew_path/features/lessons/domain/card_seed.dart';
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
    SliderCard() ||
    TastefixCard() ||
    BagpickCard() ||
    FlavorCard() => null,
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
  MatchCard() => true,
  VisualCard() ||
  PracticalCard() ||
  MultiCard() ||
  SequenceCard() ||
  SliderCard() ||
  TastefixCard() ||
  BagpickCard() ||
  FlavorCard() => false,
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
