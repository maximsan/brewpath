// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_step_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultipleChoiceStep _$MultipleChoiceStepFromJson(Map<String, dynamic> json) =>
    MultipleChoiceStep(
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctIndex: (json['correctIndex'] as num).toInt(),
      explanation: json['explanation'] as String,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$MultipleChoiceStepToJson(MultipleChoiceStep instance) =>
    <String, dynamic>{
      'question': instance.question,
      'options': instance.options,
      'correctIndex': instance.correctIndex,
      'explanation': instance.explanation,
      'type': instance.$type,
    };

DragDropStep _$DragDropStepFromJson(Map<String, dynamic> json) => DragDropStep(
  instruction: json['instruction'] as String,
  terms: (json['terms'] as List<dynamic>).map((e) => e as String).toList(),
  definitions: (json['definitions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$DragDropStepToJson(DragDropStep instance) =>
    <String, dynamic>{
      'instruction': instance.instruction,
      'terms': instance.terms,
      'definitions': instance.definitions,
      'type': instance.$type,
    };

SliderStep _$SliderStepFromJson(Map<String, dynamic> json) => SliderStep(
  instruction: json['instruction'] as String,
  minValue: (json['minValue'] as num).toDouble(),
  maxValue: (json['maxValue'] as num).toDouble(),
  targetMin: (json['targetMin'] as num).toDouble(),
  targetMax: (json['targetMax'] as num).toDouble(),
  unit: json['unit'] as String,
  explanation: json['explanation'] as String,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$SliderStepToJson(SliderStep instance) =>
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

TapOrderStep _$TapOrderStepFromJson(Map<String, dynamic> json) => TapOrderStep(
  instruction: json['instruction'] as String,
  items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
  explanation: json['explanation'] as String,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$TapOrderStepToJson(TapOrderStep instance) =>
    <String, dynamic>{
      'instruction': instance.instruction,
      'items': instance.items,
      'explanation': instance.explanation,
      'type': instance.$type,
    };
