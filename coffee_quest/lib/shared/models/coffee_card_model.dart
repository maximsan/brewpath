import 'package:freezed_annotation/freezed_annotation.dart';

part 'coffee_card_model.freezed.dart';
part 'coffee_card_model.g.dart';

/// Content model for a collectible coffee card.
@freezed
abstract class CoffeeCardModel with _$CoffeeCardModel {
  /// Creates a [CoffeeCardModel].
  const factory CoffeeCardModel({
    required String id,
    required String title,
    required String description,
    required String moduleTag,
    required String iconName,
    required String lessonId,
  }) = _CoffeeCardModel;

  /// Creates a [CoffeeCardModel] from decoded JSON.
  factory CoffeeCardModel.fromJson(Map<String, dynamic> json) =>
      _$CoffeeCardModelFromJson(json);
}
