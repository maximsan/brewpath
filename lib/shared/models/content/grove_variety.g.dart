// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grove_variety.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroveVariety _$GroveVarietyFromJson(Map<String, dynamic> json) =>
    _GroveVariety(
      id: json['id'] as String,
      name: json['name'] as String,
      latin: json['latin'] as String,
      share: json['share'] as String,
      use: json['use'] as String,
      origin: json['origin'] as String,
      grows: json['grows'] as String,
      cup: json['cup'] as String,
      tell: json['tell'] as String,
      shape: json['shape'] as String,
      leaf: json['leaf'] as String,
      drop: json['drop'] as String,
    );

Map<String, dynamic> _$GroveVarietyToJson(_GroveVariety instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latin': instance.latin,
      'share': instance.share,
      'use': instance.use,
      'origin': instance.origin,
      'grows': instance.grows,
      'cup': instance.cup,
      'tell': instance.tell,
      'shape': instance.shape,
      'leaf': instance.leaf,
      'drop': instance.drop,
    };
