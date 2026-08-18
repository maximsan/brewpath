import 'package:freezed_annotation/freezed_annotation.dart';

part 'mini_game_format.freezed.dart';
part 'mini_game_format.g.dart';

/// One entry in the mini-game catalog, as the extractor emits it.
///
/// Field names carry the prototype's vocabulary on the wire — `sub` is the
/// topic the game drills and `meta` its time estimate — and are remapped to
/// idiomatic Dart here, the same discipline `ContentCard` follows.
@freezed
abstract class MiniGameFormat with _$MiniGameFormat {
  /// Creates a [MiniGameFormat].
  const factory MiniGameFormat({
    required String id,

    /// The card kind its rounds carry. Unread today — the player dispatches
    /// on the round's own kind — and kept because the extractor renames and
    /// drops nothing, so the model mirrors the bank.
    required String kind,
    required String title,
    @JsonKey(name: 'sub') required String topic,
    @JsonKey(name: 'meta') required String duration,
    required String blurb,
    required List<String> steps,
  }) = _MiniGameFormat;

  /// Creates a [MiniGameFormat] from decoded JSON.
  factory MiniGameFormat.fromJson(Map<String, dynamic> json) =>
      _$MiniGameFormatFromJson(json);
}
