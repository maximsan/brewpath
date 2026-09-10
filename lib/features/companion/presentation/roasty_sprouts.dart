import 'package:brew_path/shared/theme/roasty_colors.dart';
import 'package:brew_path/shared/theme/roasty_outfit_colors.dart';
import 'package:flutter/material.dart';

/// The four things that can grow from Roasty's crown.
///
/// All four are transcribed from the running prototype's own table, so the
/// set is internally consistent. `leaf` therefore **drops the mascot design
/// page's stem `M100 88 Q100 80 100 70` and leaf `M100 72 C 86 58…`**, which
/// sit 1–2px higher; the running file wins (ADR-0009).
void paintRoastySproutArt(Canvas canvas, String sprout) {
  switch (sprout) {
    case 'leaf':
      _paintLeaves(canvas);
    case 'flower':
      _paintBlossom(canvas);
    case 'sprig':
      _paintSprig(canvas);
    case _:
      return;
  }
}

/// The sprouts this file can draw, guarded against the bank's ids.
const roastySproutIds = {'leaf', 'flower', 'sprig'};

/// Whether [sprout] draws anything at all.
bool sproutIsBare(String sprout) => !roastySproutIds.contains(sprout);

const _leafRect = Rect.fromLTWH(60, 55, 80, 30);
const _leafGradient = RadialGradient(
  center: Alignment(-0.3, -0.4),
  radius: 0.75,
  colors: RoastyColors.leafGradient,
);

Paint get _leafPaint => Paint()..shader = _leafGradient.createShader(_leafRect);

Paint get _stemPaint => Paint()
  ..color = RoastyColors.leafDeep
  ..strokeWidth = 3
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.stroke;

Paint get _veinPaint => Paint()
  ..color = RoastyColors.leafDeep.withValues(alpha: 0.6)
  ..strokeWidth = 1
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round;

void _paintLeaves(Canvas canvas) {
  canvas.drawPath(
    Path()
      ..moveTo(100, 87)
      ..quadraticBezierTo(100, 79, 100, 72),
    _stemPaint,
  );
  final leaf = _leafPaint;
  canvas
    ..drawPath(
      Path()
        ..moveTo(100, 75)
        ..cubicTo(87, 64, 73, 66, 69, 74)
        ..cubicTo(73, 83, 89, 81, 100, 77)
        ..close(),
      leaf,
    )
    ..drawPath(
      Path()
        ..moveTo(100, 75)
        ..cubicTo(113, 64, 127, 66, 131, 74)
        ..cubicTo(127, 83, 111, 81, 100, 77)
        ..close(),
      leaf,
    );
  final vein = _veinPaint;
  canvas
    ..drawPath(
      Path()
        ..moveTo(100, 76)
        ..quadraticBezierTo(87, 73, 73, 75),
      vein,
    )
    ..drawPath(
      Path()
        ..moveTo(100, 76)
        ..quadraticBezierTo(113, 73, 127, 75),
      vein,
    );
}

void _paintBlossom(Canvas canvas) {
  canvas.drawPath(
    Path()
      ..moveTo(100, 89)
      ..quadraticBezierTo(100, 81, 100, 74),
    _stemPaint,
  );
  final leaf = _leafPaint;
  canvas
    ..drawPath(
      Path()
        ..moveTo(100, 81)
        ..cubicTo(91, 75, 83, 77, 81, 82)
        ..cubicTo(85, 87, 94, 85, 100, 82)
        ..close(),
      leaf,
    )
    ..drawPath(
      Path()
        ..moveTo(100, 81)
        ..cubicTo(109, 75, 117, 77, 119, 82)
        ..cubicTo(115, 87, 106, 85, 100, 82)
        ..close(),
      leaf,
    );

  // Five petals around a centre, at the design's translate(100 68).
  const petals = [
    Offset(0, -7),
    Offset(7, -2),
    Offset(4, 6),
    Offset(-4, 6),
    Offset(-7, -2),
  ];
  final petal = Paint()..color = RoastyOutfitColors.gearLight;
  for (final at in petals) {
    canvas.drawCircle(Offset(100 + at.dx, 68 + at.dy), 4.6, petal);
  }
  canvas.drawCircle(
    const Offset(100, 68),
    3.2,
    Paint()..color = RoastyOutfitColors.blossomHeart,
  );
}

void _paintSprig(Canvas canvas) {
  canvas
    ..drawPath(
      Path()
        ..moveTo(100, 88)
        ..quadraticBezierTo(100, 80, 100, 72),
      _stemPaint,
    )
    ..drawPath(
      Path()
        ..moveTo(100, 76)
        ..cubicTo(113, 65, 127, 67, 131, 75)
        ..cubicTo(127, 84, 111, 82, 100, 78)
        ..close(),
      _leafPaint,
    )
    ..drawPath(
      Path()
        ..moveTo(100, 77)
        ..quadraticBezierTo(113, 74, 127, 76),
      _veinPaint,
    )
    ..drawCircle(
      const Offset(91, 70),
      5.5,
      Paint()..color = RoastyOutfitColors.ember,
    )
    ..drawCircle(
      const Offset(89, 68),
      1.8,
      Paint()..color = RoastyOutfitColors.cherryBlush,
    )
    ..drawCircle(
      const Offset(99, 65),
      4.5,
      Paint()..color = RoastyOutfitColors.emberDeep,
    );
}
