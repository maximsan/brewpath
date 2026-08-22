// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DictionaryCategory _$DictionaryCategoryFromJson(Map<String, dynamic> json) =>
    _DictionaryCategory(
      id: json['id'] as String,
      label: json['label'] as String,
      glyph: json['glyph'] as String,
      summary: json['short'] as String,
    );

Map<String, dynamic> _$DictionaryCategoryToJson(_DictionaryCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'glyph': instance.glyph,
      'short': instance.summary,
    };
