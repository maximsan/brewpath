import 'package:flutter/material.dart';

/// A coffee bean that fills bottom-up — the design's `FlavorWheel`.
///
/// The bean **is** the gauge: mastery reads as "how full" rather than as a
/// word in the margin. Geometry is transcribed from
/// `brew-path/flavor-wheel.jsx`: a 24×24 box holding an ellipse of rx 7.5 /
/// ry 9.5 tilted −18°, a fill clipped to that ellipse and grown from the
/// bottom, and a wavy centre crease.
///
/// Colours are passed in rather than read from `context.mood`, so the painter
/// needs no `BuildContext` and the widget stays testable against explicit
/// values.
class BeanGauge extends StatelessWidget {
  /// Creates a [BeanGauge] filled to [fill] (clamped to `0..1`).
  const BeanGauge({
    required this.fill,
    required this.color,
    required this.muted,
    required this.ink,
    this.size = _defaultSize,
    super.key,
  });

  /// How full the bean is, `0..1`.
  final double fill;

  /// The fill colour, and the outline once the bean is full.
  final Color color;

  /// Outline and crease colour while the bean is not full.
  final Color muted;

  /// Ink used for the outline and crease of a full bean, so a solid fill never
  /// dissolves the silhouette into one flat blob.
  final Color ink;

  /// Rendered width and height; the bean is always square.
  final double size;

  static const double _defaultSize = 20;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _BeanGaugePainter(
          fill: fill.clamp(0.0, 1.0),
          color: color,
          muted: muted,
          ink: ink,
        ),
      ),
    );
  }
}

class _BeanGaugePainter extends CustomPainter {
  const _BeanGaugePainter({
    required this.fill,
    required this.color,
    required this.muted,
    required this.ink,
  });

  final double fill;
  final Color color;
  final Color muted;
  final Color ink;

  /// The design's 24×24 authoring box; every dimension below is in its units
  /// and scaled to the widget's actual size on paint.
  static const double _viewBox = 24;
  static const double _radiusX = 7.5;
  static const double _radiusY = 9.5;
  static const double _tiltRadians = -18 * 3.1415926535897932 / 180;
  static const double _strokeWidth = 1;

  /// Above this the fill is dark enough that a muted crease stops reading, so
  /// the crease flips to ink.
  static const double _creaseInkThreshold = 0.6;

  /// Crease stroke multipliers either side of a full bean.
  static const double _fullCreaseScale = 1.15;
  static const double _partialCreaseScale = 0.9;

  bool get _isFull => fill >= 1;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    canvas
      ..save()
      ..scale(scale)
      ..translate(_viewBox / 2, _viewBox / 2)
      ..rotate(_tiltRadians);

    final bean = Rect.fromCenter(
      center: Offset.zero,
      width: _radiusX * 2,
      height: _radiusY * 2,
    );
    final beanPath = Path()..addOval(bean);

    // Fill, clipped to the bean and grown from the bottom so a partial score
    // reads as a level rather than a wedge.
    if (fill > 0) {
      canvas
        ..save()
        ..clipPath(beanPath)
        ..drawRect(
          Rect.fromLTRB(
            bean.left,
            bean.bottom - bean.height * fill,
            bean.right,
            bean.bottom,
          ),
          Paint()..color = color,
        )
        ..restore();
    }

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..color = _isFull ? ink : muted;
    canvas.drawPath(beanPath, outline);

    final creaseColor = _isFull || fill > _creaseInkThreshold ? ink : muted;
    final crease = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth =
          _strokeWidth * (_isFull ? _fullCreaseScale : _partialCreaseScale)
      ..color = creaseColor;
    canvas.drawPath(_creasePath(), crease);

    canvas.restore();
  }

  /// The bean's centre groove — the design's
  /// `M12 3.5 C 13.5 7, 10.5 9, 12 12 S 13.5 17, 12 20.5`, re-expressed
  /// around the origin because the canvas is already centred and tilted.
  Path _creasePath() {
    const halfBox = _viewBox / 2;
    Offset at(double x, double y) => Offset(x - halfBox, y - halfBox);

    return Path()
      ..moveTo(at(12, 3.5).dx, at(12, 3.5).dy)
      ..cubicTo(
        at(13.5, 7).dx,
        at(13.5, 7).dy,
        at(10.5, 9).dx,
        at(10.5, 9).dy,
        at(12, 12).dx,
        at(12, 12).dy,
      )
      // The SVG `S` command mirrors the previous control point through the
      // current one: (10.5, 9) reflected about (12, 12) is (13.5, 15).
      ..cubicTo(
        at(13.5, 15).dx,
        at(13.5, 15).dy,
        at(13.5, 17).dx,
        at(13.5, 17).dy,
        at(12, 20.5).dx,
        at(12, 20.5).dy,
      );
  }

  @override
  bool shouldRepaint(_BeanGaugePainter old) =>
      old.fill != fill ||
      old.color != color ||
      old.muted != muted ||
      old.ink != ink;
}
