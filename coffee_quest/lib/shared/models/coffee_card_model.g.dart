// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coffee_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoffeeCardModel _$CoffeeCardModelFromJson(Map<String, dynamic> json) =>
    _CoffeeCardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      moduleTag: json['moduleTag'] as String,
      iconName: json['iconName'] as String,
      lessonId: json['lessonId'] as String,
    );

Map<String, dynamic> _$CoffeeCardModelToJson(_CoffeeCardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'moduleTag': instance.moduleTag,
      'iconName': instance.iconName,
      'lessonId': instance.lessonId,
    };
