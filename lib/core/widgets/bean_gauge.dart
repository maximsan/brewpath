import 'package:brew_path/core/widgets/bean_shape.dart';
import 'package:flutter/material.dart';

/// A coffee bean that fills bottom-up — the design's `FlavorWheel`.
///
/// The bean **is** the gauge: mastery reads as "how full" rather than as a
/// word in the margin. The silhouette it fills is [BeanShape], the same one the
/// roast meter roasts; only the meaning differs, and the two must never be read
/// for each other — this one is how well you did, that one is where you are.
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
    canvas.save();
    BeanShape.applyTo(canvas, size);

    final bean = BeanShape.oval;
    final beanPath = BeanShape.ovalPath();

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
    canvas.drawPath(BeanShape.creasePath(), crease);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BeanGaugePainter old) =>
      old.fill != fill ||
      old.color != color ||
      old.muted != muted ||
      old.ink != ink;
}
