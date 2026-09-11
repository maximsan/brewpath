import 'dart:math' as math;

import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty_animation.dart';
import 'package:brew_path/features/companion/presentation/roasty_sprouts.dart';
import 'package:brew_path/shared/theme/roasty_colors.dart';
import 'package:brew_path/shared/theme/roasty_outfit_colors.dart';
import 'package:flutter/material.dart';

/// Scale origin while the host drives the grow: the stem base sits at the
/// bean's top edge, so the sprout emerges from the head rather than scaling
/// in mid-air. The default sleeping shrink keeps its original (100, 75) pivot.
const Offset _sproutGrowAnchor = Offset(100, 88);
const Offset _sproutDefaultAnchor = Offset(100, 75);

const Offset _plateCenter = Offset(100, 140);

/// Clears the contact shadow at y 232, so the bean never hangs off its plate.
const double _plateRadius = 112;

/// Paints the paper plate that separates the bean from a dark or accent-filled
/// ground, where the roast browns otherwise merge into it. Goes under
/// everything else Roasty draws.
void paintRoastyPlate(Canvas canvas) {
  canvas.drawCircle(
    _plateCenter,
    _plateRadius,
    Paint()..color = RoastyColors.plate,
  );
}

/// Paints the [sprout] above the bean. [sproutScale] overrides the
/// state-derived scale when non-null (used by the loading wake-up grow).
void paintRoastySprout(
  Canvas canvas,
  RoastyState state,
  double t,
  double? sproutScale, {
  String sprout = 'leaf',
}) {
  if (sproutIsBare(sprout)) return;
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
  paintRoastySproutArt(canvas, sprout);
  canvas.restore();
}

/// The bean's outline in the mascot's own units, which the body fills and
/// the card face's shimmer blurs behind it.
Path roastyBeanOutline() => Path()
  ..moveTo(100, 90)
  ..cubicTo(62, 90, 38, 120, 38, 158)
  ..cubicTo(38, 200, 64, 226, 100, 226)
  ..cubicTo(136, 226, 162, 200, 162, 158)
  ..cubicTo(162, 120, 138, 90, 100, 90)
  ..close();

/// Paints the bean body (shadow, gradient body, highlight, crease) with the
/// per-state body transform for [state] at progress [t].
///
/// [roast] picks the body gradient. It is threaded through the paint rather
/// than overlaid, because a darker bean is a different bean and not a tinted
/// one — a wash over the highlight and crease would grey both.
void paintRoastyBody(
  Canvas canvas,
  RoastyState state,
  double t, {
  String roast = 'medium',
}) {
  canvas.save();
  final offset = roastyBodyOffset(state, t);
  canvas.translate(100 + offset.dx, 158 + offset.dy);
  canvas.rotate(roastyBodyRotation(state, t));
  final scale = roastyBodyScale(state, t);
  canvas.scale(scale);
  canvas.translate(-100, -158);

  // contact shadow
  final shadow = Paint()
    ..color = RoastyColors.beanShadow.withValues(alpha: 0.18);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(100, 232), width: 112, height: 12),
    shadow,
  );

  // bean body — the design's radial gradient, lit side to edge
  const bodyRect = Rect.fromLTWH(38, 90, 124, 136);
  final bodyGradient = RadialGradient(
    center: const Alignment(-0.36, -0.36),
    radius: 0.75,
    colors: RoastyOutfitColors.roastGradient(roast),
    stops: const [0.0, 0.55, 1.0],
  );
  final bodyPaint = Paint()..shader = bodyGradient.createShader(bodyRect);
  canvas.drawPath(roastyBeanOutline(), bodyPaint);

  // top highlight
  final highlight = Paint()
    ..color = RoastyColors.beanHighlight.withValues(alpha: 0.45);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(78, 115), width: 44, height: 28),
    highlight,
  );

  // bean crease
  final crease = Paint()
    ..color = RoastyColors.beanShadow.withValues(alpha: 0.55)
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
