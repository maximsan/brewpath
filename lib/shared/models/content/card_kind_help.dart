import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_kind_help.freezed.dart';
part 'card_kind_help.g.dart';

/// How one card kind is played, as the drawer behind a card's `?` reads it.
///
/// Authored in the design and extracted verbatim, so the words a learner is
/// given for a format are the design's rather than the app's.
@freezed
abstract class CardKindHelp with _$CardKindHelp {
  /// Creates a [CardKindHelp].
  const factory CardKindHelp({
    required String kind,
    required String title,
    required String blurb,
    required List<String> steps,
  }) = _CardKindHelp;

  /// Creates a [CardKindHelp] from decoded JSON.
  factory CardKindHelp.fromJson(Map<String, dynamic> json) =>
      _$CardKindHelpFromJson(json);
}
