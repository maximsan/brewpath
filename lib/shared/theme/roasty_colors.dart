import 'package:flutter/painting.dart';

/// The mascot's palette — Roasty's bean, sprout and face.
///
/// A bean is the same brown under any theme, so these are identical in both
/// moods, and they follow the rule `ArtColors` set: `static const` on a class
/// that cannot be extended, implemented or instantiated, with no `of(context)`
/// accessor. Mood-dependence is unrepresentable, and the painters can read
/// them from inside `CustomPainter.paint()`, which has no `BuildContext`.
///
/// The named tokens are transcribed 1:1 from the `/* Roasty palette */` block
/// of the mascot's design page; the five below it are the colours the drawings
/// use that the block does not name, which the mascot component writes as the
/// same hex literal in both moods. The drift guard in
/// `test/unit/shared/theme/roasty_colors_test.dart` pins both to the source.
///
/// **Not everything Roasty draws with is here.** The mascot component gives
/// its celebration marks to the mood: the module stars and rays and two of the
/// four sparkles are `--warn`, the wrong badge is `--berry`, and the sleeping
/// `z`s are `--ink-mute`. Those flip with the theme, so the painters read them
/// off the `MoodColors` their host hands them rather than from this class.
abstract final class RoastyColors {
  /// The bean's edge — the last stop of the body gradient.
  static const beanDeep = Color(0xFF4A2B19);

  /// The bean's mid-tone.
  static const beanBody = Color(0xFF6B3E22);

  /// The lit side of the bean — the first stop of the body gradient.
  static const beanWarm = Color(0xFF8C5634);

  /// The contact shadow under the bean, and the crease down its front.
  static const beanShadow = Color(0xFF2F1A0E);

  /// The sprout's leaf green. Declared by the design; the drawings shade the
  /// leaf with [leafHilite] and [leafDeep] instead.
  static const leaf = Color(0xFF8A9D6B);

  /// The stem, the leaf veins, and the dark end of the leaf gradient.
  static const leafDeep = Color(0xFF5E7148);

  /// The lit end of the leaf gradient.
  static const leafHilite = Color(0xFFB5C497);

  /// The whites of the eyes, the catchlights, and the wrong badge's fill.
  static const eyeWhite = Color(0xFFFBF7EE);

  /// Pupils, mouths, brows and closed eyes.
  static const mouth = Color(0xFF2A1B12);

  /// The cheeks.
  static const blush = Color(0xFFC47654);

  /// The soft top highlight on the bean.
  static const beanHighlight = Color(0xFFA26945);

  /// The glow behind the bean on the card state.
  static const cardGlow = Color(0xFFE6C68A);

  /// The red confetti pieces, and the small sparkle.
  static const confettiEmber = Color(0xFFB8533A);

  /// The grey-green confetti pieces, and the medium sparkle.
  static const confettiMoss = Color(0xFF7A8471);

  /// The gold confetti pieces.
  static const confettiGold = Color(0xFFC8843A);

  /// The bean's radial gradient, centre out: lit → mid → edge.
  static const beanGradient = <Color>[beanWarm, beanBody, beanDeep];

  /// The leaf's radial gradient, centre out: lit → dark.
  static const leafGradient = <Color>[leafHilite, leafDeep];

  /// Every named token under the name the design page calls it, for the drift
  /// guard.
  static const byTokenName = <String, Color>{
    '--bean-deep': beanDeep,
    '--bean-body': beanBody,
    '--bean-warm': beanWarm,
    '--bean-shadow': beanShadow,
    '--leaf': leaf,
    '--leaf-deep': leafDeep,
    '--leaf-hilite': leafHilite,
    '--eye-white': eyeWhite,
    '--mouth': mouth,
    '--blush': blush,
  };
}
