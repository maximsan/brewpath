import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// The illustration palette — literal coffee, identical in both moods, and
/// never a semantic token, so `--warn` keeps meaning exactly one thing.
///
/// Transcribed 1:1 from the design bundle's `--art-*` block, and held there by
/// the drift guard. No `of(context)`: a painter reads these with no context,
/// and mood-dependence is unrepresentable rather than discouraged.
abstract final class ArtColors {
  /// Unroasted green coffee — the first stage of the roast ramp.
  static const raw = Color(0xFF9FB088);

  /// Light roast.
  static const roastLight = Color(0xFFC79A63);

  /// Medium roast.
  static const roastMid = Color(0xFFA2703C);

  /// Dark roast.
  static const roastDeep = Color(0xFF7A4526);

  /// Espresso roast — the last stage of the roast ramp.
  static const roastDark = Color(0xFF54301C);

  /// The roast ramp in roasting order, raw green → espresso.
  ///
  /// One colour story app-wide: the roast meter and every roast drawing read
  /// the same five stops, so "light / medium / dark" never means two different
  /// browns in two different components. Use [roastAt] to read a point on it.
  static const roastRamp = <Color>[
    raw,
    roastLight,
    roastMid,
    roastDeep,
    roastDark,
  ];

  /// Cherry skin (exocarp) — the outermost layer.
  static const cherrySkin = Color(0xFFA93227);

  /// Cherry pulp (mesocarp).
  static const cherryPulp = Color(0xFFC9563A);

  /// Mucilage — the pectin gel glued to the seed.
  static const cherryGel = Color(0xFFD9A94C);

  /// Parchment (pergamino) — the papery shell coffee ships inside.
  static const cherryParchment = Color(0xFFE3D2AE);

  /// Silverskin (spermoderm) — the membrane that becomes chaff.
  static const cherrySilverskin = Color(0xFFF1E8D6);

  /// The seed (endosperm) — the bean itself.
  static const cherrySeed = Color(0xFF8FA184);

  /// The cherry ramp in cross-section order, outside in: skin → seed.
  static const cherryRamp = <Color>[
    cherrySkin,
    cherryPulp,
    cherryGel,
    cherryParchment,
    cherrySilverskin,
    cherrySeed,
  ];

  /// The crease where the two seeds meet along their flat faces.
  static const seedCrease = Color(0xFF5C6B52);

  /// A ripe cherry.
  static const ripe = Color(0xFFC8843A);

  /// An underripe / sour cherry.
  static const sour = Color(0xFFB79A3C);

  /// Highlight on illustration fills.
  static const cream = Color(0xFFF0DCB8);

  /// Outline on illustration fills, drawn with a stroke opacity. Cupping ink
  /// by coincidence: the design keeps it "fixed like the other art tokens".
  static const hairline = Color(0xFF1B1614);

  /// The roast at [progress] along the ramp: 0 is [raw], 1 is [roastDark].
  ///
  /// The meter roasts continuously rather than stepping between the five stops,
  /// so this blends between the two stops [progress] falls between.
  /// Out-of-range input clamps to the ends of the ramp rather than running off
  /// it.
  static Color roastAt(double progress) {
    final scaled = progress.clamp(0.0, 1.0) * (roastRamp.length - 1);
    final stop = math.min(roastRamp.length - 2, scaled.floor());
    return Color.lerp(roastRamp[stop], roastRamp[stop + 1], scaled - stop)!;
  }

  /// Every token under the name the design source calls it, for content that
  /// names a colour as `--art-cherry-seed` rather than as a hex literal.
  ///
  /// Kept here once: the drift guard reads this map and compares it against
  /// its own transcribed values, so a second copy could never drift unseen.
  static const byTokenName = <String, Color>{
    '--art-raw': raw,
    '--art-roast-light': roastLight,
    '--art-roast-mid': roastMid,
    '--art-roast-deep': roastDeep,
    '--art-roast-dark': roastDark,
    '--art-cherry-skin': cherrySkin,
    '--art-cherry-pulp': cherryPulp,
    '--art-cherry-gel': cherryGel,
    '--art-cherry-parchment': cherryParchment,
    '--art-cherry-silverskin': cherrySilverskin,
    '--art-cherry-seed': cherrySeed,
    '--art-seed-crease': seedCrease,
    '--art-ripe': ripe,
    '--art-sour': sour,
    '--art-cream': cream,
    '--art-hairline': hairline,
  };

  /// The colour the design source names [token], e.g. `--art-cherry-seed`.
  ///
  /// Throws on a name the palette does not carry: a fallback colour would draw
  /// something plausible and wrong, and a missing token is a bug to surface.
  static Color ofToken(String token) {
    final colour = byTokenName[token];
    if (colour == null) {
      throw ArgumentError.value(
        token,
        'token',
        'not a colour in the illustration palette; expected one of '
            '${byTokenName.keys.join(', ')}',
      );
    }
    return colour;
  }
}
