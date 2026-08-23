import 'package:brew_path/features/path/presentation/guide_marks/guide_mark.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:flutter/material.dart';

/// The cherry in section: six rings, outside in.
///
/// The layers the course names — skin, pulp, gel, parchment, silverskin, seed
/// — drawn as concentric circles in the palette's own cherry ramp, so the
/// drawing and the lesson agree on what each layer looks like.
class AnatomyMark extends GuideMark {
  /// Creates an [AnatomyMark].
  const AnatomyMark(super.mood);

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final outer = size.shortestSide / 2 * 0.86;
    const ramp = ArtColors.cherryRamp;

    for (var layer = 0; layer < ramp.length; layer++) {
      final radius = outer * (1 - layer / ramp.length);
      canvas.drawCircle(centre, radius, Paint()..color = ramp[layer]);
    }
    // The crease down the seed, which is what makes it read as a bean.
    canvas.drawLine(
      Offset(centre.dx, centre.dy - outer / ramp.length),
      Offset(centre.dx, centre.dy + outer / ramp.length),
      Paint()
        ..color = ArtColors.seedCrease
        ..strokeWidth = size.shortestSide * 0.03,
    );
  }
}

/// The variety family tree: two old parents, three descendants below.
///
/// Typica and Bourbon at the top, the varieties the course names branching
/// from them — the shape of the idea rather than a labelled diagram.
class VarietyMark extends GuideMark {
  /// Creates a [VarietyMark].
  const VarietyMark(super.mood);

  @override
  void paint(Canvas canvas, Size size) {
    final node = size.shortestSide * 0.07;
    final parentY = size.height * 0.28;
    final childY = size.height * 0.74;
    final parents = [size.width * 0.34, size.width * 0.66];
    final children = [size.width * 0.2, size.width * 0.5, size.width * 0.8];

    final branch = Paint()
      ..color = mood.rule
      ..strokeWidth = size.shortestSide * 0.025;

    for (final childX in children) {
      final nearest = parents.reduce(
        (a, b) => (a - childX).abs() < (b - childX).abs() ? a : b,
      );
      canvas.drawLine(
        Offset(nearest, parentY),
        Offset(childX, childY),
        branch,
      );
    }
    for (final x in parents) {
      canvas.drawCircle(
        Offset(x, parentY),
        node,
        Paint()..color = ArtColors.cherrySeed,
      );
    }
    for (final x in children) {
      canvas.drawCircle(
        Offset(x, childY),
        node * 0.8,
        Paint()..color = ArtColors.raw,
      );
    }
  }
}
