import 'package:freezed_annotation/freezed_annotation.dart';

part 'coffee_card_model.freezed.dart';

/// A collectible card as the screens show it: the bank's record joined to the
/// words of whatever unlocks it.
///
/// **Assembled, never parsed.** There is no `fromJson` here on purpose — no
/// single bank record holds a card's text. The collectible supplies the id and
/// the illustration key, its source lesson or module supplies the title,
/// summary and fact, and the content layer joins the two once. A card built
/// straight from JSON would either be wordless or would need those words
/// duplicated into the collectibles bank, which is the duplication the
/// pipeline exists to prevent.
@freezed
abstract class CoffeeCardModel with _$CoffeeCardModel {
  /// Creates a [CoffeeCardModel].
  const factory CoffeeCardModel({
    required String id,

    /// From the source reward.
    required String title,

    /// From the source reward's summary.
    required String description,

    /// The keepsake line the reward carries under its summary.
    required String fact,

    /// The owning module's short name — what the Cards screen groups by.
    required String moduleTag,

    /// The glyph name to draw, resolved by `moduleIcon`.
    required String iconName,

    /// The lesson that awards this card, or null when a module does.
    String? lessonId,

    /// The module that awards this card, or null when a lesson does.
    String? moduleId,
  }) = _CoffeeCardModel;
}
