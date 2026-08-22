// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_term.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DictionarySource _$DictionarySourceFromJson(Map<String, dynamic> json) =>
    _DictionarySource(
      label: json['label'] as String,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$DictionarySourceToJson(_DictionarySource instance) =>
    <String, dynamic>{'label': instance.label, 'url': instance.url};

_DictionaryCheck _$DictionaryCheckFromJson(Map<String, dynamic> json) =>
    _DictionaryCheck(
      question: json['q'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),
      explanation: json['explain'] as String,
    );

Map<String, dynamic> _$DictionaryCheckToJson(_DictionaryCheck instance) =>
    <String, dynamic>{
      'q': instance.question,
      'choices': instance.choices,
      'explain': instance.explanation,
    };

_DictionaryTerm _$DictionaryTermFromJson(
  Map<String, dynamic> json,
) => _DictionaryTerm(
  id: json['id'] as String,
  term: json['term'] as String,
  categoryId: json['cat'] as String,
  shortExplanation: json['short'] as String,
  relatedIds:
      (json['related'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  aliases:
      (json['aliases'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  lessonId: json['lesson'] as String?,
  pronunciation: json['pron'] as String?,
  deepExplanation: json['deep'] as String?,
  example: json['example'] as String?,
  sources:
      (json['sources'] as List<dynamic>?)
          ?.map((e) => DictionarySource.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DictionarySource>[],
  check: json['check'] == null
      ? null
      : DictionaryCheck.fromJson(json['check'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DictionaryTermToJson(_DictionaryTerm instance) =>
    <String, dynamic>{
      'id': instance.id,
      'term': instance.term,
      'cat': instance.categoryId,
      'short': instance.shortExplanation,
      'related': instance.relatedIds,
      'aliases': instance.aliases,
      'lesson': instance.lessonId,
      'pron': instance.pronunciation,
      'deep': instance.deepExplanation,
      'example': instance.example,
      'sources': instance.sources,
      'check': instance.check,
    };
