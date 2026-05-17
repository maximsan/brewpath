// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModuleModelImpl _$$ModuleModelImplFromJson(Map<String, dynamic> json) =>
    _$ModuleModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      lessonIds:
          (json['lessonIds'] as List<dynamic>).map((e) => e as String).toList(),
      unlockRequirement: json['unlockRequirement'] as String?,
    );

Map<String, dynamic> _$$ModuleModelImplToJson(_$ModuleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'iconName': instance.iconName,
      'lessonIds': instance.lessonIds,
      'unlockRequirement': instance.unlockRequirement,
    };
