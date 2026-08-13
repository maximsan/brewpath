import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// The illustration palette — **literal coffee, not UI meaning**.
///
/// These are the colours a drawing needs: the roast of a bean, the layers of a
/// cherry. They are identical in both moods on purpose — a ripe cherry is the
/// same colour under any theme — and they are deliberately *not* semantic
/// tokens: keeping cherry and bean colours out of `--warn` is what lets that
/// token mean exactly one thing (celebration).
///
/// So there is nothing here to reach a mood with. Every token is a
/// `static const` on a class that cannot be extended, implemented or
/// instantiated, and there is no `of(context)` accessor — mood-dependence is
/// unrepresentable rather than merely discouraged. That also makes them free to
/// use from inside `CustomPainter.paint()`, which has no `BuildContext` to
/// thread one through.
///
/// Values are transcribed 1:1 from the design bundle CSS
/// (`brew-path/index.html`, the `--art-*` / `--cream` block); the drift guard in
/// `test/unit/shared/theme/art_colors_test.dart` keeps them there.
///
/// Colours that *do* flip with the mood live on `MoodColors`; overlays that
/// must stay fixed live on `OverlayColors`.
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
}
