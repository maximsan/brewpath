import 'package:brew_path/shared/theme/roasty_colors.dart';
import 'package:flutter/painting.dart';

/// What Roasty's wardrobe is drawn in — the four roast gradients, the hats,
/// the gear and the sprouts.
///
/// `RoastyColors`' rules, for its reasons: a beanie is the same red under any
/// theme. A value the design reuses from the mascot's own palette is
/// referenced there rather than restated, so the two cannot drift apart.
abstract final class RoastyOutfitColors {
  /// The lightest roast, centre out: lit → mid → edge.
  static const List<Color> roastLight = <Color>[
    Color(0xFFC49A6C),
    Color(0xFFA87B4F),
    Color(0xFF855B36),
  ];

  /// The default roast — the bean's own gradient, which is what `medium` is.
  static const List<Color> roastMedium = RoastyColors.beanGradient;

  /// A darker bean.
  static const List<Color> roastDark = <Color>[
    Color(0xFF6E4329),
    Color(0xFF4A2C19),
    Color(0xFF2C190E),
  ];

  /// The darkest roast, nearly black at the edge.
  static const List<Color> roastEspresso = <Color>[
    Color(0xFF4A2E1C),
    Color(0xFF2F1B10),
    Color(0xFF180C06),
  ];

  /// The beanie's body, and the cherry on the sprig sprout.
  static const Color ember = RoastyColors.confettiEmber;

  /// The beanie's turned brim, and the cherry's shaded side.
  static const Color emberDeep = Color(0xFF9E4632);

  /// The highlight on the cherry.
  static const Color cherryBlush = Color(0xFFE0997A);

  /// The field hat's brim.
  static const Color strawBrim = Color(0xFFC9A35E);

  /// Its crown, lighter than the brim it sits on.
  static const Color strawCrown = Color(0xFFD9B873);

  /// Its band, and the line that edges the brim.
  static const Color strawBand = Color(0xFFA8823F);

  /// The cap's crown, and the scarf.
  static const Color moss = RoastyColors.confettiMoss;

  /// The cap's peak, and its button.
  static const Color mossDeep = Color(0xFF5E6857);

  /// The scarf's hanging tail and its fold line.
  static const Color scarfShade = Color(0xFF6B7563);

  /// Frames, lenses and headphone shells — the same near-black the face is
  /// drawn in.
  static const Color gearDark = RoastyColors.mouth;

  /// Glass, the blossom's petals, and the glint on a lens.
  static const Color gearLight = RoastyColors.eyeWhite;

  /// The headphone ear cushions.
  static const Color cushion = RoastyColors.confettiEmber;

  /// The blossom's centre.
  static const Color blossomHeart = RoastyColors.confettiGold;

  /// The four roast gradients by the id the bank ships, so a roast the app has
  /// no stops for falls back to the bean's own rather than failing to paint.
  static const byRoast = <String, List<Color>>{
    'light': roastLight,
    'medium': roastMedium,
    'dark': roastDark,
    'espresso': roastEspresso,
  };

  /// The gradient for [roast], or the default bean when the id is unknown.
  static List<Color> roastGradient(String roast) =>
      byRoast[roast] ?? roastMedium;
}
