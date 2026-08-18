// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictCard _$PredictCardFromJson(Map<String, dynamic> json) => PredictCard(
  label: json['label'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  question: json['question'] as String,
  options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
  answer: json['a'] as String,
  hold: json['hold'] as String,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$PredictCardToJson(PredictCard instance) =>
    <String, dynamic>{
      'label': instance.label,
      'title': instance.title,
      'body': instance.body,
      'question': instance.question,
      'options': instance.options,
      'a': instance.answer,
      'hold': instance.hold,
      'kind': instance.$type,
    };

ConceptCard _$ConceptCardFromJson(Map<String, dynamic> json) => ConceptCard(
  label: json['label'] as String,
  title: json['title'] as String,
  fill: (json['fill'] as List<dynamic>)
      .map(const ConceptFillConverter().fromJson)
      .toList(),
  paragraphs: (json['paragraphs'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  meta: (json['meta'] as List<dynamic>)
      .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
      .toList(),
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$ConceptCardToJson(ConceptCard instance) =>
    <String, dynamic>{
      'label': instance.label,
      'title': instance.title,
      'fill': instance.fill.map(const ConceptFillConverter().toJson).toList(),
      'paragraphs': instance.paragraphs,
      'meta': instance.meta,
      'kind': instance.$type,
    };

VisualCard _$VisualCardFromJson(Map<String, dynamic> json) => VisualCard(
  label: json['label'] as String,
  title: json['title'] as String,
  variant: json['variant'] as String,
  caption: json['caption'] as String,
  mergeHeader: json['mergeHeader'] as bool?,
  captionTop: json['captionTop'] as bool?,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$VisualCardToJson(VisualCard instance) =>
    <String, dynamic>{
      'label': instance.label,
      'title': instance.title,
      'variant': instance.variant,
      'caption': instance.caption,
      'mergeHeader': instance.mergeHeader,
      'captionTop': instance.captionTop,
      'kind': instance.$type,
    };

PracticalCard _$PracticalCardFromJson(Map<String, dynamic> json) =>
    PracticalCard(
      tag: json['tag'] as String,
      title: json['title'] as String,
      paragraphs: (json['paragraphs'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      note: json['note'] as String,
      $type: json['kind'] as String?,
    );

Map<String, dynamic> _$PracticalCardToJson(PracticalCard instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'title': instance.title,
      'paragraphs': instance.paragraphs,
      'note': instance.note,
      'kind': instance.$type,
    };

McqCard _$McqCardFromJson(Map<String, dynamic> json) => McqCard(
  prompt: json['prompt'] as String,
  choices: (json['choices'] as List<dynamic>)
      .map((e) => Choice.fromJson(e as Map<String, dynamic>))
      .toList(),
  explanation: json['explain'] as String,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$McqCardToJson(McqCard instance) => <String, dynamic>{
  'prompt': instance.prompt,
  'choices': instance.choices,
  'explain': instance.explanation,
  'kind': instance.$type,
};

MultiCard _$MultiCardFromJson(Map<String, dynamic> json) => MultiCard(
  prompt: json['prompt'] as String,
  choices: (json['choices'] as List<dynamic>)
      .map((e) => Choice.fromJson(e as Map<String, dynamic>))
      .toList(),
  explanation: json['explain'] as String,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$MultiCardToJson(MultiCard instance) => <String, dynamic>{
  'prompt': instance.prompt,
  'choices': instance.choices,
  'explain': instance.explanation,
  'kind': instance.$type,
};

RecallCard _$RecallCardFromJson(Map<String, dynamic> json) => RecallCard(
  label: json['label'] as String,
  question: json['question'] as String,
  choices: (json['choices'] as List<dynamic>)
      .map((e) => Choice.fromJson(e as Map<String, dynamic>))
      .toList(),
  explanation: json['explain'] as String,
  takeaway: json['line'] as String,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$RecallCardToJson(RecallCard instance) =>
    <String, dynamic>{
      'label': instance.label,
      'question': instance.question,
      'choices': instance.choices,
      'explain': instance.explanation,
      'line': instance.takeaway,
      'kind': instance.$type,
    };

DecisionCard _$DecisionCardFromJson(Map<String, dynamic> json) => DecisionCard(
  label: json['label'] as String,
  title: json['title'] as String,
  scenario: json['scenario'] as String,
  question: json['question'] as String,
  options: (json['options'] as List<dynamic>)
      .map((e) => DecisionOption.fromJson(e as Map<String, dynamic>))
      .toList(),
  rightExplanation: json['right'] as String,
  wrongExplanation: json['wrong'] as String,
  note: json['note'] as String?,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$DecisionCardToJson(DecisionCard instance) =>
    <String, dynamic>{
      'label': instance.label,
      'title': instance.title,
      'scenario': instance.scenario,
      'question': instance.question,
      'options': instance.options,
      'right': instance.rightExplanation,
      'wrong': instance.wrongExplanation,
      'note': instance.note,
      'kind': instance.$type,
    };

MatchCard _$MatchCardFromJson(Map<String, dynamic> json) => MatchCard(
  prompt: json['prompt'] as String,
  pairs: (json['pairs'] as List<dynamic>)
      .map((e) => MatchPair.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$MatchCardToJson(MatchCard instance) => <String, dynamic>{
  'prompt': instance.prompt,
  'pairs': instance.pairs,
  'kind': instance.$type,
};

SequenceCard _$SequenceCardFromJson(Map<String, dynamic> json) => SequenceCard(
  prompt: json['prompt'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => SequenceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$SequenceCardToJson(SequenceCard instance) =>
    <String, dynamic>{
      'prompt': instance.prompt,
      'items': instance.items,
      'kind': instance.$type,
    };

SliderCard _$SliderCardFromJson(Map<String, dynamic> json) => SliderCard(
  prompt: json['prompt'] as String,
  leftLabel: json['leftLabel'] as String,
  rightLabel: json['rightLabel'] as String,
  target: (json['target'] as num).toDouble(),
  tolerance: (json['tolerance'] as num).toDouble(),
  scale: (json['scale'] as List<dynamic>).map((e) => e as String).toList(),
  feedback: json['feedback'] as String,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$SliderCardToJson(SliderCard instance) =>
    <String, dynamic>{
      'prompt': instance.prompt,
      'leftLabel': instance.leftLabel,
      'rightLabel': instance.rightLabel,
      'target': instance.target,
      'tolerance': instance.tolerance,
      'scale': instance.scale,
      'feedback': instance.feedback,
      'kind': instance.$type,
    };

TastefixCard _$TastefixCardFromJson(Map<String, dynamic> json) => TastefixCard(
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  prompt: json['prompt'] as String,
  scenario: json['scenario'] as String,
  choices: (json['choices'] as List<dynamic>)
      .map((e) => Choice.fromJson(e as Map<String, dynamic>))
      .toList(),
  explanation: json['explain'] as String,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$TastefixCardToJson(TastefixCard instance) =>
    <String, dynamic>{
      'tags': instance.tags,
      'prompt': instance.prompt,
      'scenario': instance.scenario,
      'choices': instance.choices,
      'explain': instance.explanation,
      'kind': instance.$type,
    };

BagpickCard _$BagpickCardFromJson(Map<String, dynamic> json) => BagpickCard(
  bag: json['bag'] as String,
  origin: json['origin'] as String,
  prompt: json['prompt'] as String,
  bean: BagpickBean.fromJson(json['bean'] as Map<String, dynamic>),
  options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
  answer: json['answer'] as String,
  tell: json['tell'] as String,
  cues: (json['cues'] as List<dynamic>)
      .map((e) => BagpickCue.fromJson(e as Map<String, dynamic>))
      .toList(),
  explanation: json['explain'] as String,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$BagpickCardToJson(BagpickCard instance) =>
    <String, dynamic>{
      'bag': instance.bag,
      'origin': instance.origin,
      'prompt': instance.prompt,
      'bean': instance.bean,
      'options': instance.options,
      'answer': instance.answer,
      'tell': instance.tell,
      'cues': instance.cues,
      'explain': instance.explanation,
      'kind': instance.$type,
    };

FlavorCard _$FlavorCardFromJson(Map<String, dynamic> json) => FlavorCard(
  clue: json['clue'] as String,
  prompt: json['prompt'] as String,
  choices: (json['choices'] as List<dynamic>)
      .map((e) => Choice.fromJson(e as Map<String, dynamic>))
      .toList(),
  answer: (json['answer'] as num).toInt(),
  explanation: json['explain'] as String,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$FlavorCardToJson(FlavorCard instance) =>
    <String, dynamic>{
      'clue': instance.clue,
      'prompt': instance.prompt,
      'choices': instance.choices,
      'answer': instance.answer,
      'explain': instance.explanation,
      'kind': instance.$type,
    };

QuizCard _$QuizCardFromJson(Map<String, dynamic> json) => QuizCard(
  statement: json['statement'] as String,
  answer: json['answer'] as bool,
  explanation: json['explain'] as String,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$QuizCardToJson(QuizCard instance) => <String, dynamic>{
  'statement': instance.statement,
  'answer': instance.answer,
  'explain': instance.explanation,
  'kind': instance.$type,
};
