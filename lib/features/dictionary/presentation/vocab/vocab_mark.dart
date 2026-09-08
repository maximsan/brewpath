import 'package:flutter/material.dart';

/// The design's drawing box, which every coordinate below is in.
const double _viewBox = 20;

/// The bubble, as a rectangle plus the tail hanging off its bottom edge.
const double _left = 3.5;
const double _top = 4.5;
const double _width = 13;
const double _height = 9;

/// Where the tail leaves the bottom edge, measured in from the right.
const double _tailInset = 7.5;

/// How far the tail runs down and to the left before turning back.
const double _tailRun = 3;

/// The bubble's stroke, and the lighter one the question mark takes.
const double _bubbleStroke = 1.4;
const double _markStroke = 1.3;

/// The full stop under the question mark.
const Offset _dot = Offset(10.2, 11.5);
const double _dotRadius = 0.8;

/// The hook of the question mark, transcribed control point for control point
/// from the design source. Three cubic segments, each `(control, control,
/// end)`, walked from [_hookStart].
const Offset _hookStart = Offset(8.6, 7.6);
const List<(Offset, Offset, Offset)> _hookCurves = [
  (Offset(8.6, 6.6), Offset(9.4, 6), Offset(10.2, 6)),
  (Offset(11.1, 6), Offset(11.8, 6.6), Offset(11.8, 7.5)),
  (Offset(11.8, 8.7), Offset(10.3, 8.8), Offset(10.3, 9.9)),
];

/// The vocab game's mark: a speech bubble with a question mark inside it —
/// a definition goes in, a term comes out.
///
/// Drawn rather than taken from the icon family, for the reason `SearchMark`
/// is: the family is the design system's asset set, and this is not one of them
/// — it is written inline in the prototype, where every practice row's mark is.
///
/// The question mark is drawn in the accent while the bubble is not, which is
/// the two-ink treatment every mark in that row shares.
class VocabMark extends StatelessWidget {
  /// Creates a [VocabMark].
  const VocabMark({
    required this.size,
    required this.color,
    required this.accent,
    super.key,
  });

  /// The mark's drawn size.
  final double size;

  /// The bubble's ink.
  final Color color;

  /// The question mark's ink.
  final Color accent;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _VocabPainter(color: color, accent: accent),
    ),
  );
}

class _VocabPainter extends CustomPainter {
  const _VocabPainter({required this.color, required this.accent});

  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    Offset at(double x, double y) => Offset(x * scale, y * scale);

    const right = _left + _width;
    const bottom = _top + _height;
    const tailX = right - _tailInset;

    final bubble = Path()
      ..moveTo(at(_left, _top).dx, at(_left, _top).dy)
      ..lineTo(at(right, _top).dx, at(right, _top).dy)
      ..lineTo(at(right, bottom).dx, at(right, bottom).dy)
      ..lineTo(at(tailX, bottom).dx, at(tailX, bottom).dy)
      ..lineTo(
        at(tailX - _tailRun, bottom + _tailRun).dx,
        at(tailX - _tailRun, bottom + _tailRun).dy,
      )
      ..lineTo(at(tailX - _tailRun, bottom).dx, at(tailX - _tailRun, bottom).dy)
      ..close();

    canvas
      ..drawPath(bubble, _stroke(color, _bubbleStroke, scale))
      ..drawPath(_questionMark(at), _stroke(accent, _markStroke, scale))
      ..drawCircle(
        at(_dot.dx, _dot.dy),
        _dotRadius * scale,
        Paint()..color = accent,
      );
  }

  /// The hook of the question mark, walked from its transcribed table.
  Path _questionMark(Offset Function(double, double) at) {
    Offset on(Offset point) => at(point.dx, point.dy);

    final path = Path()..moveTo(on(_hookStart).dx, on(_hookStart).dy);
    for (final (first, second, end) in _hookCurves) {
      path.cubicTo(
        on(first).dx,
        on(first).dy,
        on(second).dx,
        on(second).dy,
        on(end).dx,
        on(end).dy,
      );
    }
    return path;
  }

  Paint _stroke(Color ink, double width, double scale) => Paint()
    ..color = ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = width * scale
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  @override
  bool shouldRepaint(_VocabPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.accent != accent;
}
