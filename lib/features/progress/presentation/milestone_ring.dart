import 'dart:math';

import 'package:flutter/material.dart';

/// The milestone progress ring around the hero count.
///
/// Static by design: no fill animation exists, so reduced motion needs no
/// branch — the ring renders at its final value for everyone. Colours are
/// passed in rather than read from the theme, so the painter needs no
/// BuildContext (repo convention).
class MilestoneRing extends StatelessWidget {
  /// Creates a [MilestoneRing].
  const MilestoneRing({
    required this.fraction,
    required this.trackColor,
    required this.fillColor,
    required this.child,
    this.diameter = defaultDiameter,
    super.key,
  });

  /// Default outer size.
  static const double defaultDiameter = 176;

  /// Stroke width of both the track and the fill.
  static const double strokeWidth = 6;

  /// The painted floor, so a young streak still reads as begun.
  static const double minVisibleFraction = 0.04;

  /// Fill toward the next milestone, 0..1.
  final double fraction;

  /// The full-circle track behind the fill.
  final Color trackColor;

  /// The fill arc.
  final Color fillColor;

  /// Outer size of the ring.
  final double diameter;

  /// Centered content — the hero count.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: fraction,
          trackColor: trackColor,
          fillColor: fillColor,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.trackColor,
    required this.fillColor,
  });

  final double fraction;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - MilestoneRing.strokeWidth) / 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = MilestoneRing.strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    final clamped = fraction.clamp(MilestoneRing.minVisibleFraction, 1);
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = MilestoneRing.strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = fillColor;
    const startAngle = -pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * pi * clamped,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor;
}
