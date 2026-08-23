// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_guide.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VisualGuideUnlock _$VisualGuideUnlockFromJson(Map<String, dynamic> json) =>
    _VisualGuideUnlock(lesson: json['lesson'] as String);

Map<String, dynamic> _$VisualGuideUnlockToJson(_VisualGuideUnlock instance) =>
    <String, dynamic>{'lesson': instance.lesson};

_VisualGuideNote _$VisualGuideNoteFromJson(Map<String, dynamic> json) =>
    _VisualGuideNote(
      term: json['term'] as String,
      detail: json['detail'] as String,
    );

Map<String, dynamic> _$VisualGuideNoteToJson(_VisualGuideNote instance) =>
    <String, dynamic>{'term': instance.term, 'detail': instance.detail};

_VisualGuide _$VisualGuideFromJson(Map<String, dynamic> json) => _VisualGuide(
  id: json['id'] as String,
  subject: json['visualGuide'] as String,
  unlock: VisualGuideUnlock.fromJson(json['unlock'] as Map<String, dynamic>),
  label: json['label'] as String,
  title: json['title'] as String,
  summary: json['summary'] as String,
  fact: json['fact'] as String,
  meta:
      (json['meta'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList() ??
      const <List<String>>[],
  notes:
      (json['notes'] as List<dynamic>?)
          ?.map((e) => VisualGuideNote.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <VisualGuideNote>[],
  note: json['note'] as String?,
);

Map<String, dynamic> _$VisualGuideToJson(_VisualGuide instance) =>
    <String, dynamic>{
      'id': instance.id,
      'visualGuide': instance.subject,
      'unlock': instance.unlock,
      'label': instance.label,
      'title': instance.title,
      'summary': instance.summary,
      'fact': instance.fact,
      'meta': instance.meta,
      'notes': instance.notes,
      'note': instance.note,
    };
