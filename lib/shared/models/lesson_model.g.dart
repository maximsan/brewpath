// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LessonModel _$LessonModelFromJson(Map<String, dynamic> json) => _LessonModel(
  id: json['id'] as String,
  moduleId: json['moduleId'] as String,
  moduleLabel: json['moduleLabel'] as String,
  title: json['title'] as String,
  points: (json['points'] as num).toInt(),
  time: (json['time'] as num).toInt(),
  cards: (json['cards'] as List<dynamic>)
      .map((e) => ContentCard.fromJson(e as Map<String, dynamic>))
      .toList(),
  reward: ContentReward.fromJson(json['reward'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LessonModelToJson(_LessonModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'moduleId': instance.moduleId,
      'moduleLabel': instance.moduleLabel,
      'title': instance.title,
      'points': instance.points,
      'time': instance.time,
      'cards': instance.cards,
      'reward': instance.reward,
    };
