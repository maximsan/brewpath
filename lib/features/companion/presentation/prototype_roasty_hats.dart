// PROTOTYPE — THROWAWAY. Not production code, not wired into the app.
//
// Question it answers (wayfinder #13): can the existing hand-written Roasty
// CustomPainter absorb the Studio's 4 personalization axes — roast x hat x
// gear x sprout, 320 combinations — or does adding variants force a different
// drawing approach (flutter_svg, Rive, composed widgets)?
//
// Hats are the axis under test because they are the hard case: additive
// geometry that must stay glued to a body which hops, jumps, shakes and grows.
// Roast is a colour swap and sprout already half-exists, so if hats hold, they
// hold too.
//
// Run:  flutter run -t lib/features/companion/presentation/prototype_roasty_hats.dart
//
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:math' as math;

import 'package:coffee_quest/features/companion/domain/roasty_state.dart';
import 'package:coffee_quest/features/companion/presentation/roasty_animation.dart';
import 'package:coffee_quest/features/companion/presentation/roasty_body.dart';
import 'package:coffee_quest/features/companion/presentation/roasty_faces.dart';
import 'package:coffee_quest/features/companion/presentation/roasty_particles.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FINDING 1 — the body transform was already duplicated before this spike.
//
// `paintRoastyBody` and `_RoastyPainter._paintFace` each open with the same
// six lines: translate to (100,158)+offset, rotate, scale, translate back.
// A hat needs it too, which would have made a third copy. Extracted here as
// the one thing every body-riding layer shares. If this is not extracted, each
// new axis silently adds another copy of the transform, and a change to the
// jump curve has to be made in N places.
// ─────────────────────────────────────────────────────────────────────────────

/// Runs [paint] inside the per-state body transform, so any layer drawn in it
/// tracks the bean through every animation.
void withBodyTransform(
  Canvas canvas,
  RoastyState state,
  double t,
  VoidCallback paint,
) {
  canvas.save();
  final offset = roastyBodyOffset(state, t);
  canvas.translate(100 + offset.dx, 158 + offset.dy);
  canvas.rotate(roastyBodyRotation(state, t));
  canvas.scale(roastyBodyScale(state, t));
  canvas.translate(-100, -158);
  paint();
  canvas.restore();
}

// ─────────────────────────────────────────────────────────────────────────────
// The axis under test.
// ─────────────────────────────────────────────────────────────────────────────

enum RoastyHat {
  none('None'),
  beanie('Beanie'),
  field('Field hat'),
  cap('Cap');

  const RoastyHat(this.label);
  final String label;
}

// Bean crown geometry, read off roasty_body.dart: the body path starts at
// (100, 90) and spans x 38..162. Hats sit on that crown.
const double _crownY = 90;
const double _crownCx = 100;

const _wool = Color(0xFFB8503A);
const _woolDark = Color(0xFF8E3B2B);
const _straw = Color(0xFFD8B678);
const _strawDark = Color(0xFFB08E52);
const _capCloth = Color(0xFF5F6E55);
const _capClothDark = Color(0xFF44503C);

/// Paints [hat] on the bean's crown. Caller supplies the body transform, so
/// this draws in rest coordinates only — the same contract the face follows.
void paintRoastyHat(Canvas canvas, RoastyHat hat, RoastyState state, double t) {
  switch (hat) {
    case RoastyHat.none:
      return;
    case RoastyHat.beanie:
      _paintBeanie(canvas, state, t);
    case RoastyHat.field:
      _paintFieldHat(canvas);
    case RoastyHat.cap:
      _paintCap(canvas);
  }
}

void _paintBeanie(Canvas canvas, RoastyState state, double t) {
  final crown = Paint()..color = _wool;
  // Skull: an arc capping the bean's dome.
  final skull = Path()
    ..moveTo(_crownCx - 40, _crownY + 26)
    ..cubicTo(
      _crownCx - 40, _crownY - 14,
      _crownCx + 40, _crownY - 14,
      _crownCx + 40, _crownY + 26,
    )
    ..close();
  canvas.drawPath(skull, crown);
  // Brim band.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(_crownCx, _crownY + 27),
        width: 86,
        height: 15,
      ),
      const Radius.circular(7),
    ),
    Paint()..color = _woolDark,
  );
  // Pompom — the one hat element with its own motion, so it can lag the body
  // on a hop. FINDING 3 below.
  final lag = math.sin(t * math.pi * 2) * 3;
  canvas.drawCircle(
    Offset(_crownCx, _crownY - 16 + lag),
    9,
    Paint()..color = _woolDark,
  );
}

void _paintFieldHat(Canvas canvas) {
  // Wide brim, drawn first so the crown overlaps it.
  canvas.drawOval(
    Rect.fromCenter(
      center: const Offset(_crownCx, _crownY + 24),
      width: 132,
      height: 26,
    ),
    Paint()..color = _straw,
  );
  final crown = Path()
    ..moveTo(_crownCx - 33, _crownY + 24)
    ..cubicTo(
      _crownCx - 30, _crownY - 12,
      _crownCx + 30, _crownY - 12,
      _crownCx + 33, _crownY + 24,
    )
    ..close();
  canvas.drawPath(crown, Paint()..color = _straw);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(_crownCx, _crownY + 18),
        width: 68,
        height: 11,
      ),
      const Radius.circular(5),
    ),
    Paint()..color = _strawDark,
  );
}

void _paintCap(Canvas canvas) {
  // Peak points right — asymmetric, so rotation on `correct` is visible.
  final peak = Path()
    ..moveTo(_crownCx + 20, _crownY + 18)
    ..quadraticBezierTo(
      _crownCx + 62, _crownY + 16,
      _crownCx + 58, _crownY + 27,
    )
    ..quadraticBezierTo(
      _crownCx + 44, _crownY + 25,
      _crownCx + 20, _crownY + 26,
    )
    ..close();
  canvas.drawPath(peak, Paint()..color = _capClothDark);
  final crown = Path()
    ..moveTo(_crownCx - 36, _crownY + 22)
    ..cubicTo(
      _crownCx - 36, _crownY - 12,
      _crownCx + 36, _crownY - 12,
      _crownCx + 36, _crownY + 22,
    )
    ..close();
  canvas.drawPath(crown, Paint()..color = _capCloth);
  canvas.drawCircle(
    const Offset(_crownCx, _crownY - 9),
    4.5,
    Paint()..color = _capClothDark,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FINDING 2 — layer ORDER is per-axis, not global.
//
// The real painter runs a fixed stack: particlesBack, sprout, body, face,
// particlesFront. A hat cannot simply join the end — it must sit ABOVE the
// body but BELOW front particles, and critically it must occlude the SPROUT,
// which is drawn before the body and emerges from the same crown the hat
// covers. A beanie with leaves poking through it looks broken.
//
// So each axis declares where it sits in the stack. That is a real constraint
// on the model — a flat `List<Layer>` would not capture it — but it is a
// small one, and it does not threaten the CustomPainter approach.
// ─────────────────────────────────────────────────────────────────────────────

class PrototypeRoastyPainter extends CustomPainter {
  PrototypeRoastyPainter({
    required this.state,
    required this.t,
    required this.hat,
  });

  final RoastyState state;
  final double t;
  final RoastyHat hat;

  static const double _vbW = 200;
  static const double _vbH = 280;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final s = math.min(size.width / _vbW, size.height / _vbH);
    canvas.translate((size.width - _vbW * s) / 2, (size.height - _vbH * s) / 2);
    canvas.scale(s, s);

    paintRoastyParticlesBack(canvas, state, t);
    // Sprout is hidden under a full-crown hat rather than clipped: cheaper,
    // and matches what the Studio preview does in the prototype.
    if (hat == RoastyHat.none) {
      paintRoastySprout(canvas, state, t, null);
    }
    paintRoastyBody(canvas, state, t);
    withBodyTransform(canvas, state, t, () => paintRoastyFace(canvas, state));
    withBodyTransform(
      canvas,
      state,
      t,
      () => paintRoastyHat(canvas, hat, state, t),
    );
    paintRoastyParticlesFront(canvas, state, t);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PrototypeRoastyPainter old) =>
      old.state != state || old.t != t || old.hat != hat;
}

// ─────────────────────────────────────────────────────────────────────────────
// Harness — hat switcher x state switcher, so every combination is one tap.
// ─────────────────────────────────────────────────────────────────────────────

void main() => runApp(const _PrototypeApp());

class _PrototypeApp extends StatelessWidget {
  const _PrototypeApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A130E),
    ),
    home: const _HatLab(),
  );
}

class _HatLab extends StatefulWidget {
  const _HatLab();

  @override
  State<_HatLab> createState() => _HatLabState();
}

class _HatLabState extends State<_HatLab> with SingleTickerProviderStateMixin {
  RoastyHat _hat = RoastyHat.beanie;
  // Frozen mid-`lesson` at t=0.3 — the peak of the jump, where the body is
  // translated -18 and furthest from rest. If a hat is going to detach from
  // the bean, this is the frame that shows it.
  RoastyState _state = RoastyState.lesson;
  int _replay = 0;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: roastyDuration(RoastyState.lesson),
  )..value = 0.3;

  void _play(RoastyState next) {
    setState(() {
      _state = next;
      _replay++;
    });
    _controller
      ..stop()
      ..duration = roastyDuration(next)
      ..reset();
    if (roastyLoops(next)) {
      unawaited(_controller.repeat());
    } else {
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              'PROTOTYPE · Roasty hats',
              style: TextStyle(
                color: Color(0xFFB59E84),
                fontSize: 11,
                letterSpacing: 1.8,
              ),
            ),
            // All four hats at the SAME animation frame. If the transform
            // extraction works, every hat sits on its bean identically no
            // matter how far the body has hopped/jumped/grown away from rest.
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, _) => GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    for (final h in RoastyHat.values)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: CustomPaint(
                              size: const Size(150, 210),
                              painter: PrototypeRoastyPainter(
                                state: _state,
                                t: _controller.value,
                                hat: h,
                              ),
                            ),
                          ),
                          Text(
                            h.label,
                            style: TextStyle(
                              color: _hat == h
                                  ? const Color(0xFFE07A4F)
                                  : const Color(0xFF8C7A66),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            _Row(
              label: 'HAT',
              children: [
                for (final h in RoastyHat.values)
                  _Chip(
                    label: h.label,
                    on: _hat == h,
                    onTap: () => setState(() => _hat = h),
                  ),
              ],
            ),
            _Row(
              label: 'STATE',
              children: [
                for (final s in RoastyState.values)
                  _Chip(
                    label: s.name,
                    on: _state == s,
                    onTap: () => _play(s),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 2),
              child: Text(
                'replay #$_replay · ${roastyDuration(_state).inMilliseconds}ms'
                ' · ${roastyLoops(_state) ? "loop" : "one-shot"}',
                style: const TextStyle(
                  color: Color(0xFFB59E84),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.children});
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    child: Row(
      children: [
        SizedBox(
          width: 46,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8C7A66),
              fontSize: 9,
              letterSpacing: 1.4,
            ),
          ),
        ),
        Expanded(
          child: Wrap(spacing: 6, runSpacing: 6, children: children),
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: on ? const Color(0xFFE07A4F) : const Color(0xFF30231A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: on ? const Color(0xFF1A130E) : const Color(0xFFB59E84),
          fontSize: 12,
        ),
      ),
    ),
  );
}
