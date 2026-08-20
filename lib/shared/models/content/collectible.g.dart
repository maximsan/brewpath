// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collectible.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CollectibleUnlock _$CollectibleUnlockFromJson(Map<String, dynamic> json) =>
    _CollectibleUnlock(
      lessonId: json['lesson'] as String?,
      moduleId: json['module'] as String?,
    );

Map<String, dynamic> _$CollectibleUnlockToJson(_CollectibleUnlock instance) =>
    <String, dynamic>{'lesson': instance.lessonId, 'module': instance.moduleId};

_Collectible _$CollectibleFromJson(Map<String, dynamic> json) => _Collectible(
  id: json['id'] as String,
  unlock: CollectibleUnlock.fromJson(json['unlock'] as Map<String, dynamic>),
  kind: json['kind'] as String,
);

Map<String, dynamic> _$CollectibleToJson(_Collectible instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unlock': instance.unlock,
      'kind': instance.kind,
    };
