import 'dart:math' as math;

import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty_state.dart';
import 'package:flutter/material.dart';

/// Paints the state-specific face onto the already-transformed bean canvas.
void paintRoastyFace(Canvas canvas, RoastyState state) {
  switch (state) {
    case RoastyState.idle:
      _paintIdleFace(canvas);
    case RoastyState.correct:
    case RoastyState.lesson:
      _paintHappyFace(canvas);
    case RoastyState.wrong:
      _paintWrongFace(canvas);
    case RoastyState.module:
      _paintModuleFace(canvas);
    case RoastyState.xp:
      _paintXpFace(canvas);
    case RoastyState.card:
      _paintCardFace(canvas);
    case RoastyState.sleep:
      _paintSleepFace(canvas);
    case RoastyState.awake:
      _paintAwakeFace(canvas);
  }
}

// ── Face primitives ────────────────────────────────────────────────────
Paint get _eyeWhite => Paint()..color = const Color(0xFFFBF7EE);
Paint get _pupil => Paint()..color = const Color(0xFF2A1B12);
Paint get _cheek =>
    Paint()..color = const Color(0xFFC47654).withValues(alpha: 0.45);
Paint get _mouthStroke => Paint()
  ..color = const Color(0xFF2A1B12)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2.5
  ..strokeCap = StrokeCap.round;

void _paintEyeOpen(Canvas c, double cx, double cy) {
  c.drawOval(
    Rect.fromCenter(center: Offset(cx, cy), width: 20, height: 24),
    _eyeWhite,
  );
  c.drawOval(
    Rect.fromCenter(center: Offset(cx, cy + 3), width: 10, height: 12),
    _pupil,
  );
  c.drawCircle(Offset(cx + 2, cy), 1.7, _eyeWhite);
}

void _paintEyeArchUp(Canvas c, double cx, double cy) {
  final p = Path()
    ..moveTo(cx - 10, cy)
    ..quadraticBezierTo(cx, cy - 10, cx + 10, cy);
  c.drawPath(p, _mouthStroke..strokeWidth = 3);
}

void _paintIdleFace(Canvas c) {
  _paintEyeOpen(c, 80, 148);
  _paintEyeOpen(c, 120, 148);
  c.drawOval(
    Rect.fromCenter(center: const Offset(68, 172), width: 12, height: 6),
    _cheek,
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(132, 172), width: 12, height: 6),
    _cheek,
  );
  final mouth = Path()
    ..moveTo(90, 180)
    ..quadraticBezierTo(100, 188, 110, 180);
  c.drawPath(mouth, _mouthStroke);
}

void _paintHappyFace(Canvas c) {
  _paintEyeArchUp(c, 80, 148);
  _paintEyeArchUp(c, 120, 148);
  c.drawOval(
    Rect.fromCenter(center: const Offset(68, 170), width: 14, height: 7),
    _cheek..color = const Color(0xFFC47654).withValues(alpha: 0.55),
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(132, 170), width: 14, height: 7),
    _cheek,
  );
  final mouth = Path()
    ..moveTo(86, 178)
    ..quadraticBezierTo(100, 192, 114, 178);
  c.drawPath(mouth, _mouthStroke..strokeWidth = 3);
}

void _paintWrongFace(Canvas c) {
  // closed-low eyes
  c.drawOval(
    Rect.fromCenter(center: const Offset(80, 148), width: 20, height: 24),
    _eyeWhite,
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(80, 155), width: 10, height: 10),
    _pupil,
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(120, 148), width: 20, height: 24),
    _eyeWhite,
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(120, 155), width: 10, height: 10),
    _pupil,
  );
  final brow = Paint()
    ..color = const Color(0xFF2A1B12)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;
  c.drawLine(const Offset(71, 138), const Offset(84, 135), brow);
  c.drawLine(const Offset(129, 138), const Offset(116, 135), brow);
  final mouth = Path()
    ..moveTo(91, 184)
    ..quadraticBezierTo(100, 180, 109, 184);
  c.drawPath(mouth, _mouthStroke);
}

/// Draws a five-pointed star centered at (cx, cy). Shared by the module face
/// and the correct-state sparkle particles.
void paintStar(Canvas c, double cx, double cy, double r, Color color) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final angle = -math.pi / 2 + i * math.pi / 5;
    final rad = i.isEven ? r : r * 0.42;
    final x = cx + math.cos(angle) * rad;
    final y = cy + math.sin(angle) * rad;
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  c.drawPath(path, Paint()..color = color);
}

void _paintModuleFace(Canvas c) {
  paintStar(c, 80, 148, 11, const Color(0xFFC8843A));
  paintStar(c, 120, 148, 11, const Color(0xFFC8843A));
  c.drawOval(
    Rect.fromCenter(center: const Offset(68, 172), width: 14, height: 7),
    _cheek,
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(132, 172), width: 14, height: 7),
    _cheek,
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(100, 185), width: 16, height: 18),
    _pupil,
  );
}

void _paintXpFace(Canvas c) {
  // open left eye, winking right eye
  _paintEyeOpen(c, 80, 148);
  final wink = Path()
    ..moveTo(110, 148)
    ..quadraticBezierTo(120, 142, 130, 148);
  c.drawPath(wink, _mouthStroke..strokeWidth = 3);
  c.drawOval(
    Rect.fromCenter(center: const Offset(68, 170), width: 12, height: 6),
    _cheek,
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(132, 170), width: 12, height: 6),
    _cheek,
  );
  final mouth = Path()
    ..moveTo(90, 180)
    ..quadraticBezierTo(100, 188, 113, 178);
  c.drawPath(mouth, _mouthStroke);
}

void _paintCardFace(Canvas c) {
  // wide-eyed O
  c.drawOval(
    Rect.fromCenter(center: const Offset(80, 146), width: 22, height: 26),
    _eyeWhite,
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(80, 148), width: 12, height: 14),
    _pupil,
  );
  c.drawCircle(const Offset(83, 145), 2, _eyeWhite);
  c.drawOval(
    Rect.fromCenter(center: const Offset(120, 146), width: 22, height: 26),
    _eyeWhite,
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(120, 148), width: 12, height: 14),
    _pupil,
  );
  c.drawCircle(const Offset(123, 145), 2, _eyeWhite);
  c.drawOval(
    Rect.fromCenter(center: const Offset(100, 184), width: 10, height: 12),
    _pupil,
  );
}

void _paintSleepFace(Canvas c) {
  final closed = Paint()
    ..color = const Color(0xFF2A1B12)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  c.drawLine(const Offset(71, 150), const Offset(89, 150), closed);
  c.drawLine(const Offset(111, 150), const Offset(129, 150), closed);
  final mouth = Path()
    ..moveTo(95, 182)
    ..quadraticBezierTo(100, 184, 105, 182);
  c.drawPath(mouth, _mouthStroke);
}

void _paintAwakeFace(Canvas c) {
  // big O-eyes (like card but smaller)
  c.drawOval(
    Rect.fromCenter(center: const Offset(80, 146), width: 22, height: 28),
    _eyeWhite,
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(80, 148), width: 12, height: 14),
    _pupil,
  );
  c.drawCircle(const Offset(83, 145), 2, _eyeWhite);
  c.drawOval(
    Rect.fromCenter(center: const Offset(120, 146), width: 22, height: 28),
    _eyeWhite,
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(120, 148), width: 12, height: 14),
    _pupil,
  );
  c.drawCircle(const Offset(123, 145), 2, _eyeWhite);
  c.drawOval(
    Rect.fromCenter(center: const Offset(100, 184), width: 8, height: 10),
    _pupil,
  );
}
