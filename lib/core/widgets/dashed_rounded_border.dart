import 'package:brew_path/core/widgets/dash_runs.dart';
import 'package:flutter/material.dart';

/// A rounded border drawn as dashes rather than a solid line. Flutter has no
/// dashed [BorderSide], so this walks its own outline and paints the segments
/// [dashRuns] hands back. Give the button `side: BorderSide.none` when using
/// this as its shape, or it paints a solid border under the dashes.
@immutable
class DashedRoundedBorder extends OutlinedBorder {
  /// Creates a [DashedRoundedBorder].
  const DashedRoundedBorder({
    required this.radius,
    required super.side,
    this.dashLength = dashPatternLength,
    this.dashGap = dashPatternGap,
  });

  /// Corner radius of the outline.
  final double radius;

  /// Length of one drawn dash.
  final double dashLength;

  /// Gap between dashes.
  final double dashGap;

  RRect _rrect(Rect rect) =>
      RRect.fromRectAndRadius(rect, Radius.circular(radius));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_rrect(rect));

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_rrect(rect).deflate(side.width));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;

    final outline = Path()..addRRect(_rrect(rect).deflate(side.width / 2));
    final paint = side.toPaint()..style = PaintingStyle.stroke;

    for (final metric in outline.computeMetrics()) {
      for (final run in dashRuns(
        metric.length,
        dash: dashLength,
        gap: dashGap,
      )) {
        canvas.drawPath(metric.extractPath(run.from, run.to), paint);
      }
    }
  }

  @override
  DashedRoundedBorder copyWith({BorderSide? side}) => DashedRoundedBorder(
    radius: radius,
    side: side ?? this.side,
    dashLength: dashLength,
    dashGap: dashGap,
  );

  @override
  ShapeBorder scale(double factor) => DashedRoundedBorder(
    radius: radius * factor,
    side: side.scale(factor),
    dashLength: dashLength * factor,
    dashGap: dashGap * factor,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashedRoundedBorder &&
          other.radius == radius &&
          other.side == side &&
          other.dashLength == dashLength &&
          other.dashGap == dashGap;

  @override
  int get hashCode => Object.hash(radius, side, dashLength, dashGap);
}
