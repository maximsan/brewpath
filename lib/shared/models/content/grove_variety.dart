import 'package:freezed_annotation/freezed_annotation.dart';

part 'grove_variety.freezed.dart';
part 'grove_variety.g.dart';

/// One coffee species a learner can plant, as the extractor emits it.
///
/// The copy is real botany rather than decoration: a species is a fact the
/// course itself teaches (Arabica vs Robusta is a lesson), which is what earns
/// the grove its place as the one cosmetic surface that reinforces content.
@freezed
abstract class GroveVariety with _$GroveVariety {
  /// Creates a [GroveVariety].
  const factory GroveVariety({
    required String id,
    required String name,

    /// The binomial, e.g. `Coffea arabica`.
    required String latin,

    /// Share of the world's cups, as authored prose (`~60%`).
    required String share,

    /// What the bean gets brewed as — the same question for all three.
    required String use,
    required String origin,

    /// Growing conditions, as authored prose (`High and cool`).
    required String grows,

    /// The cup profile — the chooser's "Tastes like".
    required String cup,

    /// The plant's body plus one consequence worth remembering. Carries what
    /// the spec strip cannot: what the tree actually looks like.
    required String tell,

    /// Anisotropic scale distinguishing this species' silhouette, or `none`
    /// for the species drawn as-is. The interim treatment until bespoke art
    /// lands (#87).
    required String shape,

    /// Leaf-tone filter chain composed under the chosen light, empty for the
    /// species whose art is already the real one.
    required String leaf,

    /// The prototype's art-pipeline rollout note.
    ///
    /// Emitted because the extractor renames and drops nothing, and **read by
    /// nothing**: all three species ship, and a flag in the source must not be
    /// able to re-defer a decided launch.
    required String drop,
  }) = _GroveVariety;

  /// Creates a [GroveVariety] from decoded JSON.
  factory GroveVariety.fromJson(Map<String, dynamic> json) =>
      _$GroveVarietyFromJson(json);
}
