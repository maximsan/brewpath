// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grove_light.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroveLight _$GroveLightFromJson(Map<String, dynamic> json) => _GroveLight(
  id: json['id'] as String,
  name: json['name'] as String,
  note: json['note'] as String,
  swatch: json['swatch'] as String,
  filter: json['filter'] as String,
);

Map<String, dynamic> _$GroveLightToJson(_GroveLight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'note': instance.note,
      'swatch': instance.swatch,
      'filter': instance.filter,
    };
