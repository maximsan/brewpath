import 'package:brew_path/features/path/presentation/guide_marks/guide_mark.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:flutter/material.dart';

/// Grind size: coarse, medium, fine — three columns of shrinking dots.
///
/// The particle count rises as the size falls, which is the whole idea the
/// guide is about, drawn rather than stated.
class GrindMark extends GuideMark {
  /// Creates a [GrindMark].
  const GrindMark(super.mood);

  @override
  void paint(Canvas canvas, Size size) {
    // Coarse to fine: fewer, bigger → more, smaller.
    const columns = [
      (rows: 2, radius: 0.09),
      (rows: 3, radius: 0.06),
      (
        rows: 4,
        radius: 0.04,
      ),
    ];
    final gap = size.width / (columns.length + 1);
    final paint = Paint()..color = ArtColors.roastDeep;

    for (var column = 0; column < columns.length; column++) {
      final spec = columns[column];
      final x = gap * (column + 1);
      final radius = size.shortestSide * spec.radius;
      final span = size.height * 0.62;
      final step = span / (spec.rows - 1);

      for (var row = 0; row < spec.rows; row++) {
        canvas.drawCircle(
          Offset(x, size.height * 0.19 + step * row),
          radius,
          paint,
        );
      }
    }
  }
}

/// Particle distribution: a blade's wide spread against a burr's tight band.
///
/// Two curves over one axis — the shape of the difference, which is what the
/// guide exists to make recognisable.
class DistributionMark extends GuideMark {
  /// Creates a [DistributionMark].
  const DistributionMark(super.mood);

  @override
  void paint(Canvas canvas, Size size) {
    // Blade: low and wide. Burr: one tight peak.
    _curve(canvas, size, spread: 0.34, peak: 0.42, color: mood.inkMute);
    _curve(canvas, size, spread: 0.1, peak: 0.72, color: ArtColors.raw);
    canvas.drawLine(
      Offset(size.width * 0.08, _floorOf(size)),
      Offset(size.width * 0.92, _floorOf(size)),
      Paint()
        ..color = mood.rule
        ..strokeWidth = size.shortestSide * 0.02,
    );
  }

  /// The axis both curves stand on.
  double _floorOf(Size size) => size.height * 0.82;

  /// One bell over the axis, [spread] wide and [peak] tall, both fractions.
  void _curve(
    Canvas canvas,
    Size size, {
    required double spread,
    required double peak,
    required Color color,
  }) {
    final floor = _floorOf(size);
    final centre = size.width / 2;
    final width = size.width * spread;
    final height = size.height * peak;
    final path = Path()
      ..moveTo(centre - width * 1.6, floor)
      ..cubicTo(
        centre - width,
        floor - height,
        centre + width,
        floor - height,
        centre + width * 1.6,
        floor,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.045,
    );
  }
}
