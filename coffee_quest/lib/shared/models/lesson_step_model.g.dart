// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_step_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MultipleChoiceStepImpl _$$MultipleChoiceStepImplFromJson(
        Map<String, dynamic> json) =>
    _$MultipleChoiceStepImpl(
      question: json['question'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctIndex: (json['correctIndex'] as num).toInt(),
      explanation: json['explanation'] as String,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$MultipleChoiceStepImplToJson(
        _$MultipleChoiceStepImpl instance) =>
    <String, dynamic>{
      'question': instance.question,
      'options': instance.options,
      'correctIndex': instance.correctIndex,
      'explanation': instance.explanation,
      'type': instance.$type,
    };

_$DragDropStepImpl _$$DragDropStepImplFromJson(Map<String, dynamic> json) =>
    _$DragDropStepImpl(
      instruction: json['instruction'] as String,
      terms: (json['terms'] as List<dynamic>).map((e) => e as String).toList(),
      definitions: (json['definitions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$DragDropStepImplToJson(_$DragDropStepImpl instance) =>
    <String, dynamic>{
      'instruction': instance.instruction,
      'terms': instance.terms,
      'definitions': instance.definitions,
      'type': instance.$type,
    };

_$SliderStepImpl _$$SliderStepImplFromJson(Map<String, dynamic> json) =>
    _$SliderStepImpl(
      instruction: json['instruction'] as String,
      minValue: (json['minValue'] as num).toDouble(),
      maxValue: (json['maxValue'] as num).toDouble(),
      targetMin: (json['targetMin'] as num).toDouble(),
      targetMax: (json['targetMax'] as num).toDouble(),
      unit: json['unit'] as String,
      explanation: json['explanation'] as String,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$SliderStepImplToJson(_$SliderStepImpl instance) =>
    <String, dynamic>{
      'instruction': instance.instruction,
      'minValue': instance.minValue,
      'maxValue': instance.maxValue,
      'targetMin': instance.targetMin,
      'targetMax': instance.targetMax,
      'unit': instance.unit,
      'explanation': instance.explanation,
      'type': instance.$type,
    };

_$TapOrderStepImpl _$$TapOrderStepImplFromJson(Map<String, dynamic> json) =>
    _$TapOrderStepImpl(
      instruction: json['instruction'] as String,
      items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
      explanation: json['explanation'] as String,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$TapOrderStepImplToJson(_$TapOrderStepImpl instance) =>
    <String, dynamic>{
      'instruction': instance.instruction,
      'items': instance.items,
      'explanation': instance.explanation,
      'type': instance.$type,
    };
