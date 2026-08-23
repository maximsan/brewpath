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
        'so its shading does not invert with the mood — a dark seam lit from '
        'above stays dark in Dark Roast. It happens to equal Cupping ink, '
        'which is a coincidence of the palette rather than a reference to it; '
        'the drawing would keep this value if Cupping ink moved.',
  );

  /// The fruit staining left on a naturally processed seed.
  static const OffToken<Color> seedStain = OffToken(
    Color(0xFF6B4A22),
    reason:
        'The mottling of a bean dried in its own fruit. The design draws it '
        'and never names it, so there is no --art-* token to read; it belongs '
        'to one illustration rather than to the palette.',
  );

  /// Every sanctioned exception, so the register can be read — and tested — as
  /// a whole rather than one constant at a time.
  static const register = <OffToken<Object>>[
    rewardedAdCanvas,
    rewardedAdProgressRing,
    seedInk,
    seedStain,
  ];
}
