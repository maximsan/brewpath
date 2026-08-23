import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The contract every guide's drawing meets.
///
/// **One drawing per subject, painted normalised to whatever box it is given**
/// — so the row thumbnail and the sheet illustration are the same drawing at
/// two sizes rather than two drawings that can drift apart. Every coordinate
/// below is a fraction of [Size], never a pixel.
///
/// **Wordless, deliberately.** A guide's meta rows are the textual counterpart
/// of its own diagram — `LIGHT / Bright · acidic` — so words in the art would
/// put course copy somewhere a copy fix cannot reach.
abstract class GuideMark extends CustomPainter {
  /// Creates a [GuideMark] that paints in [mood].
  const GuideMark(this.mood);

  /// The theme the drawing follows, for anything that is not fixed
  /// illustration palette.
  final MoodColors mood;

  @override
  bool shouldRepaint(covariant GuideMark oldDelegate) =>
      oldDelegate.mood != mood;
}

/// Fills a rounded bar, the shape several marks are built from.
void paintBar(Canvas canvas, Rect rect, Color color, {double radius = 2}) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, Radius.circular(radius)),
    Paint()..color = color,
  );
}
