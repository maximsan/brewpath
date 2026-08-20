import 'package:freezed_annotation/freezed_annotation.dart';

part 'collectible.freezed.dart';
part 'collectible.g.dart';

/// What earns a collectible: exactly one of a lesson or a module.
///
/// The pointer runs this way round — from the collectible to its source —
/// which is why resolving *the card a lesson awards* is a reverse lookup. The
/// extractor guarantees exactly one side is set; [isValid] is the same claim,
/// checked where the app can act on it rather than assumed.
@freezed
abstract class CollectibleUnlock with _$CollectibleUnlock {
  /// Creates a [CollectibleUnlock].
  const factory CollectibleUnlock({
    @JsonKey(name: 'lesson') String? lessonId,
    @JsonKey(name: 'module') String? moduleId,
  }) = _CollectibleUnlock;

  const CollectibleUnlock._();

  /// Creates a [CollectibleUnlock] from decoded JSON.
  factory CollectibleUnlock.fromJson(Map<String, dynamic> json) =>
      _$CollectibleUnlockFromJson(json);

  /// Whether exactly one source is named.
  bool get isValid => (lessonId == null) != (moduleId == null);
}

/// One collectible card, as the bank stores it.
///
/// **It carries no words.** Title, summary and fact come from the reward of
/// whatever unlocks it, so the text lives in exactly one place. The bank's
/// `earned` flag is prototype demo state and is deliberately not modelled —
/// what a learner owns is progress, and progress lives in the database.
@freezed
abstract class Collectible with _$Collectible {
  /// Creates a [Collectible].
  const factory Collectible({
    required String id,
    required CollectibleUnlock unlock,

    /// The card's own illustration key. Unique per collectible, so it names a
    /// specific drawing rather than a family, and the app falls back to the
    /// owning module's glyph until those drawings exist.
    required String kind,
  }) = _Collectible;

  /// Creates a [Collectible] from decoded JSON.
  factory Collectible.fromJson(Map<String, dynamic> json) =>
      _$CollectibleFromJson(json);
}
