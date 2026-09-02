import 'dart:math' as math;

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The corner's own metrics (`screens.jsx:2420`).
const double _cornerSize = 26;
const double _markSize = 13;
const double _openMarkSize = 12;
const double _openDotRadius = 1.6;
const double _openRingRadius = 4.4;
const double _openRingStroke = 1.3;

/// How much accent goes into each corner's fill and border.
const double _triedFill = 0.16;
const double _triedBorder = 0.4;
const double _openFill = 0.08;
const double _openBorder = 0.5;

/// What a card's Coffee Challenge is doing, as the tile shows it.
enum CardChallengeState {
  /// No challenge on this card, or none the learner can act on.
  none,

  /// There is one to brew — the design rings it, dashed, as an offer.
  open,

  /// Brewed. The design stamps it.
  tried,
}

/// The mark in a tile's corner when its challenge is offered or done.
///
/// Solid for a challenge that has been brewed, dashed for one still open: the
/// design uses the same two languages the rest of the app does for *done* and
/// *available*, so the pair reads without a legend.
class CardChallengeCorner extends StatelessWidget {
  const CardChallengeCorner._({required this.state});

  /// The corner for [state], or **null** when there is nothing to mark.
  ///
  /// Null rather than an empty box: a widget that renders nothing still sits
  /// in the tree, where a test finds it and a reader has to work out that it
  /// draws air. One decision, made here, so no caller has to repeat it.
  static Widget? forState(CardChallengeState state) =>
      state == CardChallengeState.none
      ? null
      : CardChallengeCorner._(state: state);

  /// What the challenge is doing.
  final CardChallengeState state;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final tried = state == CardChallengeState.tried;

    return Semantics(
      label: tried ? 'Challenge tried' : 'Challenge to earn',
      excludeSemantics: true,
      child: Container(
        width: _cornerSize,
        height: _cornerSize,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: Color.lerp(
            mood.surface,
            mood.accent,
            tried ? _triedFill : _openFill,
          ),
          shape: tried
              ? RoundedRectangleBorder(
                  side: BorderSide(
                    color: Color.lerp(
                      mood.rule,
                      mood.accent,
                      _triedBorder,
                    )!,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                )
              : _DashedCircleBorder(
                  color: Color.lerp(mood.rule, mood.accent, _openBorder)!,
                ),
        ),
        child: tried
            ? IconMark(AppIcon.check, size: _markSize, color: mood.accent)
            : CustomPaint(
                size: const Size.square(_openMarkSize),
                painter: _OfferPainter(mood.accent),
              ),
      ),
    );
  }
}

/// The design's dashed ring — an offer, not a state.
class _DashedCircleBorder extends OutlinedBorder {
  const _DashedCircleBorder({required this.color})
    : super(side: BorderSide.none);

  final Color color;

  /// Dash and gap, in logical pixels on the ring itself.
  static const double _dash = 3;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final radius = rect.shortestSide / 2;
    final centre = rect.center;
    final circumference = 2 * math.pi * radius;
    final step = (_dash + _gap) / radius;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var drawn = 0.0; drawn < circumference; drawn += _dash + _gap) {
      final start = drawn / radius;
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: radius),
        start,
        step * (_dash / (_dash + _gap)),
        false,
        paint,
      );
    }
  }

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) => canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);

  @override
  bool get preferPaintInterior => true;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addOval(
        Rect.fromCircle(center: rect.center, radius: rect.shortestSide / 2),
      );

  @override
  ShapeBorder scale(double t) => this;

  @override
  _DashedCircleBorder copyWith({BorderSide? side, Color? color}) =>
      _DashedCircleBorder(color: color ?? this.color);
}

/// The ringed dot inside an open challenge's corner (`screens.jsx:2437`).
class _OfferPainter extends CustomPainter {
  const _OfferPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final scale = size.width / _openMarkSize;

    canvas
      ..drawCircle(
        centre,
        _openRingRadius * scale,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _openRingStroke * scale,
      )
      ..drawCircle(centre, _openDotRadius * scale, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_OfferPainter oldDelegate) => oldDelegate.color != color;
}
