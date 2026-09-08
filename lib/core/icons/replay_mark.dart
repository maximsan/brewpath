import 'package:flutter/material.dart';

/// The design's drawing box, which every coordinate below is in.
const double _viewBox = 20;

/// The arc: most of a circle, open at the top right where the head sits.
const Offset _arcStart = Offset(15.5, 6.5);
const Offset _arcEnd = Offset(16, 10);
const double _arcRadius = 6;

/// The arrowhead, drawn as the two edges that meet at its tip.
const Offset _headStart = Offset(15.8, 4);
const Offset _headTip = Offset(16, 6.8);
const Offset _headEnd = Offset(13.2, 6.6);

/// The design's `strokeWidth="1.5"`.
const double _stroke = 1.5;

/// The replay arrow a practice row ends in — a circle nearly closed, with an
/// arrowhead where it opens.
///
/// Drawn rather than taken from the icon family, the same call `FlashcardsMark`
/// and `VocabMark` make: the family is the design system's asset set and this
/// is not one of them — the design draws it inline, in the row it belongs to.
/// Nor is it the family's `rematch`, which is two arrows chasing each other:
/// that mark means *play them again*, this one means *play it again*.
class ReplayMark extends StatelessWidget {
  /// Creates a [ReplayMark].
  const ReplayMark({required this.size, required this.color, super.key});

  /// Rendered width and height; the mark is square.
  final double size;

  /// The stroke.
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _ReplayMarkPainter(color: color)),
  );
}

class _ReplayMarkPainter extends CustomPainter {
  const _ReplayMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // `A6 6 0 1 0 16 10`: the large arc, swept counter-clockwise.
    final arc = Path()
      ..moveTo(_arcStart.dx * scale, _arcStart.dy * scale)
      ..arcToPoint(
        _arcEnd * scale,
        radius: Radius.circular(_arcRadius * scale),
        largeArc: true,
        clockwise: false,
      );
    final head = Path()
      ..moveTo(_headStart.dx * scale, _headStart.dy * scale)
      ..lineTo(_headTip.dx * scale, _headTip.dy * scale)
      ..lineTo(_headEnd.dx * scale, _headEnd.dy * scale);

    canvas
      ..drawPath(arc, paint)
      ..drawPath(head, paint);
  }

  @override
  bool shouldRepaint(_ReplayMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
