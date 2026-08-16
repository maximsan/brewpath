import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/features/lessons/presentation/cards/concept_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/graded_picker.dart';
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
/// Five kinds render today: they are the eight cards of the first lesson and
/// 185 of the course's 257. The rest return null rather than a placeholder,
/// so a host meets an honest absence instead of a card that pretends.
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
    VisualCard() ||
    PracticalCard() ||
    MultiCard() ||
    MatchCard() ||
    SequenceCard() ||
    SliderCard() ||
    TastefixCard() ||
    BagpickCard() ||
    FlavorCard() => null,
  };
}

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
