// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mini_game_format.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MiniGameFormat _$MiniGameFormatFromJson(Map<String, dynamic> json) =>
    _MiniGameFormat(
      id: json['id'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      topic: json['sub'] as String,
      duration: json['meta'] as String,
      blurb: json['blurb'] as String,
      steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MiniGameFormatToJson(_MiniGameFormat instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'title': instance.title,
      'sub': instance.topic,
      'meta': instance.duration,
      'blurb': instance.blurb,
      'steps': instance.steps,
    };
