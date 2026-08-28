import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A value the design deliberately places **outside** the token system, holding
/// the reason it is allowed to be there.
///
/// The token system is meant to be total: every colour comes from `MoodColors`,
/// `ArtColors` or `OverlayColors`, and anything else is a magic literal. But
/// the design does sanction exceptions, and an exception with nowhere to live
/// gets written as a bare literal with a lint suppression — or, worse, gets
/// "fixed" into a token later and quietly breaks. Wrapping it forces the
/// [reason] to be written down next to the value, and makes every read say so
/// at the call site: `OffTokens.rewardedAdProgressRing.value`.
///
/// New entries belong in [OffTokens], not scattered through feature code.
///
/// `final` for the same reason the token holders are: a subclass could override
/// [value] with a getter that reads the mood, which is the one thing this whole
/// layer exists to make impossible.
@immutable
final class OffToken<T extends Object> {
  /// Records [value] as off-token, for the stated [reason].
  const OffToken(this.value, {required this.reason});

  /// The off-token value itself.
  final T value;

  /// Why this value does not come from a token. Written for the reader who
  /// finds it in a year and assumes it is an oversight.
  final String reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OffToken<T> && other.value == value && other.reason == reason;

  @override
  int get hashCode => Object.hash(value, reason);

  @override
  String toString() => 'OffToken($value, reason: $reason)';
}

/// The register of sanctioned off-token values — the whole list, in one place,
/// so an exception can be reviewed rather than discovered.
abstract final class OffTokens {
  /// The rewarded-ad canvas. Fixed near-black in both moods: an ad is a foreign
  /// surface handed to the app, not a page of it, so it does not take `--bg`.
  static const OffToken<Color> rewardedAdCanvas = OffToken(
    Color(0xFF0B0908),
    reason:
        'The rewarded-ad screen is a sponsor surface, not an app page. It is '
        'fixed near-black in both moods so the ad reads the same either way.',
  );

  /// The rewarded-ad countdown ring, which keeps the Dark Roast accent in both
  /// moods.
  static const OffToken<Color> rewardedAdProgressRing = OffToken(
    Color(0xFFE07A4F),
    reason:
        'It sits on the rewarded-ad canvas, which is near-black in both moods, '
        'so the themed accent would go too dark to read in Cupping. The ring '
        'keeps the Dark Roast accent instead of following the mood.',
  );

  /// The ink the green-bean drawing is shaded with — its outline, its cast
  /// shadow and the shadow under its centre cut, at three different alphas.
  static const OffToken<Color> seedInk = OffToken(
    Color(0xFF1B1614),
    reason:
        'A bean is an object the learner is looking at, not a page of the app, '
        'so its shading does not invert with the mood — a seam lit from above '
        'stays dark in Dark Roast. It happens to equal Cupping ink, which is a '
        'coincidence of the palette rather than a reference to it; the drawing '
        'would keep this value if Cupping ink moved.',
  );

  /// The fruit staining left on a naturally processed seed.
  static const OffToken<Color> seedStain = OffToken(
    Color(0xFF6B4A22),
    reason:
        'The mottling of a bean dried in its own fruit. The design draws it '
        'and never names it, so there is no --art-* token to read; it belongs '
        'to one illustration rather than to the palette.',
  );

  /// The cream highlight carved down the middle of a drawn bean.
  static const OffToken<Color> beanCrease = OffToken(
    Color(0xFFFBF7EE),
    reason:
        'The design writes this literal into the bean itself, so the crease '
        'stays the same cream in both moods — it is a highlight on an object, '
        'not a surface of the app. It happens to equal the Cupping surface, '
        'which is a coincidence of the palette rather than a reference to it. '
        'Nor is it --art-cream, whose warmer value is for illustration fills.',
  );

  /// The vertical room inside a `predict` card's guess tile.
  static const OffToken<double> pickTilePadding = OffToken(
    26,
    reason:
        'The design sets `.pick-tile` to `padding: 26px 14px`. 26 sits between '
        'AppSpacing.lg (24) and xl (32) and is deliberate: the two-up guess is '
        'meant to read far taller than a row, so it does not look like the '
        'graded lists it sits among. Rounding it onto the scale is a design '
        'change, not a tidy-up.',
  );

  /// The tab label's letter-spacing, in em — wider than the micro rung the
  /// label otherwise sits on.
  static const OffToken<double> tabLabelTracking = OffToken(
    0.18,
    reason:
        'The design letters the tab label at 0.18em where the ladder tracks '
        'its micro rung at 0.14em (`index.html:361` against the rung table in '
        '`app_text.dart`). The bar is the only place in the shipped design '
        'lettered this wide, so widening the rung would restyle every other '
        'micro line to letter one bar.',
  );

  /// The gap the intro screens set between a block and the next one.
  static const OffToken<double> introBlockGap = OffToken(
    28,
    reason:
        'The design sets 28 twice on the intro — under the Welcome hero and '
        'above the Meet Roasty CTA (`screens.jsx:72`, `:120`). It sits midway '
        'between AppSpacing.lg (24) and xl (32), belonging to neither, and '
        'these are the only two screens in the app that use it. Snapping it '
        'onto a rung would retune two screens to spare one entry.',
  );

  /// The tap cue's letter-spacing, in logical pixels at the label step.
  static const OffToken<double> tapCueTracking = OffToken(
    2.64,
    reason:
        '`.tap-cue` letters at 0.24em (`index.html:1111`), half again as wide '
        'as any other mono label in the design and the thing that makes it '
        'read as an instruction rather than a heading. 2.64 is that em value '
        'at the 11px label step. Same case as tabLabelTracking: widening the '
        'rung would reletter every micro line to style one cue.',
  );

  /// Every sanctioned exception, so the register can be read — and tested — as
  /// a whole rather than one constant at a time.
  static const register = <OffToken<Object>>[
    rewardedAdCanvas,
    rewardedAdProgressRing,
    seedInk,
    seedStain,
    beanCrease,
    pickTilePadding,
    introBlockGap,
    tapCueTracking,
    tabLabelTracking,
  ];
}
