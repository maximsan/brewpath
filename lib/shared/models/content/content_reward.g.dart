// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_reward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContentReward _$ContentRewardFromJson(Map<String, dynamic> json) =>
    _ContentReward(
      title: json['title'] as String,
      summary: json['summary'] as String,
      fact: json['fact'] as String,
      meta:
          (json['meta'] as List<dynamic>?)
              ?.map(
                (e) => (e as List<dynamic>).map((e) => e as String).toList(),
              )
              .toList() ??
          const <List<String>>[],
      badge: json['badge'] as String?,
    );

Map<String, dynamic> _$ContentRewardToJson(_ContentReward instance) =>
    <String, dynamic>{
      'title': instance.title,
      'summary': instance.summary,
      'fact': instance.fact,
      'meta': instance.meta,
      'badge': instance.badge,
    };
