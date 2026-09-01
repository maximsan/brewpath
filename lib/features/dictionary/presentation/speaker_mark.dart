import 'package:flutter/material.dart';

/// The design's speaker, at its own 20-unit box (`dictionary.jsx:39`).
const double _viewBox = 20;

/// The cone: a rectangle at the left, opening into the triangle.
const double _coneLeft = 4;
const double _coneNeck = 6.5;
const double _coneTop = 8;
const double _coneBottom = 12;
const double _conePoint = 10;
const double _conePointTop = 4.5;
const double _conePointBottom = 15.5;
const double _coneStroke = 1.1;

/// The near wave, always drawn; and the far one, only while the word plays.
const double _wavesStroke = 1.4;
const double _nearWaveX = 13;
const double _nearWaveTop = 7.5;
const double _nearWaveBottom = 12.5;
const double _nearWaveRadius = 3.5;
const double _farWaveX = 15;
const double _farWaveTop = 5.5;
const double _farWaveBottom = 14.5;
const double _farWaveRadius = 6;

/// How faint the near wave sits at rest.
const double _restingWaveOpacity = 0.7;

/// The design's speaker mark, with the second wave that appears while a word
/// is being spoken.
///
/// Drawn rather than taken from the icon family for the same reason
/// `SearchMark` is: the family is the design system's 37 marks, and this is a
/// one-off written inline on the pronunciation chip.
class SpeakerMark extends StatelessWidget {
  /// Creates a [SpeakerMark].
  const SpeakerMark({
    required this.size,
    required this.color,
    this.speaking = false,
    super.key,
  });

  /// The mark's drawn size.
  final double size;

  /// Its ink.
  final Color color;

  /// Whether the far wave is showing — the design's pulse.
  final bool speaking;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _SpeakerPainter(color: color, speaking: speaking),
      ),
    );
  }
}

class _SpeakerPainter extends CustomPainter {
  const _SpeakerPainter({required this.color, required this.speaking});

  final Color color;
  final bool speaking;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    final cone = Path()
      ..moveTo(_coneLeft * scale, _coneTop * scale)
      ..lineTo(_coneNeck * scale, _coneTop * scale)
      ..lineTo(_conePoint * scale, _conePointTop * scale)
      ..lineTo(_conePoint * scale, _conePointBottom * scale)
      ..lineTo(_coneNeck * scale, _coneBottom * scale)
      ..lineTo(_coneLeft * scale, _coneBottom * scale)
      ..close();

    canvas
      ..drawPath(cone, Paint()..color = color)
      ..drawPath(
        cone,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _coneStroke * scale
          ..strokeJoin = StrokeJoin.round,
      )
      ..drawPath(
        _wave(
          scale: scale,
          x: _nearWaveX,
          top: _nearWaveTop,
          bottom: _nearWaveBottom,
          radius: _nearWaveRadius,
        ),
        _wavePaint(scale, speaking ? 1 : _restingWaveOpacity),
      );

    if (speaking) {
      canvas.drawPath(
        _wave(
          scale: scale,
          x: _farWaveX,
          top: _farWaveTop,
          bottom: _farWaveBottom,
          radius: _farWaveRadius,
        ),
        _wavePaint(scale, 1),
      );
    }
  }

  Path _wave({
    required double scale,
    required double x,
    required double top,
    required double bottom,
    required double radius,
  }) => Path()
    ..moveTo(x * scale, top * scale)
    ..arcToPoint(
      Offset(x * scale, bottom * scale),
      radius: Radius.circular(radius * scale),
    );

  Paint _wavePaint(double scale, double opacity) => Paint()
    ..color = color.withValues(alpha: opacity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = _wavesStroke * scale
    ..strokeCap = StrokeCap.round;

  @override
  bool shouldRepaint(_SpeakerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.speaking != speaking;
}
