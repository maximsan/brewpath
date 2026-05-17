import 'package:freezed_annotation/freezed_annotation.dart';

part 'coffee_card_model.freezed.dart';
part 'coffee_card_model.g.dart';

@freezed
class CoffeeCardModel with _$CoffeeCardModel {
  const factory CoffeeCardModel({
    required String id,
    required String title,
    required String description,
    required String moduleTag,
    required String iconName,
    required String lessonId,
  }) = _CoffeeCardModel;

  factory CoffeeCardModel.fromJson(Map<String, dynamic> json) =>
      _$CoffeeCardModelFromJson(json);
}
