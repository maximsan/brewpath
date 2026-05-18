// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LessonModel _$LessonModelFromJson(Map<String, dynamic> json) => _LessonModel(
  id: json['id'] as String,
  moduleId: json['moduleId'] as String,
  title: json['title'] as String,
  summary: json['summary'] as String,
  xpReward: (json['xpReward'] as num).toInt(),
  cardId: json['cardId'] as String?,
  steps: (json['steps'] as List<dynamic>)
      .map((e) => LessonStepModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LessonModelToJson(_LessonModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'moduleId': instance.moduleId,
      'title': instance.title,
      'summary': instance.summary,
      'xpReward': instance.xpReward,
      'cardId': instance.cardId,
      'steps': instance.steps,
    };
