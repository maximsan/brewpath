// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ModuleLesson _$ModuleLessonFromJson(Map<String, dynamic> json) =>
    _ModuleLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      points: (json['points'] as num).toInt(),
      time: (json['time'] as num).toInt(),
    );

Map<String, dynamic> _$ModuleLessonToJson(_ModuleLesson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'points': instance.points,
      'time': instance.time,
    };

_ModuleModel _$ModuleModelFromJson(Map<String, dynamic> json) => _ModuleModel(
  id: json['id'] as String,
  n: (json['n'] as num).toInt(),
  label: json['label'] as String,
  iconName: json['glyph'] as String,
  title: json['title'] as String,
  lessons: (json['lessons'] as List<dynamic>)
      .map((e) => ModuleLesson.fromJson(e as Map<String, dynamic>))
      .toList(),
  reward: ContentReward.fromJson(json['reward'] as Map<String, dynamic>),
  art: json['art'] as String?,
  artPos: json['artPos'] as String?,
);

Map<String, dynamic> _$ModuleModelToJson(_ModuleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'n': instance.n,
      'label': instance.label,
      'glyph': instance.iconName,
      'title': instance.title,
      'lessons': instance.lessons,
      'reward': instance.reward,
      'art': instance.art,
      'artPos': instance.artPos,
    };
