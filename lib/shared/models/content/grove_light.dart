import 'package:freezed_annotation/freezed_annotation.dart';

part 'grove_light.freezed.dart';
part 'grove_light.g.dart';

/// One lighting treatment the grove can stand in, as the extractor emits it.
///
/// A light is a mood, not a plant — the axis exists because the design's older
/// five-skin list conflated the two and could therefore teach nothing. Any
/// light composes over any variety, so this carries no reference to one.
@freezed
abstract class GroveLight with _$GroveLight {
  /// Creates a [GroveLight].
  const factory GroveLight({
    required String id,
    required String name,

    /// The one-line mood, e.g. `Late sun`.
    required String note,

    /// Swatch colour for the picker pill, as a CSS hex string.
    required String swatch,

    /// The filter chain applied over the plant, empty for the unfiltered
    /// default. Composed with the variety's leaf tone into one treatment.
    required String filter,
  }) = _GroveLight;

  /// Creates a [GroveLight] from decoded JSON.
  factory GroveLight.fromJson(Map<String, dynamic> json) =>
      _$GroveLightFromJson(json);
}
