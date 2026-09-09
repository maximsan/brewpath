import 'package:freezed_annotation/freezed_annotation.dart';

part 'coffee_card_model.freezed.dart';

/// A collectible card as the screens show it: the bank's record joined to the
/// words of whatever unlocks it.
///
/// **Assembled, never parsed.** No bank record holds a card's text, so there
/// is no `fromJson` — the collectible supplies the id and the illustration
/// key, its source supplies the words, and the content layer joins them once.
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

    /// What the card is *of* — `botanical`, `burrs`, `roastcurve`. The
    /// collectible's own key, not its module's: it is what the design tints
    /// the tile by, and eventually what it draws there.
    required String kind,

    /// The lesson that awards this card, or null when a module does.
    String? lessonId,

    /// The module that awards this card, or null when a lesson does.
    String? moduleId,
  }) = _CoffeeCardModel;

  const CoffeeCardModel._();

  /// Whether this is one of the five Module Rewards.
  ///
  /// [moduleId] carries the collectibles bank's own `unlock.module` pointer
  /// and nothing else writes it, so only a module-awarded card has one — a
  /// lesson card's owning module lives in [moduleTag].
  bool get isModuleReward => moduleId != null;
}
