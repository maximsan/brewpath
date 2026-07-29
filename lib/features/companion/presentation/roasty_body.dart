import 'dart:math' as math;

import 'package:coffee_quest/features/companion/domain/roasty_state.dart';
import 'package:coffee_quest/features/companion/presentation/roasty_animation.dart';
import 'package:flutter/material.dart';

/// Scale origin while the host drives the grow: the stem base sits at the
/// bean's top edge, so the sprout emerges from the head rather than scaling
/// in mid-air. The default sleeping shrink keeps its original (100, 75) pivot.
const Offset _sproutGrowAnchor = Offset(100, 88);
const Offset _sproutDefaultAnchor = Offset(100, 75);

/// Paints the sprout (stem + leaves) above the bean. [sproutScale] overrides
/// the state-derived scale when non-null (used by the loading wake-up grow).
void paintRoastySprout(
  Canvas canvas,
  RoastyState state,
  double t,
  double? sproutScale,
) {
  final sleeping = state == RoastyState.sleep || state == RoastyState.awake;
  final usingGrow = sproutScale != null;
  final scale = sproutScale ?? (sleeping ? 0.15 : 1.0);
  if (scale <= 0) return; // fully hidden; also skips a degenerate matrix
  canvas.save();
  final anchor = usingGrow ? _sproutGrowAnchor : _sproutDefaultAnchor;
  canvas.translate(anchor.dx, anchor.dy);

  // leaf sway: gentle ±2° rotation on most states
  if (!sleeping) {
    final sway = math.sin(t * math.pi * 2) * 2 * math.pi / 180;
    canvas.rotate(sway);
  }

  canvas.scale(scale);
  canvas.translate(-anchor.dx, -anchor.dy);

  final stem = Paint()
    ..color = const Color(0xFF5E7148)
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final stemPath = Path()
    ..moveTo(100, 88)
    ..quadraticBezierTo(100, 80, 100, 70);
  canvas.drawPath(stemPath, stem);

  const leafGradient = RadialGradient(
    center: Alignment(-0.3, -0.4),
    radius: 0.75,
    colors: [Color(0xFFB5C497), Color(0xFF5E7148)],
  );
  const leafRect = Rect.fromLTWH(60, 55, 80, 30);
  final leafPaint = Paint()..shader = leafGradient.createShader(leafRect);

  final leafL = Path()
    ..moveTo(100, 72)
    ..cubicTo(86, 58, 70, 60, 66, 70)
    ..cubicTo(70, 82, 88, 80, 100, 74)
    ..close();
  final leafR = Path()
    ..moveTo(100, 72)
    ..cubicTo(114, 58, 130, 60, 134, 70)
    ..cubicTo(130, 82, 112, 80, 100, 74)
    ..close();
  canvas.drawPath(leafL, leafPaint);
  canvas.drawPath(leafR, leafPaint);

  final vein = Paint()
    ..color = const Color(0xFF5E7148).withValues(alpha: 0.6)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final veinL = Path()
    ..moveTo(100, 73)
    ..quadraticBezierTo(86, 70, 72, 72);
  final veinR = Path()
    ..moveTo(100, 73)
    ..quadraticBezierTo(114, 70, 128, 72);
  canvas.drawPath(veinL, vein);
  canvas.drawPath(veinR, vein);

  canvas.restore();
}

/// Paints the bean body (shadow, gradient body, highlight, crease) with the
/// per-state body transform for [state] at progress [t].
void paintRoastyBody(Canvas canvas, RoastyState state, double t) {
  canvas.save();
  final offset = roastyBodyOffset(state, t);
  canvas.translate(100 + offset.dx, 158 + offset.dy);
  canvas.rotate(roastyBodyRotation(state, t));
  final scale = roastyBodyScale(state, t);
  canvas.scale(scale);
  canvas.translate(-100, -158);

  // contact shadow
  final shadow = Paint()
    ..color = const Color(0xFF2F1A0E).withValues(alpha: 0.18);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(100, 232), width: 112, height: 12),
    shadow,
  );

  // bean body — radial gradient #8C5634 → #6B3E22 → #4A2B19
  const bodyRect = Rect.fromLTWH(38, 90, 124, 136);
  const bodyGradient = RadialGradient(
    center: Alignment(-0.36, -0.36),
    radius: 0.75,
    colors: [Color(0xFF8C5634), Color(0xFF6B3E22), Color(0xFF4A2B19)],
    stops: [0.0, 0.55, 1.0],
  );
  final bodyPaint = Paint()..shader = bodyGradient.createShader(bodyRect);
  final bodyPath = Path()
    ..moveTo(100, 90)
    ..cubicTo(62, 90, 38, 120, 38, 158)
    ..cubicTo(38, 200, 64, 226, 100, 226)
    ..cubicTo(136, 226, 162, 200, 162, 158)
    ..cubicTo(162, 120, 138, 90, 100, 90)
    ..close();
  canvas.drawPath(bodyPath, bodyPaint);

  // top highlight
  final highlight = Paint()
    ..color = const Color(0xFFA26945).withValues(alpha: 0.45);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(78, 115), width: 44, height: 28),
    highlight,
  );

  // bean crease
  final crease = Paint()
    ..color = const Color(0xFF2F1A0E).withValues(alpha: 0.55)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round;
  final creasePath = Path()
    ..moveTo(100, 96)
    ..quadraticBezierTo(88, 130, 100, 158)
    ..quadraticBezierTo(112, 186, 100, 218);
  canvas.drawPath(creasePath, crease);

  canvas.restore();
}
