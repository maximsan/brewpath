// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonModelImpl _$$LessonModelImplFromJson(Map<String, dynamic> json) =>
    _$LessonModelImpl(
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

Map<String, dynamic> _$$LessonModelImplToJson(_$LessonModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'moduleId': instance.moduleId,
      'title': instance.title,
      'summary': instance.summary,
      'xpReward': instance.xpReward,
      'cardId': instance.cardId,
      'steps': instance.steps,
    };
