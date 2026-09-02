import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/dashed_rounded_border.dart';
import 'package:brew_path/features/challenges/domain/card_challenge_state.dart';
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

/// The mark in a tile's corner when its challenge is offered or done.
///
/// Solid for a challenge that has been brewed, dashed for one still open: the
/// design uses the same two languages the rest of the app does for *done* and
/// *available*, so the pair reads without a legend.
///
/// The design writes the ring as a bare `1px dashed` and names no pattern, so
/// it takes the app's own dash rhythm from [DashedRoundedBorder] rather than
/// inventing a second one.
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
    final edge = BorderSide(
      color: Color.lerp(
        mood.rule,
        mood.accent,
        tried ? _triedBorder : _openBorder,
      )!,
    );

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
                  side: edge,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                )
              : DashedRoundedBorder(radius: AppRadii.pill, side: edge),
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
