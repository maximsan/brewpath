import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty_state.dart';

/// Animated Roasty mascot. Reproduces the geometry + per-state animations
/// from the design bundle (`coffee_quest/brew-path-app/project/roasty.jsx`)
/// using Flutter's Canvas + a single [AnimationController]. Public API:
/// `Roasty(state: …, size: …, replayKey: …)`. The `replayKey` mimics the
/// prototype's `key={state + ':' + replayKey}` so one-shot animations
/// restart on demand.
class Roasty extends StatefulWidget {
  const Roasty({
    required this.state,
    this.size = 160,
    this.replayKey,
    super.key,
  });

  final RoastyState state;
  final double size;
  final Object? replayKey;

  @override
  State<Roasty> createState() => _RoastyState();
}

class _RoastyState extends State<Roasty> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: _durationFor(widget.state))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && _loops(widget.state)) {
              _controller.repeat();
            }
          });
    _startForState(widget.state);
  }

  @override
  void didUpdateWidget(covariant Roasty oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stateChanged = oldWidget.state != widget.state;
    final replayChanged = oldWidget.replayKey != widget.replayKey;
    if (stateChanged || replayChanged) {
      _controller.stop();
      _controller.duration = _durationFor(widget.state);
      _startForState(widget.state);
    }
  }

  void _startForState(RoastyState state) {
    _controller.reset();
    if (_loops(state)) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  static Duration _durationFor(RoastyState state) {
    switch (state) {
      case RoastyState.idle:
        return const Duration(milliseconds: 3200); // breathe loop
      case RoastyState.correct:
        return const Duration(milliseconds: 900); // hop one-shot
      case RoastyState.wrong:
        return const Duration(milliseconds: 500); // shake one-shot
      case RoastyState.lesson:
        return const Duration(milliseconds: 1100); // jump one-shot
      case RoastyState.module:
        return const Duration(milliseconds: 900); // grow one-shot
      case RoastyState.xp:
        return const Duration(milliseconds: 1300); // xp rise one-shot
      case RoastyState.card:
        return const Duration(milliseconds: 1600); // shimmer loop
      case RoastyState.sleep:
        return const Duration(milliseconds: 3400); // slow breathe loop
      case RoastyState.awake:
        return const Duration(milliseconds: 400); // blink-pop one-shot
    }
  }

  static bool _loops(RoastyState state) {
    switch (state) {
      case RoastyState.idle:
      case RoastyState.card:
      case RoastyState.sleep:
        return true;
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size * 1.4,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _RoastyPainter(state: widget.state, t: _controller.value),
          ),
        ),
      ),
    );
  }
}

/// Paints the bean body, current-state face, sprout, and the state-specific
/// particle layer onto a 200x280 logical canvas (matches the prototype's
/// SVG viewBox so geometry copies 1:1 from roasty.jsx).
class _RoastyPainter extends CustomPainter {
  _RoastyPainter({required this.state, required this.t});

  final RoastyState state;
  final double t;

  static const double _vbW = 200;
  static const double _vbH = 280;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final sx = size.width / _vbW;
    final sy = size.height / _vbH;
    final s = math.min(sx, sy);
    canvas.translate((size.width - _vbW * s) / 2, (size.height - _vbH * s) / 2);
    canvas.scale(s, s);

    _paintParticlesBack(canvas);
    _paintSprout(canvas);
    _paintBody(canvas);
    _paintFace(canvas);
    _paintParticlesFront(canvas);

    canvas.restore();
  }

  // ── Animation drivers (mapped 1:1 from roasty.jsx CSS keyframes) ─────

  Offset _bodyOffset() {
    switch (state) {
      case RoastyState.idle:
        // breathe: translateY 0 → -3 → 0
        final v = math.sin(t * math.pi * 2);
        return Offset(0, -3 * (v * 0.5 + 0.5) * math.sin(t * math.pi));
      case RoastyState.correct:
        // hop: -10 at 25% and 75%, 0 at 0/50/100%
        final hop = math.sin(t * math.pi * 2).abs();
        return Offset(0, -10 * hop);
      case RoastyState.wrong:
        // shake: ±5 → ±3
        final amp = (1 - t) * 5;
        final dx = math.sin(t * math.pi * 8) * amp;
        return Offset(dx, 0);
      case RoastyState.lesson:
        // jump: 0 → -18 → -8 → -14 → 0
        if (t < 0.3) {
          return Offset(0, -18 * (t / 0.3));
        } else if (t < 0.5) {
          final p = (t - 0.3) / 0.2;
          return Offset(0, -18 + 10 * p);
        } else if (t < 0.7) {
          final p = (t - 0.5) / 0.2;
          return Offset(0, -8 - 6 * p);
        } else {
          final p = (t - 0.7) / 0.3;
          return Offset(0, -14 + 14 * p);
        }
      default:
        return Offset.zero;
    }
  }

  double _bodyScale() {
    switch (state) {
      case RoastyState.module:
        // grow: 1 → 1.12 → 1.05
        if (t < 0.4) return 1 + (0.12) * (t / 0.4);
        return 1.12 - 0.07 * ((t - 0.4) / 0.6);
      case RoastyState.awake:
        // blink-pop: 0.94 → 1.04 → 1
        if (t < 0.5) return 0.94 + (1.04 - 0.94) * (t / 0.5);
        return 1.04 - (1.04 - 1.0) * ((t - 0.5) / 0.5);
      case RoastyState.idle:
        // subtle 0.5% squash on the breath beat
        final v = math.sin(t * math.pi * 2);
        return 1.0 + 0.005 * v;
      default:
        return 1.0;
    }
  }

  double _bodyRotation() {
    switch (state) {
      case RoastyState.correct:
        // ±3° rotate on hop peaks
        final s = math.sin(t * math.pi * 2);
        return (s * 3) * math.pi / 180;
      case RoastyState.sleep:
        // permanent 6° tilt
        return 6 * math.pi / 180;
      default:
        return 0;
    }
  }

  // ── Particles back (behind body) ─────────────────────────────────────
  void _paintParticlesBack(Canvas canvas) {
    if (state == RoastyState.module) {
      _paintModuleRays(canvas);
    }
    if (state == RoastyState.card) {
      _paintCardGlow(canvas);
    }
  }

  void _paintModuleRays(Canvas canvas) {
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

  void _paintCardGlow(Canvas canvas) {
    final pulse = (math.sin(t * math.pi * 2) * 0.5 + 0.5);
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

  // ── Sprout ───────────────────────────────────────────────────────────
  void _paintSprout(Canvas canvas) {
    canvas.save();
    final sleeping = state == RoastyState.sleep || state == RoastyState.awake;
    final scale = sleeping ? 0.15 : 1.0;
    // anchor near base of stem (x=100, y=88)
    canvas.translate(100, 75);

    // leaf sway: gentle ±2° rotation on most states
    if (!sleeping) {
      final sway = math.sin(t * math.pi * 2) * 2 * math.pi / 180;
      canvas.rotate(sway);
    }

    canvas.scale(scale);
    canvas.translate(-100, -75);

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

  // ── Body (bean) ──────────────────────────────────────────────────────
  void _paintBody(Canvas canvas) {
    canvas.save();
    final offset = _bodyOffset();
    canvas.translate(100 + offset.dx, 158 + offset.dy);
    canvas.rotate(_bodyRotation());
    final scale = _bodyScale();
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

  // ── Face (state-specific) ────────────────────────────────────────────
  void _paintFace(Canvas canvas) {
    // Faces ride along with the body transform.
    canvas.save();
    final offset = _bodyOffset();
    canvas.translate(100 + offset.dx, 158 + offset.dy);
    canvas.rotate(_bodyRotation());
    canvas.scale(_bodyScale());
    canvas.translate(-100, -158);

    switch (state) {
      case RoastyState.idle:
        _paintIdleFace(canvas);
        break;
      case RoastyState.correct:
      case RoastyState.lesson:
        _paintHappyFace(canvas);
        break;
      case RoastyState.wrong:
        _paintWrongFace(canvas);
        break;
      case RoastyState.module:
        _paintModuleFace(canvas);
        break;
      case RoastyState.xp:
        _paintXpFace(canvas);
        break;
      case RoastyState.card:
        _paintCardFace(canvas);
        break;
      case RoastyState.sleep:
        _paintSleepFace(canvas);
        break;
      case RoastyState.awake:
        _paintAwakeFace(canvas);
        break;
    }

    canvas.restore();
  }

  // ── Particles in front (xp burst, wrong x, sleep zzz, sparkles, confetti)
  void _paintParticlesFront(Canvas canvas) {
    switch (state) {
      case RoastyState.correct:
        _paintSparkles(canvas);
        break;
      case RoastyState.lesson:
      case RoastyState.module:
        _paintConfetti(canvas);
        break;
      case RoastyState.xp:
        _paintXpBurst(canvas);
        break;
      case RoastyState.wrong:
        _paintWrongBadge(canvas);
        break;
      case RoastyState.sleep:
        _paintSleepZzz(canvas);
        break;
      default:
        break;
    }
  }

  // ── Face primitives ──────────────────────────────────────────────────
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

  void _paintStar(Canvas c, double cx, double cy, double r, Color color) {
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
    _paintStar(c, 80, 148, 11, const Color(0xFFC8843A));
    _paintStar(c, 120, 148, 11, const Color(0xFFC8843A));
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

  // ── Particle implementations ─────────────────────────────────────────
  void _paintSparkles(Canvas c) {
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
      _paintStar(c, 0, 0, 5, p.color);
      c.restore();
    }
  }

  void _paintConfetti(Canvas c) {
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

  void _paintXpBurst(Canvas c) {
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

  void _paintSleepZzz(Canvas c) {
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

  @override
  bool shouldRepaint(covariant _RoastyPainter old) =>
      old.state != state || old.t != t;
}
