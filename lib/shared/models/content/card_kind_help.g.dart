// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_kind_help.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CardKindHelp _$CardKindHelpFromJson(Map<String, dynamic> json) =>
    _CardKindHelp(
      kind: json['kind'] as String,
      title: json['title'] as String,
      blurb: json['blurb'] as String,
      steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CardKindHelpToJson(_CardKindHelp instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'title': instance.title,
      'blurb': instance.blurb,
      'steps': instance.steps,
    };
