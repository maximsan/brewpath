import 'package:flutter/material.dart';

/// The freeze mark — one dash, one meaning: a day held rather than earned.
///
/// Shared by the week strip's covered cells and any surface that needs to
/// point at a freeze. The colour is passed in rather than read from the
/// theme, so the painter needs no BuildContext (repo convention).
class FreezeMark extends StatelessWidget {
  /// Creates a [FreezeMark].
  const FreezeMark({required this.color, this.size = defaultSize, super.key});

  /// The glyph's default edge length.
  static const double defaultSize = 12;

  /// Dash colour.
  final Color color;

  /// Edge length of the square the dash is drawn in.
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _DashPainter(color),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  /// Stroke width as a fraction of the edge, so the dash scales with its box.
  static const double _strokeFraction = 0.18;

  /// Inset of the dash ends from the corners, as a fraction of the edge.
  static const double _insetFraction = 0.2;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.width * _insetFraction;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * _strokeFraction
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(size.width - inset, inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.color != color;
}
