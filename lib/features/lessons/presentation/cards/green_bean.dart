import 'dart:math' as math;

import 'package:brew_path/features/lessons/presentation/cards/bagpick_bean_art.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:flutter/material.dart';

/// One green seed from the sample, drawn from the round's own bean attributes.
///
/// Transcribed coordinate-for-coordinate from `prototype/bean-anatomy.jsx`, in
/// the same 24×24 space, so the drawing the design reviewed is the drawing that
/// ships. Nothing here is an image asset: every round's beans differ only by
/// the four attributes the content authors, which is what lets five bags look
/// like five different lots without five illustrations.
///
/// [seed] separates the three seeds of one sample, so they mottle differently
/// while staying stable across rebuilds.
class GreenBean extends StatelessWidget {
  /// Creates a [GreenBean].
  const GreenBean({
    required this.bean,
    required this.seed,
    required this.size,
    required this.turns,
    super.key,
  });

  /// The bean this round authored.
  final BagpickBean bean;

  /// Which seed of the sample this is.
  final int seed;

  /// Width in logical pixels; the drawing is very slightly taller.
  final double size;

  /// Rotation, in turns, so each seed lies at its own angle.
  final double turns;

  /// The design's own aspect: the box is a touch taller than it is wide.
  static const double _aspect = 1.04;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: size,
      height: size * _aspect,
      child: CustomPaint(
        painter: _GreenBeanPainter(bean: bean, seed: seed, turns: turns),
      ),
    ),
  );
}

class _GreenBeanPainter extends CustomPainter {
  _GreenBeanPainter({
    required this.bean,
    required this.seed,
    required this.turns,
  });

  final BagpickBean bean;
  final int seed;
  final double turns;

  /// The space the design drew in.
  static const double _viewBox = 24;

  static const Color _shadow = Color(0x2E1B1614);
  static const Color _outline = Color(0x591B1614);
  static const Color _creaseShadow = Color(0x4D1B1614);
  static const Color _mottleStain = Color(0xFF6B4A22);
  static const Color _chaff = Color(0xFFF3EADA);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    canvas
      ..save()
      ..scale(scale)
      ..translate(beanCentre.dx, beanCentre.dy)
      ..rotate(turns * 2 * math.pi)
      ..translate(-beanCentre.dx, -beanCentre.dy);

    _paintBody(canvas);
    _paintMottling(canvas);
    _paintOutline(canvas);
    _paintCrease(canvas);
    if (bean.chaff) _paintChaff(canvas);

    canvas.restore();
  }

  void _paintBody(Canvas canvas) {
    canvas
      ..drawOval(
        Rect.fromCenter(
          center: const Offset(12, 12.6),
          width: beanRadius.width * 2,
          height: beanRadius.height * 2,
        ),
        Paint()..color = _shadow,
      )
      ..drawOval(_beanOval, Paint()..color = beanColour(bean.body));
  }

  void _paintMottling(Canvas canvas) {
    for (final patch in mottlePatches(bean, seed: seed)) {
      canvas.drawOval(
        Rect.fromCenter(
          center: patch.centre,
          width: patch.radius.width * 2,
          height: patch.radius.height * 2,
        ),
        Paint()..color = _mottleStain.withValues(alpha: patch.opacity),
      );
    }
  }

  void _paintOutline(Canvas canvas) {
    canvas.drawOval(
      _beanOval,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
  }

  /// The centre cut — the seam down the flat face, and the single strongest
  /// tell a learner reads.
  void _paintCrease(Canvas canvas) {
    final crease = Path()
      ..moveTo(12, 3.5)
      ..cubicTo(13.5, 7, 10.5, 9, 12, 12)
      // The design's `S` command: the first control point mirrors the previous
      // one about the current point, which lands it at (13.5, 15).
      ..cubicTo(13.5, 15, 13.5, 17, 12, 20.5);

    canvas
      ..drawPath(
        crease,
        Paint()
          ..color = _creaseShadow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.9
          ..strokeCap = StrokeCap.round,
      )
      ..drawPath(
        crease,
        Paint()
          ..color = beanColour(bean.crease)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
  }

  /// Silverskin still clinging to the seed.
  void _paintChaff(Canvas canvas) {
    _fleck(canvas, const Offset(11.2, 8.2), const Size(0.85, 0.42), 0.6, -14);
    _fleck(canvas, const Offset(12.7, 16), const Size(0.7, 0.38), 0.5, 12);
  }

  void _fleck(
    Canvas canvas,
    Offset centre,
    Size radius,
    double opacity,
    double degrees,
  ) {
    canvas
      ..save()
      ..translate(centre.dx, centre.dy)
      ..rotate(degrees * math.pi / 180)
      ..drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius.width * 2,
          height: radius.height * 2,
        ),
        Paint()..color = _chaff.withValues(alpha: opacity),
      )
      ..restore();
  }

  Rect get _beanOval => Rect.fromCenter(
    center: beanCentre,
    width: beanRadius.width * 2,
    height: beanRadius.height * 2,
  );

  @override
  bool shouldRepaint(_GreenBeanPainter old) =>
      old.bean != bean || old.seed != seed || old.turns != turns;
}
