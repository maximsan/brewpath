import 'dart:math' as math;

import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/roasty_colors.dart';
import 'package:flutter/material.dart';

/// Paints the state-specific face onto the already-transformed bean canvas.
///
/// The face is palette-fixed except the module face's star eyes, which the
/// design gives to the mood's warn — so the host passes [mood] in.
void paintRoastyFace(Canvas canvas, RoastyState state, MoodColors mood) {
  switch (state) {
    case RoastyState.idle:
      _paintIdleFace(canvas);
    case RoastyState.correct:
    case RoastyState.lesson:
      _paintHappyFace(canvas);
    case RoastyState.wrong:
      _paintWrongFace(canvas);
    case RoastyState.module:
      _paintModuleFace(canvas, mood);
    case RoastyState.card:
      _paintCardFace(canvas);
    case RoastyState.sleep:
      _paintSleepFace(canvas);
    case RoastyState.awake:
      _paintAwakeFace(canvas);
  }
}

// ── Face primitives ────────────────────────────────────────────────────
Paint get _eyeWhite => Paint()..color = RoastyColors.eyeWhite;
Paint get _pupil => Paint()..color = RoastyColors.mouth;
Paint get _cheek => Paint()..color = RoastyColors.blush.withValues(alpha: 0.45);
Paint get _mouthStroke => Paint()
  ..color = RoastyColors.mouth
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2.5
  ..strokeCap = StrokeCap.round;

void _paintEyeOpen(Canvas canvas, double cx, double cy) {
  canvas.drawOval(
    Rect.fromCenter(center: Offset(cx, cy), width: 20, height: 24),
    _eyeWhite,
  );
  canvas.drawOval(
    Rect.fromCenter(center: Offset(cx, cy + 3), width: 10, height: 12),
    _pupil,
  );
  canvas.drawCircle(Offset(cx + 2, cy), 1.7, _eyeWhite);
}

void _paintEyeArchUp(Canvas canvas, double cx, double cy) {
  final arch = Path()
    ..moveTo(cx - 10, cy)
    ..quadraticBezierTo(cx, cy - 10, cx + 10, cy);
  canvas.drawPath(arch, _mouthStroke..strokeWidth = 3);
}

void _paintIdleFace(Canvas canvas) {
  _paintEyeOpen(canvas, 80, 148);
  _paintEyeOpen(canvas, 120, 148);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(68, 172), width: 12, height: 6),
    _cheek,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(132, 172), width: 12, height: 6),
    _cheek,
  );
  final mouth = Path()
    ..moveTo(90, 180)
    ..quadraticBezierTo(100, 188, 110, 180);
  canvas.drawPath(mouth, _mouthStroke);
}

void _paintHappyFace(Canvas canvas) {
  _paintEyeArchUp(canvas, 80, 148);
  _paintEyeArchUp(canvas, 120, 148);
  final cheek = _cheek..color = RoastyColors.blush.withValues(alpha: 0.55);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(68, 170), width: 14, height: 7),
    cheek,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(132, 170), width: 14, height: 7),
    cheek,
  );
  final mouth = Path()
    ..moveTo(86, 178)
    ..quadraticBezierTo(100, 192, 114, 178);
  canvas.drawPath(mouth, _mouthStroke..strokeWidth = 3);
}

void _paintWrongFace(Canvas canvas) {
  // closed-low eyes
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(80, 148), width: 20, height: 24),
    _eyeWhite,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(80, 155), width: 10, height: 10),
    _pupil,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(120, 148), width: 20, height: 24),
    _eyeWhite,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(120, 155), width: 10, height: 10),
    _pupil,
  );
  final brow = Paint()
    ..color = RoastyColors.mouth
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(const Offset(71, 138), const Offset(84, 135), brow);
  canvas.drawLine(const Offset(129, 138), const Offset(116, 135), brow);
  final mouth = Path()
    ..moveTo(91, 184)
    ..quadraticBezierTo(100, 180, 109, 184);
  canvas.drawPath(mouth, _mouthStroke);
}

/// Draws a five-pointed star centered at (cx, cy). Shared by the module face
/// and the correct-state sparkle particles.
void paintStar(
  Canvas canvas,
  double cx,
  double cy,
  double radius,
  Color color,
) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final angle = -math.pi / 2 + i * math.pi / 5;
    final pointRadius = i.isEven ? radius : radius * 0.42;
    final pointX = cx + math.cos(angle) * pointRadius;
    final pointY = cy + math.sin(angle) * pointRadius;
    if (i == 0) {
      path.moveTo(pointX, pointY);
    } else {
      path.lineTo(pointX, pointY);
    }
  }
  path.close();
  canvas.drawPath(path, Paint()..color = color);
}

void _paintModuleFace(Canvas canvas, MoodColors mood) {
  paintStar(canvas, 80, 148, 11, mood.warn);
  paintStar(canvas, 120, 148, 11, mood.warn);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(68, 172), width: 14, height: 7),
    _cheek,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(132, 172), width: 14, height: 7),
    _cheek,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(100, 185), width: 16, height: 18),
    _pupil,
  );
}

void _paintCardFace(Canvas canvas) {
  // wide-eyed O
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(80, 146), width: 22, height: 26),
    _eyeWhite,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(80, 148), width: 12, height: 14),
    _pupil,
  );
  canvas.drawCircle(const Offset(83, 145), 2, _eyeWhite);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(120, 146), width: 22, height: 26),
    _eyeWhite,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(120, 148), width: 12, height: 14),
    _pupil,
  );
  canvas.drawCircle(const Offset(123, 145), 2, _eyeWhite);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(100, 184), width: 10, height: 12),
    _pupil,
  );
}

void _paintSleepFace(Canvas canvas) {
  final closed = Paint()
    ..color = RoastyColors.mouth
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(const Offset(71, 150), const Offset(89, 150), closed);
  canvas.drawLine(const Offset(111, 150), const Offset(129, 150), closed);
  final mouth = Path()
    ..moveTo(95, 182)
    ..quadraticBezierTo(100, 184, 105, 182);
  canvas.drawPath(mouth, _mouthStroke);
}

void _paintAwakeFace(Canvas canvas) {
  // big O-eyes (like card but smaller)
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(80, 146), width: 22, height: 28),
    _eyeWhite,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(80, 148), width: 12, height: 14),
    _pupil,
  );
  canvas.drawCircle(const Offset(83, 145), 2, _eyeWhite);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(120, 146), width: 22, height: 28),
    _eyeWhite,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(120, 148), width: 12, height: 14),
    _pupil,
  );
  canvas.drawCircle(const Offset(123, 145), 2, _eyeWhite);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(100, 184), width: 8, height: 10),
    _pupil,
  );
}
