// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_parts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Choice _$ChoiceFromJson(Map<String, dynamic> json) => _Choice(
  text: json['t'] as String,
  isCorrect: json['correct'] as bool? ?? false,
);

Map<String, dynamic> _$ChoiceToJson(_Choice instance) => <String, dynamic>{
  't': instance.text,
  'correct': instance.isCorrect,
};

_DecisionOption _$DecisionOptionFromJson(Map<String, dynamic> json) =>
    _DecisionOption(
      text: json['t'] as String,
      subtitle: json['sub'] as String?,
      isCorrect: json['correct'] as bool? ?? false,
    );

Map<String, dynamic> _$DecisionOptionToJson(_DecisionOption instance) =>
    <String, dynamic>{
      't': instance.text,
      'sub': instance.subtitle,
      'correct': instance.isCorrect,
    };

_MatchPair _$MatchPairFromJson(Map<String, dynamic> json) =>
    _MatchPair(left: json['l'] as String, right: json['r'] as String);

Map<String, dynamic> _$MatchPairToJson(_MatchPair instance) =>
    <String, dynamic>{'l': instance.left, 'r': instance.right};

_SequenceItem _$SequenceItemFromJson(Map<String, dynamic> json) =>
    _SequenceItem(
      label: json['label'] as String,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$SequenceItemToJson(_SequenceItem instance) =>
    <String, dynamic>{'label': instance.label, 'order': instance.order};

_BagpickBean _$BagpickBeanFromJson(Map<String, dynamic> json) => _BagpickBean(
  body: json['body'] as String,
  crease: json['crease'] as String,
  mottle: (json['mottle'] as num).toInt(),
  chaff: json['chaff'] as bool,
);

Map<String, dynamic> _$BagpickBeanToJson(_BagpickBean instance) =>
    <String, dynamic>{
      'body': instance.body,
      'crease': instance.crease,
      'mottle': instance.mottle,
      'chaff': instance.chaff,
    };

_BagpickCue _$BagpickCueFromJson(Map<String, dynamic> json) => _BagpickCue(
  id: json['id'] as String,
  label: json['label'] as String,
  text: json['text'] as String,
);

Map<String, dynamic> _$BagpickCueToJson(_BagpickCue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'text': instance.text,
    };
