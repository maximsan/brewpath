import 'package:brew_path/features/lessons/presentation/cards/bagpick_bean.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// One green bean from the sample, drawn.
///
/// Holds no logic of its own: every colour and coordinate comes from
/// `bagpick_bean.dart`, so this widget and its painter are only strokes. What
/// is worth testing about a bean is tested there, without a canvas.
class BagpickBeanView extends StatelessWidget {
  /// Creates a [BagpickBeanView].
  const BagpickBeanView({
    required this.bean,
    required this.seed,
    required this.size,
    this.turns = 0,
    super.key,
  });

  /// The round's description of the sample.
  final BagpickBean bean;

  /// This bean's place in the sample, which decides its mottling.
  final int seed;

  /// Drawn width; the bean is slightly taller than wide, as a seed is.
  final double size;

  /// A quarter-turn fraction, so the three beans do not lie in parallel.
  final double turns;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.04,
      child: RotationTransition(
        turns: AlwaysStoppedAnimation(turns),
        child: CustomPaint(
          painter: _BeanPainter(
            body: beanColour(bean.body),
            crease: beanColour(bean.crease),
            patches: beanPatches(mottle: bean.mottle, seed: seed),
            chaff: beanChaff(chaff: bean.chaff),
          ),
        ),
      ),
    );
  }
}

class _BeanPainter extends CustomPainter {
  const _BeanPainter({
    required this.body,
    required this.crease,
    required this.patches,
    required this.chaff,
  });

  /// The ink the design draws a seed's own shading with — a near-black at low
  /// opacity, so it reads on any body colour rather than tinting toward one.
  ///
  /// Registered rather than written as a literal: it happens to equal Cupping
  /// `ink`, and left bare it reads as a mood token someone forgot to wire up.
  static final Color _shading = OffTokens.seedInk.value;
  static const _shadowOpacity = 0.18;
  static const _outlineOpacity = 0.35;
  static const _creaseShadowOpacity = 0.3;

  /// The fruit staining of a seed dried in its own cherry. The design draws it
  /// and never names it, so there is no `--art-*` token to read.
  static final Color _mottleInk = OffTokens.seedStain.value;

  /// Silverskin clinging to the seed — the token's own description names it
  /// as chaff, which is exactly this.
  static const Color _chaffInk = ArtColors.cherrySilverskin;

  static const _outlineWidth = 0.7;
  static const _creaseShadowWidth = 2.9;
  static const _creaseWidth = 2.0;

  final Color body;
  final Color crease;
  final List<BeanPatch> patches;
  final List<BeanPatch> chaff;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / beanCanvas, size.height / (beanCanvas * 1.04));

    canvas
      ..drawOval(
        beanShadow,
        Paint()..color = _shading.withValues(alpha: _shadowOpacity),
      )
      ..drawOval(beanBody, Paint()..color = body);

    _paintPatches(canvas, patches, _mottleInk);

    canvas
      ..drawOval(
        beanBody,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _outlineWidth
          ..color = _shading.withValues(alpha: _outlineOpacity),
      )
      ..drawPath(
        beanCrease,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _creaseShadowWidth
          ..strokeCap = StrokeCap.round
          ..color = _shading.withValues(alpha: _creaseShadowOpacity),
      )
      ..drawPath(
        beanCrease,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _creaseWidth
          ..strokeCap = StrokeCap.round
          ..color = crease,
      );

    _paintPatches(canvas, chaff, _chaffInk);
    canvas.restore();
  }

  void _paintPatches(Canvas canvas, List<BeanPatch> marks, Color ink) {
    for (final mark in marks) {
      canvas.drawOval(
        Rect.fromCenter(
          center: mark.centre,
          width: mark.radius.width * 2,
          height: mark.radius.height * 2,
        ),
        Paint()..color = ink.withValues(alpha: mark.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_BeanPainter old) =>
      old.body != body ||
      old.crease != crease ||
      old.patches != patches ||
      old.chaff != chaff;
}
