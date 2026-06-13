import 'dart:math' as math;

import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty_faces.dart';
import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty_state.dart';
import 'package:flutter/material.dart';

// The front particle dispatch handles the states with particles and defaults
// the rest; enumerating every no-op state would bloat the switch.
// ignore_for_file: no_default_cases

/// Particle layer painted behind the bean body (rays / glow).
void paintRoastyParticlesBack(Canvas canvas, RoastyState state, double t) {
  if (state == RoastyState.module) {
    _paintModuleRays(canvas, t);
  }
  if (state == RoastyState.card) {
    _paintCardGlow(canvas, t);
  }
}

/// Particle layer painted in front of the bean body (sparkles, confetti, xp
/// burst, wrong badge, sleep zzz).
void paintRoastyParticlesFront(Canvas canvas, RoastyState state, double t) {
  switch (state) {
    case RoastyState.correct:
      _paintSparkles(canvas, t);
    case RoastyState.lesson:
    case RoastyState.module:
      _paintConfetti(canvas, t);
    case RoastyState.xp:
      _paintXpBurst(canvas, t);
    case RoastyState.wrong:
      _paintWrongBadge(canvas);
    case RoastyState.sleep:
      _paintSleepZzz(canvas, t);
    default:
      break;
  }
}

// ── Particles back (behind body) ───────────────────────────────────────
void _paintModuleRays(Canvas canvas, double t) {
  canvas.save();
  const cx = 100.0;
  const cy = 158.0;
  canvas.translate(cx, cy);
  canvas.rotate(t * math.pi * 2);
  final paint = Paint()
    ..color = const Color(0xFFC8843A).withValues(alpha: 0.55)
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (var i = 0; i < 8; i++) {
    final a = (i / 8) * math.pi * 2;
    final x1 = math.cos(a) * 80;
    final y1 = math.sin(a) * 80;
    final x2 = math.cos(a) * 62;
    final y2 = math.sin(a) * 62;
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }
  canvas.restore();
}

void _paintCardGlow(Canvas canvas, double t) {
  final pulse = math.sin(t * math.pi * 2) * 0.5 + 0.5;
  final gradient = RadialGradient(
    colors: [
      const Color(0xFFE6C68A).withValues(alpha: 0.6 * pulse),
      const Color(0xFFE6C68A).withValues(alpha: 0),
    ],
  );
  final rect = Rect.fromCenter(
    center: const Offset(100, 160),
    width: 240,
    height: 220,
  );
  final paint = Paint()..shader = gradient.createShader(rect);
  canvas.drawOval(rect, paint);
}

// ── Particles in front ─────────────────────────────────────────────────
void _paintSparkles(Canvas c, double t) {
  const centers = [
    Offset(36, 80),
    Offset(168, 100),
    Offset(40, 200),
    Offset(170, 200),
  ];
  const delays = [0.0, 0.25, 0.5, 0.75];
  const colors = [
    Color(0xFFC8843A),
    Color(0xFF7A8471),
    Color(0xFFB8533A),
    Color(0xFFC8843A),
  ];
  for (var i = 0; i < centers.length; i++) {
    final phase = (t - delays[i]) % 1.0;
    final wave = phase < 0 ? 0.0 : math.sin(phase * math.pi).abs();
    final opacity = wave;
    final scale = 0.3 + wave * 0.7;
    final p = Paint()..color = colors[i].withValues(alpha: opacity);
    c.save();
    c.translate(centers[i].dx, centers[i].dy);
    c.scale(scale);
    paintStar(c, 0, 0, 5, p.color);
    c.restore();
  }
}

void _paintConfetti(Canvas c, double t) {
  const pieces = [
    [40.0, 60.0, 0.0],
    [158.0, 50.0, 0.2],
    [30.0, 120.0, 0.4],
    [170.0, 100.0, 0.6],
    [172.0, 180.0, 0.1],
    [22.0, 180.0, 0.5],
    [60.0, 40.0, 0.3],
    [140.0, 40.0, 0.7],
  ];
  const colors = [
    Color(0xFFB8533A),
    Color(0xFF7A8471),
    Color(0xFFC8843A),
    Color(0xFFB8533A),
    Color(0xFF7A8471),
    Color(0xFFC8843A),
    Color(0xFF7A8471),
    Color(0xFFB8533A),
  ];
  for (var i = 0; i < pieces.length; i++) {
    final piece = pieces[i];
    final phase = (t + piece[2]) % 1.0;
    final dy = -30 + phase * 210;
    final rotate = phase * 540 * math.pi / 180;
    final opacity = phase < 0.2
        ? phase / 0.2
        : (phase > 0.95 ? (1 - phase) / 0.05 : 1.0);
    final paint = Paint()
      ..color = colors[i].withValues(alpha: opacity.clamp(0, 1));
    c.save();
    c.translate(piece[0], piece[1] + dy);
    c.rotate(rotate);
    if (i.isEven) {
      c.drawRect(const Rect.fromLTWH(-3, -4, 6, 8), paint);
    } else {
      c.drawCircle(Offset.zero, 3, paint);
    }
    c.restore();
  }
}

void _paintXpBurst(Canvas c, double t) {
  final phase = t;
  final dy = -50 * phase;
  final opacity = phase < 0.2
      ? phase / 0.2
      : (1 - phase).clamp(0, 1).toDouble();
  final paint = Paint()
    ..color = const Color(0xFFC8843A).withValues(alpha: opacity);
  final rect = Rect.fromLTWH(68, 42 + dy, 64, 24);
  c.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
  final textStyle = TextStyle(
    color: const Color(0xFFFBF7EE).withValues(alpha: opacity),
    fontWeight: FontWeight.w600,
    fontSize: 13,
    fontFamily: 'IBMPlexMono',
    letterSpacing: 1,
  );
  final tp = TextPainter(
    text: TextSpan(text: '+15 XP', style: textStyle),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  )..layout(minWidth: 64, maxWidth: 64);
  tp.paint(c, Offset(68, 47 + dy));
}

void _paintWrongBadge(Canvas c) {
  final fill = Paint()..color = const Color(0xFFFBF7EE);
  final stroke = Paint()
    ..color = const Color(0xFFB8533A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  c.drawCircle(const Offset(148, 76), 13, fill);
  c.drawCircle(const Offset(148, 76), 13, stroke);
  final bar = Paint()..color = const Color(0xFFB8533A);
  c.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(146, 68, 4, 9),
      const Radius.circular(1),
    ),
    bar,
  );
  c.drawCircle(const Offset(148, 82), 1.6, bar);
}

void _paintSleepZzz(Canvas c, double t) {
  const letters = <({double x, double y, double size, double delay})>[
    (x: 148, y: 80, size: 18, delay: 0.0),
    (x: 158, y: 68, size: 14, delay: 0.6 / 2.6),
    (x: 166, y: 58, size: 11, delay: 1.2 / 2.6),
  ];
  for (final l in letters) {
    final raw = (t - l.delay) % 1.0;
    final p = raw < 0 ? raw + 1 : raw;
    final opacity = p < 0.3 ? p / 0.3 : (p > 0.7 ? (1 - p) / 0.3 : 1.0);
    final dx = p * 8;
    final dy = -p * 12;
    final tp = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
          color: const Color(
            0xFF6B5F54,
          ).withValues(alpha: opacity.clamp(0.0, 1.0)),
          fontStyle: FontStyle.italic,
          fontSize: l.size,
          fontFamily: 'Fraunces',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(l.x + dx, l.y + dy));
  }
}
