import 'package:flutter/material.dart';

/// The steam mark — three curls rising off a cup, the design's glyph for a
/// live streak.
///
/// Not part of the ported icon family (#378): the design draws it inline in
/// `screens.jsx:141-149` rather than in `ds-content.js`, so it has no
/// `AppIcon` to read. Transcribed from those three paths on a 26×16 canvas.
///
/// The colour is passed in rather than read from the theme, so the painter
/// needs no `BuildContext` — the same rule `FreezeMark` follows.
class SteamMark extends StatelessWidget {
  /// Creates a [SteamMark].
  const SteamMark({required this.color, this.width = defaultWidth, super.key});

  /// The design's default width.
  static const double defaultWidth = 26;

  /// The design's canvas is 26 wide by 16 tall, so height follows width.
  static const double _aspect = 16 / 26;

  /// Curl colour.
  final Color color;

  /// Width of the box the three curls are drawn in.
  final double width;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * _aspect),
      painter: _SteamPainter(color),
    );
  }
}

class _SteamPainter extends CustomPainter {
  const _SteamPainter(this.color);

  final Color color;

  /// The design's viewBox, which every coordinate below is written in.
  static const Size _viewBox = Size(26, 16);

  /// The design's `stroke-width`, in viewBox units.
  static const double _strokeWidth = 1.6;

  /// Where each curl starts, in viewBox units. The design draws three at 6, 13
  /// and 20 — evenly spaced, and the reason the mark reads as steam rather
  /// than as one stray stroke.
  static const List<double> _curlOrigins = [6, 13, 20];

  /// A curl's geometry, all in viewBox units: it rises from [_curlFoot] to
  /// [_curlTip], bending left by [_leanOut] on the way to [_curlWaist] and back
  /// right by [_leanIn] above it. The two opposed bends are what make the
  /// stroke read as rising rather than as a bracket.
  static const double _curlFoot = 15;
  static const double _curlWaist = 6;
  static const double _curlTip = 1;
  static const double _leanOut = 3;
  static const double _leanIn = 2;

  /// Where each bend peaks, between the foot and the waist and between the
  /// waist and the tip.
  static const double _lowerBend = 10;
  static const double _upperBend = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox.width;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _strokeWidth * scale;

    canvas.save();
    canvas.scale(scale);
    for (final origin in _curlOrigins) {
      canvas.drawPath(_curl(origin), paint);
    }
    canvas.restore();
  }

  /// One curl, transcribed from `M x 15 Q x-3 10 x 6 Q x+2 3 x 1`.
  Path _curl(double x) => Path()
    ..moveTo(x, _curlFoot)
    ..quadraticBezierTo(x - _leanOut, _lowerBend, x, _curlWaist)
    ..quadraticBezierTo(x + _leanIn, _upperBend, x, _curlTip);

  @override
  bool shouldRepaint(_SteamPainter oldDelegate) => oldDelegate.color != color;
}
