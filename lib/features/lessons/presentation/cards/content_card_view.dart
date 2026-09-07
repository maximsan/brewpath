import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:brew_path/features/lessons/domain/held_guess.dart';
import 'package:brew_path/features/lessons/presentation/cards/bagpick_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/features/lessons/presentation/cards/concept_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/graded_picker.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_board.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_board_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/multi_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/practical_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/predict_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/recall_payoff.dart';
import 'package:brew_path/features/lessons/presentation/cards/sequence_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/sequence_order.dart';
import 'package:brew_path/features/lessons/presentation/cards/slider_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/visual_card_view.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:flutter/widgets.dart';

/// Builds the widget for [card]. A single exhaustive switch over the sealed
/// union, so adding a kind breaks this function until it is handled, and it
/// **always returns a widget** — a card this app cannot draw is not a state it
/// can be in (#418). [seed] fixes the choice order for this card in this
/// attempt (`card_seed.dart`), and [guess] is the loop the opening card opens
/// and the closing one resolves.
Widget contentCardView(
  ContentCard card, {
  required int seed,
  required CardSolved onSolved,
  required CardAdvance onContinue,
  GuessLoop guess = GuessLoop.none,
}) {
  final held = guess.held;

  return switch (card) {
    final PredictCard predict => PredictCardView(
      card: predict,
      options: shuffledBySeed(predict.options, seed),
      onContinue: onContinue,
      onGuess: guess.onGuess,
    ),
    final ConceptCard concept => ConceptCardView(
      card: concept,
      onContinue: onContinue,
    ),
    final PracticalCard practical => PracticalCardView(
      card: practical,
      onContinue: onContinue,
    ),
    final MultiCard multi => MultiCardView(
      prompt: multi.prompt,
      explanation: multi.explanation,
      options: shuffledBySeed(_fromChoices(multi.choices), seed),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    final McqCard mcq => GradedPicker(
      options: shuffledBySeed(_fromChoices(mcq.choices), seed),
      copy: _mcqCopy(mcq),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    final RecallCard recall => GradedPicker(
      options: shuffledBySeed(_fromChoices(recall.choices), seed),
      copy: _recallCopy(recall),
      onSolved: onSolved,
      onContinue: onContinue,
      // Only when the lesson actually opened on a guess: a deep link into a
      // single card reaches recall with nothing to pay off.
      payoff: held == null ? null : RecallPayoff(guess: held),
    ),
    final DecisionCard decision => GradedPicker(
      options: shuffledBySeed(_decisionOptions(decision), seed),
      copy: _decisionCopy(decision),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    final QuizCard quiz => GradedPicker(
      options: shuffledBySeed(_quizOptions(quiz), seed),
      copy: _quizCopy(quiz),
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
      copy: _tastefixCopy(tastefix),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    final FlavorCard flavor => GradedPicker(
      // Marked *before* the shuffle, never after. See `_flavorOptions`.
      options: shuffledBySeed(_flavorOptions(flavor), seed),
      copy: _flavorCopy(flavor),
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
    final VisualCard visual => VisualCardView(
      card: visual,
      onContinue: onContinue,
    ),
    final SliderCard slider => SliderCardView(
      card: slider,
      onSolved: onSolved,
      onContinue: onContinue,
    ),
    final SequenceCard sequence => SequenceCardView(
      prompt: sequence.prompt,
      // The one shuffle that can hand the learner the answer: a sequence round
      // is authored in its correct order, so the draw is checked against the
      // solution rather than merely taken. See `sequence_order.dart`.
      items: sequenceDisplayOrder(sequence.items, seed),
      onSolved: onSolved,
      onContinue: onContinue,
    ),
  };
}

/// True and False, marked from the statement's own answer. The pair is
/// seeded like every other card's choices, so a run cannot be passed by
/// learning that True always sits first.
List<ChoiceOption> _quizOptions(QuizCard card) => [
  ChoiceOption(text: 'True', isCorrect: card.answer),
  ChoiceOption(text: 'False', isCorrect: !card.answer),
];

/// What is wrong with the cup, as the eyebrow above the question — the tags are
/// framing rather than part of it, so they take the picker's existing slot.
///
/// ⚠️ **A visual deferral, recorded rather than hidden.** The design draws
/// these as berry-tinted chips that dim when a wrong fix makes the cup worse;
/// this renders one smallcaps line, with the words and none of the reaction.
String _tastefixSymptoms(TastefixCard card) => card.tags.join(' · ');

/// What each picking kind says around its choices — one builder per kind,
/// beside the option builders below, because what a kind *offers* and what it
/// *says* are halves of one mapping. Named rather than written inline with
/// history: the last real bug here routed `flavor` through `tastefix`'s helper
/// and produced a round nobody could win, caught only because the options half
/// already had a name to test against. These are the other half.
PickerCopy _mcqCopy(McqCard card) => PickerCopy(
  prompt: card.prompt,
  explain: ({required wasCorrect}) => card.explanation,
);

PickerCopy _recallCopy(RecallCard card) => PickerCopy(
  placement: VerdictPlacement.conversational,
  label: card.label,
  prompt: card.question,
  explain: ({required wasCorrect}) => card.explanation,
  footnote: card.takeaway,
);

PickerCopy _decisionCopy(DecisionCard card) => PickerCopy(
  placement: VerdictPlacement.conversational,
  label: card.label,
  title: card.title,
  scenario: card.scenario,
  prompt: card.question,
  // The one kind that authors a separate reading per outcome: being wrong here
  // has its own lesson, not a softer version of being right.
  explain: ({required wasCorrect}) =>
      wasCorrect ? card.rightExplanation : card.wrongExplanation,
  // And its verdict answers the judgement rather than grading it: a decision
  // is a call that pays off or backfires, not a fact you knew or did not.
  verdict: ({required wasCorrect}) =>
      wasCorrect ? 'Good call' : 'That would backfire',
  footnote: card.note,
);

PickerCopy _quizCopy(QuizCard card) => PickerCopy(
  prompt: card.statement,
  explain: ({required wasCorrect}) => card.explanation,
);

/// The cup's symptoms lead, then the setup, then the question.
PickerCopy _tastefixCopy(TastefixCard card) => PickerCopy(
  label: _tastefixSymptoms(card),
  scenario: card.scenario,
  prompt: card.prompt,
  explain: ({required wasCorrect}) => card.explanation,
  // A fix that worked, not an answer that was right.
  verdict: ({required wasCorrect}) => wasCorrect ? 'Good fix' : notQuiteVerdict,
);

/// The tasting clue takes the scenario slot: it is what the learner is reading
/// *from*, set out before the question rather than being part of it.
PickerCopy _flavorCopy(FlavorCard card) => PickerCopy(
  scenario: card.clue,
  prompt: card.prompt,
  explain: ({required wasCorrect}) => card.explanation,
);

/// A flavor round's notes, marked from the card's answer **index** — never
/// [_fromChoices], though both kinds hold `List<Choice>` and the two lines look
/// interchangeable in review. A tastefix round marks correctness on the choice;
/// a flavor round keeps it in a separate index, so passing it through the other
/// helper compiles, renders, and yields a round where every note reads as
/// wrong. The index resolves here and the result shuffles *after* it.
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
