import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// The coffee-bean silhouette every bean drawing in the app is cut from.
///
/// Geometry transcribed from `prototype/flavor-wheel.jsx`: a 24×24 authoring
/// box holding an ellipse of rx 7.5 / ry 9.5 tilted −18°, with a wavy centre
/// crease. It lives here rather than inside one painter because the design
/// draws the *same* bean twice over with two different meanings — the mastery
/// gauge fills it, the roast meter roasts it — and a second transcription is a
/// second chance for one of them to drift off the design source.
///
/// Paths are built around the origin, because [applyTo] has already centred and
/// tilted the canvas by the time a painter asks for one.
abstract final class BeanShape {
  /// The design's authoring box; every dimension here is in its units.
  static const double viewBox = 24;

  /// Half-width of the bean.
  static const double radiusX = 7.5;

  /// Half-height of the bean.
  static const double radiusY = 9.5;

  /// The design's `rotate(-18 12 12)`.
  static const double tiltRadians = -18 * math.pi / 180;

  /// The bean's bounds, centred on the origin.
  static Rect get oval => Rect.fromCenter(
    center: Offset.zero,
    width: radiusX * 2,
    height: radiusY * 2,
  );

  /// The bean's outline.
  static Path ovalPath() => Path()..addOval(oval);

  /// The bean's centre groove — the design's
  /// `M12 3.5 C 13.5 7, 10.5 9, 12 12 S 13.5 17, 12 20.5`, re-expressed around
  /// the origin because the canvas is already centred and tilted.
  static Path creasePath() {
    const halfBox = viewBox / 2;
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

  /// Scales [canvas] from the authoring box onto a widget of [size], then
  /// centres and tilts it so the paths above land where the design puts them.
  ///
  /// The caller owns the `save`/`restore` around this — a painter usually has
  /// more to draw once the bean is done.
  static void applyTo(Canvas canvas, Size size) {
    canvas.scale(size.width / viewBox);
    canvas.translate(viewBox / 2, viewBox / 2);
    canvas.rotate(tiltRadians);
  }
}
