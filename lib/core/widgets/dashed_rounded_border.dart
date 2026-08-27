import 'package:flutter/material.dart';

/// Length of one drawn dash.
const double _dashLength = 5;

/// Gap between dashes.
const double _dashGap = 4;

/// A rounded border drawn as dashes rather than a solid line.
///
/// Flutter has no dashed [BorderSide], so the design's dashed states need a
/// shape that walks its own outline and paints segments of it. It is an
/// [OutlinedBorder] so it drops into anything that takes a shape — an
/// `OutlinedButton`, or a `ShapeDecoration` on a plain box.
///
/// Give the button `side: BorderSide.none` when using this as its shape:
/// the button would otherwise paint a solid border underneath the dashes.
@immutable
class DashedRoundedBorder extends OutlinedBorder {
  /// Creates a [DashedRoundedBorder].
  const DashedRoundedBorder({
    required this.radius,
    required super.side,
    this.dashLength = _dashLength,
    this.dashGap = _dashGap,
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
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + dashGap;
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
  ShapeBorder scale(double t) => DashedRoundedBorder(
    radius: radius * t,
    side: side.scale(t),
    dashLength: dashLength * t,
    dashGap: dashGap * t,
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
