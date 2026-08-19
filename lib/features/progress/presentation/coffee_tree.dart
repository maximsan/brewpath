import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:flutter/material.dart';

/// The Coffee Tree, rendered as the single still frame for [stage], wearing
/// the grove [treatment].
///
/// Deliberately decides nothing: both the stage and the treatment arrive from
/// the caller, and the treatment is already reduced to a matrix and a scale, so
/// this widget knows nothing about species or lights. Motion stays out until
/// the #88 port lands, so a still frame is the whole contract and reduced
/// motion is satisfied by construction.
class CoffeeTree extends StatelessWidget {
  /// Creates a [CoffeeTree].
  const CoffeeTree({
    required this.stage,
    this.treatment = GroveTreatment.identity,
    this.size = defaultSize,
    super.key,
  });

  /// Highest tree stage ever reached, as the snapshot stores it. Values
  /// outside the shipped frames clamp to seed and full growth.
  final int stage;

  /// The planted species' silhouette and the light it stands in, composed.
  final GroveTreatment treatment;

  /// Square edge the frame renders at.
  final double size;

  /// Hero-sized default, matching the design's preview block.
  static const double defaultSize = 176;

  @override
  Widget build(BuildContext context) {
    final frame = Image.asset(
      treeStageAsset(stage),
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: treeStageLabel(stage),
    );

    // Arabica in Daylight is the real art, so it is painted with neither
    // wrapper rather than through a matrix that happens to be the identity.
    if (treatment.isIdentity) return frame;

    return Transform.scale(
      scaleX: treatment.silhouette.scaleX,
      scaleY: treatment.silhouette.scaleY,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(treatment.colorMatrix),
        child: frame,
      ),
    );
  }
}

/// The tree's place while the stored stage is still being read.
///
/// Holds the hero's footprint so the page does not jump, and says only that a
/// tree is coming: naming a stage here would announce a number that is about
/// to change, and for a grown tree that announcement would be false.
class CoffeeTreePlaceholder extends StatelessWidget {
  /// Creates a [CoffeeTreePlaceholder].
  const CoffeeTreePlaceholder({this.size = CoffeeTree.defaultSize, super.key});

  /// Square edge the placeholder reserves, matching [CoffeeTree.size].
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your coffee tree is loading',
      child: SizedBox(width: size, height: size),
    );
  }
}
