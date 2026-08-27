import 'package:brew_path/core/widgets/bean_shape.dart';
import 'package:brew_path/core/widgets/roast_meter_math.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// A coffee bean that **roasts as a run advances** — the design's `RoastBean`.
///
/// Raw green at the first card, espresso-dark at the last, moving a little on
/// every card in between. It reports *where you are, never how well you did*,
/// which is why it has no fill state at all: a bean that filled would be the
/// mastery gauge (`BeanGauge`), and the two must never be read for each other.
///
/// The roast colours are literal coffee, so they come from [ArtColors] and are
/// identical in both moods; only the outline follows the mood.
class RoastBean extends StatelessWidget {
  /// Creates a [RoastBean] showing [position] of [total].
  const RoastBean({
    required this.position,
    required this.total,
    this.size = _defaultSize,
    super.key,
  });

  /// The card being played, 1-based. (The design calls this prop `done` and
  /// passes it `idx + 1`; here it is named for what it holds.)
  final int position;

  /// How many cards the run plays.
  final int total;

  /// Rendered width and height; the bean is always square.
  final double size;

  /// The design's `size={22}`.
  static const double _defaultSize = 22;

  /// The design's `fill 420ms cubic-bezier(.34,1.18,.5,1)`.
  static const Duration roastDuration = Duration(milliseconds: 420);

  /// The curve that duration is paired with. It overshoots (control point
  /// 1.18) so the roast arrives with a small settle; [ArtColors.roastAt]
  /// clamps, so the overshoot cannot run off the end of the ramp.
  static const Curve roastCurve = Cubic(0.34, 1.18, 0.5, 1);

  @override
  Widget build(BuildContext context) {
    final outline = context.mood.inkMute;
    final target = roastProgress(position: position, total: total);

    return SizedBox.square(
      dimension: size,
      // No animation means no animator, not a zero-length one: reduced motion
      // paints the roast the run is actually at.
      child: MediaQuery.disableAnimationsOf(context)
          ? _bean(target, outline)
          : TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: target, end: target),
              duration: roastDuration,
              curve: roastCurve,
              builder: (_, progress, _) => _bean(progress, outline),
            ),
    );
  }

  Widget _bean(double progress, Color outline) => CustomPaint(
    painter: RoastBeanPainter(
      roast: ArtColors.roastAt(progress),
      outline: outline,
    ),
  );
}

/// Paints [RoastBean]'s silhouette in one solid [roast].
///
/// Public so a test can pin the colour the bean is actually being painted in —
/// the one property of this widget that carries meaning.
class RoastBeanPainter extends CustomPainter {
  /// Creates a [RoastBeanPainter].
  const RoastBeanPainter({required this.roast, required this.outline});

  /// The roast the bean is filled with, a point on [ArtColors.roastRamp].
  final Color roast;

  /// The bean's hairline, in the mood's muted ink.
  final Color outline;

  /// Both strokes are in the authoring box's units, scaled with the bean.
  static const double _outlineWidth = 1;
  static const double _creaseWidth = 1.5;

  /// The design's `strokeOpacity="0.34"` on the crease.
  static const double _creaseOpacity = 0.34;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    BeanShape.applyTo(canvas, size);

    final bean = BeanShape.ovalPath();
    canvas.drawPath(bean, Paint()..color = roast);
    canvas.drawPath(
      bean,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _outlineWidth
        ..color = outline,
    );
    canvas.drawPath(
      BeanShape.creasePath(),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = _creaseWidth
        ..color = OffTokens.beanCrease.value.withValues(alpha: _creaseOpacity),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(RoastBeanPainter old) =>
      old.roast != roast || old.outline != outline;
}
