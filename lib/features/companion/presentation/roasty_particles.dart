import 'dart:math' as math;

import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty_animation.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/roasty_colors.dart';
import 'package:flutter/material.dart';

// The front particle dispatch handles the states with particles and defaults
// the rest; enumerating every no-op state would bloat the switch.
// ignore_for_file: no_default_cases

/// Particle layer painted behind the bean body (rays / glow).
///
/// The rays are the mood's warn in the design, so the host passes [mood] in;
/// the glow is palette-fixed.
void paintRoastyParticlesBack(
  Canvas canvas,
  RoastyState state,
  double progress,
  MoodColors mood,
) {
  if (state == RoastyState.module) {
    _paintModuleRays(canvas, progress, mood);
  }
  if (state == RoastyState.card) {
    _paintCardGlow(canvas, progress);
  }
}

/// Particle layer painted in front of the bean body (sparkles, confetti,
/// wrong badge, points burst, sleep zzz).
///
/// Two sparkles, the wrong badge, the points burst and the sleeping `z`s
/// follow the mood in the design (warn, berry, accent and muted ink); the
/// confetti is palette-fixed.
///
/// [pointsAmount] is what the burst says, and only [RoastyState.points] reads
/// it. The mascot names no payout of its own (#16), so with nothing passed the
/// burst has nothing to state and draws nothing; `Roasty` asserts the pairing
/// so a half-drawn pose cannot reach a screen.
void paintRoastyParticlesFront(
  Canvas canvas,
  RoastyState state,
  double progress,
  MoodColors mood, {
  int? pointsAmount,
}) {
  switch (state) {
    case RoastyState.correct:
      _paintSparkles(canvas, progress, mood);
    case RoastyState.lesson:
    case RoastyState.module:
      _paintConfetti(canvas, progress);
    case RoastyState.wrong:
      _paintWrongBadge(canvas, mood);
    case RoastyState.points:
      if (pointsAmount != null) {
        _paintPointsBurst(canvas, progress, mood, pointsAmount);
      }
    case RoastyState.sleep:
      _paintSleepZzz(canvas, progress, mood);
    default:
      break;
  }
}

// ── Particles back (behind body) ───────────────────────────────────────
void _paintModuleRays(Canvas canvas, double progress, MoodColors mood) {
  canvas.save();
  const cx = 100.0;
  const cy = 158.0;
  canvas.translate(cx, cy);
  canvas.rotate(progress * math.pi * 2);
  final paint = Paint()
    ..color = mood.warn.withValues(alpha: 0.55)
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (var i = 0; i < 8; i++) {
    final angle = (i / 8) * math.pi * 2;
    final x1 = math.cos(angle) * 80;
    final y1 = math.sin(angle) * 80;
    final x2 = math.cos(angle) * 62;
    final y2 = math.sin(angle) * 62;
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }
  canvas.restore();
}

void _paintCardGlow(Canvas canvas, double progress) {
  final pulse = math.sin(progress * math.pi * 2) * 0.5 + 0.5;
  final gradient = RadialGradient(
    colors: [
      RoastyColors.cardGlow.withValues(alpha: 0.6 * pulse),
      RoastyColors.cardGlow.withValues(alpha: 0),
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
void _paintSparkles(Canvas canvas, double progress, MoodColors mood) {
  const centers = [
    Offset(36, 80),
    Offset(168, 100),
    Offset(40, 200),
    Offset(170, 200),
  ];
  const delays = [0.0, 0.25, 0.5, 0.75];
  // The design gives each sparkle its own size; the app drew one size for all
  // four.
  const sizes = <({double outer, double inner})>[
    (outer: 6, inner: 1.5),
    (outer: 5, inner: 1.2),
    (outer: 4, inner: 1),
    (outer: 6, inner: 1.5),
  ];
  final colors = [
    mood.warn,
    RoastyColors.confettiMoss,
    RoastyColors.confettiEmber,
    mood.warn,
  ];
  for (var i = 0; i < centers.length; i++) {
    final phase = (progress - delays[i]) % 1.0;
    final wave = phase < 0 ? 0.0 : math.sin(phase * math.pi).abs();
    final opacity = wave;
    final scale = 0.3 + wave * 0.7;
    final sparkle = Paint()..color = colors[i].withValues(alpha: opacity);
    canvas.save();
    canvas.translate(centers[i].dx, centers[i].dy);
    canvas.scale(scale);
    _paintTwinkle(canvas, sizes[i], sparkle.color);
    canvas.restore();
  }
}

/// One sparkle: the design's **four**-pointed twinkle, where the app had been
/// drawing the same five-pointed star it uses for the module face's eyes.
///
/// Drawn about the origin — the caller has already translated and scaled to
/// the sparkle's place in its beat.
void _paintTwinkle(
  Canvas canvas,
  ({double outer, double inner}) size,
  Color colour,
) {
  final path = Path()
    ..moveTo(0, -size.outer)
    ..lineTo(size.inner, -size.inner)
    ..lineTo(size.outer, 0)
    ..lineTo(size.inner, size.inner)
    ..lineTo(0, size.outer)
    ..lineTo(-size.inner, size.inner)
    ..lineTo(-size.outer, 0)
    ..lineTo(-size.inner, -size.inner)
    ..close();
  canvas.drawPath(path, Paint()..color = colour);
}

void _paintConfetti(Canvas canvas, double progress) {
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
    RoastyColors.confettiEmber,
    RoastyColors.confettiMoss,
    RoastyColors.confettiGold,
    RoastyColors.confettiEmber,
    RoastyColors.confettiMoss,
    RoastyColors.confettiGold,
    RoastyColors.confettiMoss,
    RoastyColors.confettiEmber,
  ];
  for (var i = 0; i < pieces.length; i++) {
    final piece = pieces[i];
    final phase = (progress + piece[2]) % 1.0;
    final dy = -30 + phase * 210;
    final rotate = phase * 540 * math.pi / 180;
    final opacity = phase < 0.2
        ? phase / 0.2
        : (phase > 0.95 ? (1 - phase) / 0.05 : 1.0);
    final paint = Paint()
      ..color = colors[i].withValues(alpha: opacity.clamp(0, 1));
    canvas.save();
    canvas.translate(piece[0], piece[1] + dy);
    canvas.rotate(rotate);
    if (i.isEven) {
      canvas.drawRect(const Rect.fromLTWH(-3, -4, 6, 8), paint);
    } else {
      canvas.drawCircle(Offset.zero, 3, paint);
    }
    canvas.restore();
  }
}

/// The design's group opacity on the wrong badge.
const _wrongBadgeOpacity = 0.85;

const _wrongBadgeCenter = Offset(148, 76);
const _wrongBadgeRadius = 13.0;
const _wrongBadgeStroke = 2.0;

/// The layer the badge composites into: its disc plus the stroke that rides
/// on the edge of it.
const double _wrongBadgeExtent = _wrongBadgeRadius + _wrongBadgeStroke;

void _paintWrongBadge(Canvas canvas, MoodColors mood) {
  // The design's `opacity="0.85"` sits on the badge's *group*, and that is not
  // the same as fading each mark: the stroke and the exclamation are drawn on
  // the badge's own white disc, so per-mark alpha would let the disc show
  // through them. `saveLayer` composites the badge first and fades it once.
  //
  // Only the layer paint's alpha is read, so this dims `Paint`'s own default
  // colour rather than naming one the mascot does not have.
  final fade = Paint();
  fade.color = fade.color.withValues(alpha: _wrongBadgeOpacity);
  canvas.saveLayer(
    Rect.fromCircle(center: _wrongBadgeCenter, radius: _wrongBadgeExtent),
    fade,
  );

  final fill = Paint()..color = RoastyColors.eyeWhite;
  final stroke = Paint()
    ..color = mood.berry
    ..style = PaintingStyle.stroke
    ..strokeWidth = _wrongBadgeStroke;
  canvas.drawCircle(_wrongBadgeCenter, _wrongBadgeRadius, fill);
  canvas.drawCircle(_wrongBadgeCenter, _wrongBadgeRadius, stroke);
  final bar = Paint()..color = mood.berry;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(146, 68, 4, 9),
      const Radius.circular(1),
    ),
    bar,
  );
  canvas.drawCircle(const Offset(148, 82), 1.6, bar);

  canvas.restore();
}

/// The plate the burst's line sits on, above the bean.
const _pointsBurstRect = Rect.fromLTWH(68, 42, 64, 24);
const _pointsBurstRadius = Radius.circular(2);

/// The burst's type size and letter-spacing, in the mascot's own canvas units.
///
/// Off the type ladder, for the reason `grinder_dial_view.dart` is: this is
/// drawn on a canvas grid rather than set on a rung, so the same label reaches
/// the screen at a different size on every host. 13 here is never 13 logical
/// pixels, and 1 beside it is a ratio to it rather than a width `AppTracking`
/// could resolve.
const double _pointsBurstFontSize = 13;
const double _pointsBurstTracking = 1;

/// What the burst says: a signed amount in the design's `+N PTS` shape.
///
/// The amount is the caller's. A lesson pays what it authors (§5.1, #16), so
/// nothing in the mascot layer may name one — this only knows how to spell an
/// amount it is handed.
String roastyPointsBurstLabel(int amount) => '+$amount PTS';

/// The style of the burst's line: the design's mono on the mood's accent fill,
/// so it takes [MoodColors.accentInk] — the ink that reads on that fill.
///
/// Face from the ladder, size and tracking from the drawing, the same split
/// [roastySleepZStyle] makes.
TextStyle roastyPointsBurstStyle({
  required MoodColors mood,
  required double opacity,
}) => TextStyle(
  color: mood.accentInk.withValues(alpha: opacity.clamp(0.0, 1.0)),
  fontSize: _pointsBurstFontSize,
  letterSpacing: _pointsBurstTracking,
  fontFamily: AppFace.mono.family,
  fontWeight: AppFace.mono.weight,
);

void _paintPointsBurst(
  Canvas canvas,
  double progress,
  MoodColors mood,
  int amount,
) {
  final rise = roastyPointsBurstRise(progress);
  if (rise.opacity <= 0) return;

  canvas.save();
  canvas.translate(0, rise.dy);
  canvas.drawRRect(
    RRect.fromRectAndRadius(_pointsBurstRect, _pointsBurstRadius),
    Paint()..color = mood.accent.withValues(alpha: rise.opacity),
  );
  final line = TextPainter(
    text: TextSpan(
      text: roastyPointsBurstLabel(amount),
      style: roastyPointsBurstStyle(mood: mood, opacity: rise.opacity),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  line.paint(
    canvas,
    Offset(
      _pointsBurstRect.center.dx - line.width / 2,
      _pointsBurstRect.center.dy - line.height / 2,
    ),
  );
  canvas.restore();
}

void _paintSleepZzz(Canvas canvas, double progress, MoodColors mood) {
  const letters = <({double x, double y, double size, double delay})>[
    (x: 148, y: 80, size: 18, delay: 0.0),
    (x: 158, y: 68, size: 14, delay: 0.6 / 2.6),
    (x: 166, y: 58, size: 11, delay: 1.2 / 2.6),
  ];
  for (final letter in letters) {
    final raw = (progress - letter.delay) % 1.0;
    final phase = raw < 0 ? raw + 1 : raw;
    final opacity = phase < 0.3
        ? phase / 0.3
        : (phase > 0.7 ? (1 - phase) / 0.3 : 1.0);
    final dx = phase * 8;
    final dy = -phase * 12;
    final painter = TextPainter(
      text: TextSpan(
        text: 'z',
        style: roastySleepZStyle(
          mood: mood,
          size: letter.size,
          opacity: opacity,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(letter.x + dx, letter.y + dy));
  }
}

/// The style of one sleeping `z`: the mood's muted ink at [opacity], italic,
/// at the drawing's own [size].
///
/// Face from the ladder, size from the drawing — the same split
/// `grinder_dial_view.dart` makes, so a rename in the pubspec reaches this `z`
/// too.
TextStyle roastySleepZStyle({
  required MoodColors mood,
  required double size,
  required double opacity,
}) => TextStyle(
  color: mood.inkMute.withValues(alpha: opacity.clamp(0.0, 1.0)),
  fontStyle: FontStyle.italic,
  fontSize: size,
  fontFamily: AppFace.display.family,
  fontWeight: AppFace.display.weight,
);
