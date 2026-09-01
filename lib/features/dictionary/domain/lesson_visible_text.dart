/// The words of a lesson a learner can actually read on screen.
///
/// This exists for one caller — the mention rule behind the practice term pool
/// (ADR-0014) — and it is deliberately **not** "every string in the record". A
/// card carries authored data no renderer prints: a bagpick cue's `tell` is an
/// id, a visual card's subject is an axis slug, a slider's target is a number.
/// Counting those would let a term be "mentioned" by a lesson that never says
/// it, which is the one thing this function exists to prevent.
///
/// The switch is exhaustive on purpose: a new card kind does not compile until
/// someone says which of its fields a learner sees.
library;

import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/content_reward.dart';
import 'package:brew_path/shared/models/lesson_model.dart';

/// Every visible run of copy in [lesson], joined into one searchable string.
String lessonVisibleText(LessonModel lesson) => [
  lesson.title,
  lesson.moduleLabel,
  for (final card in lesson.cards) ...cardVisibleText(card),
  ..._rewardText(lesson.reward),
].join(' ');

/// The copy [card] renders, by kind.
Iterable<String> cardVisibleText(ContentCard card) => switch (card) {
  final PredictCard predict => [
    predict.label,
    predict.title,
    predict.body,
    predict.question,
    ...predict.options,
    predict.answer,
    predict.hold,
  ],
  final ConceptCard concept => [
    concept.label,
    concept.title,
    ..._conceptBody(concept),
    for (final row in concept.meta) ...row,
  ],
  final VisualCard visual => [visual.label, visual.title, visual.caption],
  final PracticalCard practical => [
    practical.tag,
    practical.title,
    ...practical.paragraphs,
    practical.note,
  ],
  final McqCard mcq => _asked(mcq.prompt, mcq.choices, mcq.explanation),
  final MultiCard multi => _asked(
    multi.prompt,
    multi.choices,
    multi.explanation,
  ),
  final FlavorCard flavor => [
    flavor.clue,
    ..._asked(flavor.prompt, flavor.choices, flavor.explanation),
  ],
  final RecallCard recall => [
    recall.label,
    ..._asked(recall.question, recall.choices, recall.explanation),
    recall.takeaway,
  ],
  final TastefixCard tastefix => [
    ...tastefix.tags,
    tastefix.scenario,
    ..._asked(tastefix.prompt, tastefix.choices, tastefix.explanation),
  ],
  final DecisionCard decision => _decision(decision),
  final MatchCard match => [
    match.prompt,
    for (final pair in match.pairs) ...[pair.left, pair.right],
  ],
  final SequenceCard sequence => [
    sequence.prompt,
    for (final item in sequence.items) item.label,
  ],
  final SliderCard slider => [
    slider.prompt,
    slider.leftLabel,
    slider.rightLabel,
    ...slider.scale,
    slider.feedback,
  ],
  final BagpickCard bagpick => _bagpick(bagpick),
  final QuizCard quiz => [quiz.statement, quiz.explanation],
};

/// The shape every picking card shares: a prompt, its options, its teaching.
Iterable<String> _asked(
  String prompt,
  List<Choice> choices,
  String explanation,
) => [prompt, for (final choice in choices) choice.text, explanation];

Iterable<String> _decision(DecisionCard card) => [
  card.label,
  card.title,
  card.scenario,
  card.question,
  for (final option in card.options) ...[option.text, ?option.subtitle],
  card.rightExplanation,
  card.wrongExplanation,
  ?card.note,
];

Iterable<String> _bagpick(BagpickCard card) => [
  card.bag,
  card.origin,
  card.prompt,
  ...card.options,
  card.answer,
  for (final cue in card.cues) ...[cue.label, cue.text],
  card.explanation,
];

/// A concept card's sentence and the prose under it.
///
/// A card with blanks renders only `paragraphs[1]` as support copy — the rest
/// of the list is authoring the renderer never prints — while a card with no
/// blanks is plain prose and prints all of it.
Iterable<String> _conceptBody(ConceptCard card) => [
  for (final part in card.fill)
    ...switch (part) {
      FillLiteral(:final text) => [text],
      FillBlank(:final answer, :final options, :final label) => [
        answer,
        label,
        ...options,
      ],
    },
  if (card.fill.isEmpty)
    ...card.paragraphs
  else if (card.paragraphs.length > 1)
    card.paragraphs[1],
];

Iterable<String> _rewardText(ContentReward reward) => [
  reward.title,
  reward.summary,
  reward.fact,
  ?reward.badge,
  for (final row in reward.meta) ...row,
];
