import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/features/lessons/domain/card_seed.dart';
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
import 'package:brew_path/features/lessons/presentation/cards/sequence_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/sequence_order.dart';
import 'package:brew_path/features/lessons/presentation/cards/slider_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/visual_card_view.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:flutter/widgets.dart';

/// Builds the widget for [card].
///
/// A single exhaustive switch over the sealed union — no registry, no builder
/// map, no factory indirection. Adding a kind to [ContentCard] breaks this
/// function until the kind is handled, which is the guarantee the union was
/// chosen for.
///
/// **It always returns a widget** — a card this app cannot draw is not a state
/// it can be in, and the switch below is what holds that (#418).
///
/// `visual` is the one that reports no success: it is a reference a lesson
/// shows, never a question, so it latches on arrival and mastery cannot move
/// when a lesson gains one.
///
/// [nonce] identifies the lesson attempt and [cardIndex] the card's place in
/// it; together they seed the choice order. See `card_seed.dart` for why
/// neither is stored.
Widget contentCardView(
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
      options: shuffledBySeed(predict.options, seed),
      onContinue: onContinue,
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

/// What each picking kind says around its choices.
///
/// One builder per kind, beside the option builders below, because the two are
/// halves of the same mapping: what a kind *offers* and what it *says* are the
/// two things a card has to get right about its content, and reading one
/// without the other is how they drift.
///
/// Named rather than written inline in the switch for a reason with history.
/// The last real bug in this file was a mapping — `flavor` marks correctness
/// with an index where `tastefix` marks it on the choice, and routing one
/// through the other's helper produced a round nobody could win, silently. It
/// was caught because the *options* half already had a name to test against.
/// These are the other half.
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
