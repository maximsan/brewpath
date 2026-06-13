// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ModuleModel _$ModuleModelFromJson(Map<String, dynamic> json) => _ModuleModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  iconName: json['iconName'] as String,
  lessonIds: (json['lessonIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  unlockRequirement: json['unlockRequirement'] as String?,
);

Map<String, dynamic> _$ModuleModelToJson(_ModuleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'iconName': instance.iconName,
      'lessonIds': instance.lessonIds,
      'unlockRequirement': instance.unlockRequirement,
    };
