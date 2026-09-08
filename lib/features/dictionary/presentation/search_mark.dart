import 'package:flutter/material.dart';

/// The glass's radius and the handle's reach, from the design's own drawing at
/// its 20-unit box.
const double _viewBox = 20;
const double _circleRadius = 6;
const double _circleCentre = 9;
const double _handleStart = 13.5;
const double _handleEnd = 17;

/// The family's stroke, which every mark in the app is drawn at.
const double _stroke = 1.6;

/// The design's search mark.
///
/// Drawn rather than taken from the icon family: the family is the design
/// system's 37 marks, and this is not one of them — it is a one-off on the
/// dictionary's search field, written inline in the prototype.
///
/// Material's `Icons.search` is a different glass — a shorter handle at a
/// different angle, and a stroke that does not match the marks beside it.
class SearchMark extends StatelessWidget {
  /// Creates a [SearchMark].
  const SearchMark({required this.size, required this.color, super.key});

  /// The mark's drawn size.
  final double size;

  /// Its ink.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _SearchPainter(color)),
    );
  }
}

class _SearchPainter extends CustomPainter {
  const _SearchPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke * scale
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawCircle(
        Offset(_circleCentre * scale, _circleCentre * scale),
        _circleRadius * scale,
        paint,
      )
      ..drawLine(
        Offset(_handleStart * scale, _handleStart * scale),
        Offset(_handleEnd * scale, _handleEnd * scale),
        paint,
      );
  }

  @override
  bool shouldRepaint(_SearchPainter oldDelegate) => oldDelegate.color != color;
}
