import 'package:flutter/material.dart';

/// The design's drawing box, which every coordinate below is in.
const double _viewBox = 24;

/// The front card: the one with lines on it.
const Rect _front = Rect.fromLTWH(3, 6, 14, 12);
const double _frontRadius = 2;

/// The two rules of text on it, each a run from x to x at one height.
const List<(double, double, double)> _lines = [(7, 13, 9.5), (7, 11, 12.5)];

/// The card behind, drawn as the two edges of it that show: right and along
/// the top. It stops at the front card's corner rather than being a second
/// rectangle, which is what makes the pair read as a deck seen at an angle.
const Offset _backStart = Offset(9, 4.5);
const double _backCorner = 2;
const double _backRight = 20;
const double _backBottom = 15;

/// The strokes: the card's own, and the lighter one its lines and the card
/// behind take.
const double _cardStroke = 1.6;
const double _detailStroke = 1.4;

/// How much of the accent the card behind keeps — the design's `opacity: 0.5`,
/// which is what puts it *behind* rather than beside.
const double _backOpacity = 0.5;

/// The flashcards mark: a card with a line of text, and another behind it.
///
/// Drawn rather than taken from the icon family, the same call `SearchMark`
/// and `VocabMark` make: the family is the design system's asset set and this
/// is not one of them — the design draws it inline, in the chip row it
/// belongs to.
class FlashcardsMark extends StatelessWidget {
  /// Creates a [FlashcardsMark].
  const FlashcardsMark({
    required this.size,
    required this.color,
    required this.accent,
    super.key,
  });

  /// Rendered width and height; the mark is square.
  final double size;

  /// The front card's stroke.
  final Color color;

  /// The card behind it, which the design draws in the accent at half weight.
  final Color accent;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _FlashcardsMarkPainter(color: color, accent: accent),
    ),
  );
}

class _FlashcardsMarkPainter extends CustomPainter {
  const _FlashcardsMarkPainter({required this.color, required this.accent});

  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    canvas.scale(scale);

    final card = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = color
      ..strokeWidth = _cardStroke;
    final detail = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = color
      ..strokeWidth = _detailStroke;
    final behind = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: _backOpacity)
      ..strokeWidth = _detailStroke;

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(_front, const Radius.circular(_frontRadius)),
        card,
      )
      ..drawPath(_backEdges(), behind);
    for (final (from, to, y) in _lines) {
      canvas.drawLine(Offset(from, y), Offset(to, y), detail);
    }
  }

  /// The two edges of the card behind, with its rounded top-right corner.
  Path _backEdges() => Path()
    ..moveTo(_backStart.dx, _backStart.dy)
    ..lineTo(_backRight - _backCorner, _backStart.dy)
    ..quadraticBezierTo(
      _backRight,
      _backStart.dy,
      _backRight,
      _backStart.dy + _backCorner,
    )
    ..lineTo(_backRight, _backBottom);

  @override
  bool shouldRepaint(_FlashcardsMarkPainter old) =>
      old.color != color || old.accent != accent;
}
