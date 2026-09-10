import 'dart:math' as math;

import 'package:brew_path/shared/theme/roasty_outfit_colors.dart';
import 'package:flutter/material.dart';

/// What Roasty can wear on his face and neck.
///
/// Drawn inside the body transform and under the hat, which is the order the
/// design draws them in — a beanie's brim sits over a headphone band. An id
/// with no art here draws nothing, which is what `none` is.
void paintRoastyGear(Canvas canvas, String gear) {
  switch (gear) {
    case 'glasses':
      _paintGlasses(canvas);
    case 'sunglasses':
      _paintShades(canvas);
    case 'scarf':
      _paintScarf(canvas);
    case 'headphones':
      _paintHeadphones(canvas);
    case _:
      return;
  }
}

/// The gear this file can draw, guarded against the bank's ids.
const roastyGearIds = {'glasses', 'sunglasses', 'scarf', 'headphones'};

Paint get _frame => Paint()
  ..color = RoastyOutfitColors.gearDark
  ..strokeWidth = 2.4
  ..style = PaintingStyle.stroke;

Paint get _arm => Paint()
  ..color = RoastyOutfitColors.gearDark
  ..strokeWidth = 2.4
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round;

void _paintGlasses(Canvas canvas) {
  final lens = Paint()
    ..color = RoastyOutfitColors.gearLight.withValues(alpha: 0.16);
  canvas
    ..drawCircle(const Offset(80, 150), 13, lens)
    ..drawCircle(const Offset(80, 150), 13, _frame)
    ..drawCircle(const Offset(120, 150), 13, lens)
    ..drawCircle(const Offset(120, 150), 13, _frame)
    ..drawPath(
      Path()
        ..moveTo(93, 149)
        ..relativeQuadraticBezierTo(7, -4, 14, 0),
      _frame,
    )
    ..drawPath(
      Path()
        ..moveTo(67, 149)
        ..relativeQuadraticBezierTo(-12, -2, -17, 4),
      _arm,
    )
    ..drawPath(
      Path()
        ..moveTo(133, 149)
        ..relativeQuadraticBezierTo(12, -2, 17, 4),
      _arm,
    );
}

void _paintShades(Canvas canvas) {
  final dark = Paint()..color = RoastyOutfitColors.gearDark;
  final glint = Paint()
    ..color = RoastyOutfitColors.gearLight.withValues(alpha: 0.28);
  canvas
    ..drawRRect(
      RRect.fromLTRBR(63, 142, 94, 159, const Radius.circular(7.5)),
      dark,
    )
    ..drawRRect(
      RRect.fromLTRBR(106, 142, 137, 159, const Radius.circular(7.5)),
      dark,
    )
    ..drawLine(
      const Offset(94, 147),
      const Offset(106, 147),
      Paint()
        ..color = RoastyOutfitColors.gearDark
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    )
    ..drawPath(
      Path()
        ..moveTo(63, 146)
        ..relativeQuadraticBezierTo(-12, -1, -16, 4),
      _arm,
    )
    ..drawPath(
      Path()
        ..moveTo(137, 146)
        ..relativeQuadraticBezierTo(12, -1, 16, 4),
      _arm,
    )
    ..drawOval(
      Rect.fromCenter(center: const Offset(72, 147), width: 6.4, height: 4),
      glint,
    )
    ..drawOval(
      Rect.fromCenter(center: const Offset(115, 147), width: 6.4, height: 4),
      glint,
    );
}

void _paintScarf(Canvas canvas) {
  canvas
    ..drawPath(
      Path()
        ..moveTo(50, 196)
        ..quadraticBezierTo(100, 214, 150, 196)
        ..lineTo(150, 209)
        ..quadraticBezierTo(100, 227, 50, 209)
        ..close(),
      Paint()..color = RoastyOutfitColors.moss,
    )
    ..drawPath(
      Path()
        ..moveTo(118, 206)
        ..relativeQuadraticBezierTo(11, 15, 5, 32)
        ..relativeQuadraticBezierTo(-9, 2, -13, -2)
        ..relativeQuadraticBezierTo(5, -15, 0, -28)
        ..close(),
      Paint()..color = RoastyOutfitColors.scarfShade,
    )
    ..drawPath(
      Path()
        ..moveTo(58, 202)
        ..quadraticBezierTo(100, 216, 142, 202),
      Paint()
        ..color = RoastyOutfitColors.scarfShade.withValues(alpha: 0.7)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );
}

void _paintHeadphones(Canvas canvas) {
  final shell = Paint()..color = RoastyOutfitColors.gearDark;
  final cushion = Paint()..color = RoastyOutfitColors.cushion;
  canvas
    ..drawPath(
      // The design's `a52 52 0 0 1` sweep from (48,152) to (152,152): a
      // half-circle over the head, which its own bounding arc states exactly.
      Path()..addArc(
        Rect.fromCircle(center: const Offset(100, 152), radius: 52),
        math.pi,
        math.pi,
      ),
      Paint()
        ..color = RoastyOutfitColors.gearDark
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    )
    ..drawRRect(
      RRect.fromLTRBR(35, 142, 54, 170, const Radius.circular(8)),
      shell,
    )
    ..drawRRect(
      RRect.fromLTRBR(146, 142, 165, 170, const Radius.circular(8)),
      shell,
    )
    ..drawRRect(
      RRect.fromLTRBR(39, 147, 50, 165, const Radius.circular(5)),
      cushion,
    )
    ..drawRRect(
      RRect.fromLTRBR(150, 147, 161, 165, const Radius.circular(5)),
      cushion,
    );
}
