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
      _paintCorrectFace(canvas);
    case RoastyState.lesson:
      _paintLessonFace(canvas);
    case RoastyState.wrong:
      _paintWrongFace(canvas);
    case RoastyState.module:
      _paintModuleFace(canvas, mood);
    case RoastyState.points:
      _paintPointsFace(canvas);
    case RoastyState.card:
      _paintCardFace(canvas);
    case RoastyState.sleep:
      _paintSleepFace(canvas);
    case RoastyState.awake:
      _paintAwakeFace(canvas);
  }
}

// ── Face primitives ────────────────────────────────────────────────────
/// The tongue inside an open mouth, on the two faces that open one.
const _tongueOpacity = 0.7;

Paint get _eyeWhite => Paint()..color = RoastyColors.eyeWhite;
Paint get _pupil => Paint()..color = RoastyColors.mouth;
Paint get _mouthFill => Paint()..color = RoastyColors.mouth;
Paint get _tongue =>
    Paint()..color = RoastyColors.blush.withValues(alpha: _tongueOpacity);
Paint get _mouthStroke => Paint()
  ..color = RoastyColors.mouth
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2.5
  ..strokeCap = StrokeCap.round;

/// The blush pair, mirrored about the face at the design's own height.
///
/// Every face blushes and no two agree on the size or the alpha, so each
/// states its own rather than sharing one cheek: how hard Roasty blushes is
/// part of what makes a state read as sleepy, delighted or caught out.
void _paintCheeks(
  Canvas canvas, {
  required double cy,
  required double rx,
  required double ry,
  required double opacity,
}) {
  final paint = Paint()..color = RoastyColors.blush.withValues(alpha: opacity);
  for (final cx in const [68.0, 132.0]) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      paint,
    );
  }
}

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

/// How high a delighted eye arches. The wink arches shallower, which is what
/// keeps it reading as one eye closing rather than as half a grin.
const _delightedLift = 10.0;
const _winkLift = 6.0;

void _paintEyeArchUp(
  Canvas canvas,
  double cx,
  double cy, {
  double lift = _delightedLift,
}) {
  final arch = Path()
    ..moveTo(cx - 10, cy)
    ..quadraticBezierTo(cx, cy - lift, cx + 10, cy);
  canvas.drawPath(arch, _mouthStroke..strokeWidth = 3);
}

void _paintIdleFace(Canvas canvas) {
  _paintEyeOpen(canvas, 80, 148);
  _paintEyeOpen(canvas, 120, 148);
  _paintCheeks(canvas, cy: 172, rx: 6, ry: 3, opacity: 0.45);
  final mouth = Path()
    ..moveTo(90, 180)
    ..quadraticBezierTo(100, 188, 110, 180);
  canvas.drawPath(mouth, _mouthStroke);
}

/// The arched eyes and blush the correct and lesson faces share. Only the
/// mouth below them tells the two apart.
void _paintDelightedEyesAndCheeks(Canvas canvas) {
  _paintEyeArchUp(canvas, 80, 148);
  _paintEyeArchUp(canvas, 120, 148);
  _paintCheeks(canvas, cy: 170, rx: 7, ry: 3.5, opacity: 0.55);
}

void _paintCorrectFace(Canvas canvas) {
  _paintDelightedEyesAndCheeks(canvas);
  final mouth = Path()
    ..moveTo(86, 178)
    ..quadraticBezierTo(100, 192, 114, 178);
  canvas.drawPath(mouth, _mouthStroke..strokeWidth = 3);
}

/// Finishing a lesson is a bigger moment than getting one answer right, and
/// the design says so with the mouth: a filled open grin with a tongue in it,
/// where [_paintCorrectFace] draws a stroked smile.
void _paintLessonFace(Canvas canvas) {
  _paintDelightedEyesAndCheeks(canvas);
  final mouth = Path()
    ..moveTo(84, 178)
    ..quadraticBezierTo(100, 198, 116, 178)
    ..quadraticBezierTo(100, 188, 84, 178)
    ..close();
  canvas.drawPath(mouth, _mouthFill);
  final tongue = Path()
    ..moveTo(92, 186)
    ..quadraticBezierTo(100, 192, 108, 186)
    ..quadraticBezierTo(100, 190, 92, 186)
    ..close();
  canvas.drawPath(tongue, _tongue);
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
  _paintCheeks(canvas, cy: 174, rx: 5, ry: 2.5, opacity: 0.3);
}

/// The module face's star eye, as the design draws it.
///
/// Transcribed rather than generated. The design's star is hand-drawn and
/// slightly irregular — its inner points sit at radii 4.24 and 5.39 rather
/// than on one circle, and it reaches further below the centre than above —
/// so a computed regular star loses the very thing that makes it look drawn.
const _starEye = <Offset>[
  Offset(0, -11),
  Offset(3, -3),
  Offset(11, -3),
  Offset(5, 2),
  Offset(7, 10),
  Offset(0, 5),
  Offset(-7, 10),
  Offset(-5, 2),
  Offset(-11, -3),
  Offset(-3, -3),
];

void _paintStarEye(Canvas canvas, double cx, double cy, Color colour) {
  final path = Path()..moveTo(cx + _starEye.first.dx, cy + _starEye.first.dy);
  for (final point in _starEye.skip(1)) {
    path.lineTo(cx + point.dx, cy + point.dy);
  }
  path.close();
  canvas.drawPath(path, Paint()..color = colour);
}

void _paintModuleFace(Canvas canvas, MoodColors mood) {
  _paintStarEye(canvas, 80, 148, mood.warn);
  _paintStarEye(canvas, 120, 148, mood.warn);
  _paintCheeks(canvas, cy: 172, rx: 7, ry: 3.5, opacity: 0.55);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(100, 185), width: 16, height: 18),
    _mouthFill,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(100, 188), width: 10, height: 8),
    _tongue,
  );
}

/// The wink Roasty gives a payout: one eye still open with its catchlight, the
/// other arched shut, and a mouth that lifts on the winking side rather than
/// curving level the way every other smile here does.
void _paintPointsFace(Canvas canvas) {
  _paintEyeOpen(canvas, 80, 148);
  _paintEyeArchUp(canvas, 120, 148, lift: _winkLift);
  _paintCheeks(canvas, cy: 170, rx: 6, ry: 3, opacity: 0.5);
  final mouth = Path()
    ..moveTo(90, 180)
    ..quadraticBezierTo(100, 188, 113, 178);
  canvas.drawPath(mouth, _mouthStroke);
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
  _paintCheeks(canvas, cy: 172, rx: 7, ry: 3.5, opacity: 0.5);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(100, 184), width: 10, height: 12),
    _mouthFill,
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
  _paintCheeks(canvas, cy: 172, rx: 6, ry: 3, opacity: 0.35);
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
  _paintCheeks(canvas, cy: 172, rx: 6, ry: 3, opacity: 0.4);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(100, 184), width: 8, height: 10),
    _mouthFill,
  );
}
