import 'package:brew_path/core/widgets/guide_marks/guide_mark.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:flutter/material.dart';

/// Roast levels: three beans, light to dark.
///
/// The palette's own roast ramp, so the swatches and the lesson that teaches
/// them cannot disagree about what "medium" looks like.
class RoastMark extends GuideMark {
  /// Creates a [RoastMark].
  const RoastMark(super.mood);

  @override
  void paint(Canvas canvas, Size size) {
    const shown = [
      ArtColors.roastLight,
      ArtColors.roastMid,
      ArtColors.roastDark,
    ];
    final radius = size.width / (shown.length * 2.6);
    final gap = size.width / (shown.length + 1);

    for (var index = 0; index < shown.length; index++) {
      final centre = Offset(gap * (index + 1), size.height / 2);
      canvas.drawCircle(centre, radius, Paint()..color = shown[index]);
      // The crease, so a circle reads as a bean.
      canvas.drawLine(
        Offset(centre.dx, centre.dy - radius * 0.72),
        Offset(centre.dx, centre.dy + radius * 0.72),
        Paint()
          ..color = ArtColors.seedCrease
          ..strokeWidth = size.shortestSide * 0.022,
      );
    }
  }
}

/// Caffeine per serving: three bars, shortest to longest.
///
/// Wordless on purpose — which serving is which is the guide's meta table's
/// job, and the shape alone carries "a small strong cup is not the most".
class CaffeineMark extends GuideMark {
  /// Creates a [CaffeineMark].
  const CaffeineMark(super.mood);

  @override
  void paint(Canvas canvas, Size size) {
    // Espresso, drip, cold brew — the order the guide lists them.
    const heights = [0.38, 0.62, 1.0];
    final barWidth = size.width / (heights.length * 2);
    final gap = size.width / (heights.length + 1);
    final floor = size.height * 0.88;

    for (var index = 0; index < heights.length; index++) {
      final height = (floor - size.height * 0.12) * heights[index];
      paintBar(
        canvas,
        Rect.fromLTWH(
          gap * (index + 1) - barWidth / 2,
          floor - height,
          barWidth,
          height,
        ),
        index == heights.length - 1 ? ArtColors.roastDeep : ArtColors.roastMid,
      );
    }
  }
}
