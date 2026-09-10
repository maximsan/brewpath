import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'companion_option.freezed.dart';
part 'companion_option.g.dart';

/// One pick on one of Roasty's four outfit axes, as the extractor emits it.
///
/// Words only. What each id *looks like* is vector geometry the app draws, so
/// the art is keyed by [id] rather than carried here — see `roastyOutfitArt`
/// and the guard test that holds the two in step.
@freezed
abstract class CompanionOption with _$CompanionOption {
  /// Creates a [CompanionOption].
  const factory CompanionOption({
    required String id,
    required String label,

    /// Swatch colour for the picker chip, as a CSS hex string. Only the roast
    /// axis carries one — a hat is shown by its drawing, not by a colour.
    String? swatch,
  }) = _CompanionOption;

  /// Creates a [CompanionOption] from decoded JSON.
  factory CompanionOption.fromJson(Map<String, dynamic> json) =>
      _$CompanionOptionFromJson(json);
}

/// The four axes together — what the Studio's Roasty section draws its rows
/// from, and the only shape any caller wants them in.
@immutable
class CompanionOptions {
  /// Creates a [CompanionOptions].
  const CompanionOptions({
    required this.roasts,
    required this.hats,
    required this.gear,
    required this.sprouts,
  });

  /// Roast levels, lightest first.
  final List<CompanionOption> roasts;

  /// Headwear, `none` first.
  final List<CompanionOption> hats;

  /// Glasses, scarf and friends, `none` first.
  final List<CompanionOption> gear;

  /// What grows from the crown.
  final List<CompanionOption> sprouts;

  /// Every id the four banks ship, for the guard that holds art in step.
  Set<String> get allIds => {
    for (final axis in [roasts, hats, gear, sprouts])
      for (final option in axis) option.id,
  };

  /// [outfit] as a line of labels: the roast, then whatever was put on.
  ///
  /// Naming the plain bean's `none`s is skipped — a resting state is not a
  /// choice, and reading it back as one would say it was.
  String labelLine(CompanionConfig outfit) => [
    _labelOf(roasts, outfit.roast),
    if (outfit.hat != CompanionConfig.initial.hat) _labelOf(hats, outfit.hat),
    if (outfit.gear != CompanionConfig.initial.gear)
      _labelOf(gear, outfit.gear),
    if (outfit.sprout != CompanionConfig.initial.sprout)
      _labelOf(sprouts, outfit.sprout),
  ].whereType<String>().join(' · ');

  /// The label the bank gives [id], or null when it ships no such option.
  static String? _labelOf(List<CompanionOption> axis, String id) =>
      axis.where((option) => option.id == id).firstOrNull?.label;
}
