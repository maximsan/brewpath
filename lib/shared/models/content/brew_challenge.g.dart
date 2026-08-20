// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brew_challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BrewChallenge _$BrewChallengeFromJson(Map<String, dynamic> json) =>
    _BrewChallenge(
      id: json['id'] as String,
      scope: $enumDecode(_$ChallengeScopeEnumMap, json['type']),
      moduleId: json['moduleId'] as String,
      cardId: json['cardId'] as String,
      title: json['title'] as String,
      instruction: json['instruction'] as String,
      effort: json['effort'] as String,
      prompt: json['prompt'] as String,
      reactions: (json['reactions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lessonId: json['lessonId'] as String?,
    );

Map<String, dynamic> _$BrewChallengeToJson(_BrewChallenge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ChallengeScopeEnumMap[instance.scope]!,
      'moduleId': instance.moduleId,
      'cardId': instance.cardId,
      'title': instance.title,
      'instruction': instance.instruction,
      'effort': instance.effort,
      'prompt': instance.prompt,
      'reactions': instance.reactions,
      'lessonId': instance.lessonId,
    };

const _$ChallengeScopeEnumMap = {
  ChallengeScope.module: 'module',
  ChallengeScope.lesson: 'lesson',
};
