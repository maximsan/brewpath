import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/cards/domain/card_art.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The colours a card's art stands in for, and the token each becomes.
///
/// A `.svg` file cannot hold `var(--sage)`, so `tool/extract_card_art.js`
/// writes a literal in its place and this maps it back. The literals are
/// magenta on purpose: one that slips through unmapped is visibly wrong rather
/// than plausibly right in one mood.
///
/// Two families, because the design has two. `--sage` and the rest below are
/// declared once per mood and flip with it, so they come from [MoodColors].
/// The `--art-*` family is declared once for both moods and does not flip, so
/// it comes from [ArtColors] — the same palette the bagpick bean reads.
@immutable
class _ArtColorMapper extends ColorMapper {
  const _ArtColorMapper(this.mood);

  static const _ink = Color(0xFFFE0001);
  static const _inkMute = Color(0xFFFE0002);
  static const _rule = Color(0xFFFE0003);
  static const _surface = Color(0xFFFE0004);
  static const _surface2 = Color(0xFFFE0005);
  static const _accent = Color(0xFFFE0006);
  static const _sage = Color(0xFFFE0007);
  static const _berry = Color(0xFFFE0008);

  /// The mood-independent half, by the token name the design gives it.
  ///
  /// Named rather than valued so the palette stays in one place: a colour
  /// written here would be a second copy of [ArtColors], and nothing would
  /// notice the two drifting.
  /// Keyed by the packed ARGB value: `Color` overrides `==`, so it cannot key
  /// a const map.
  static const _artTokens = <int, String>{
    0xFFFE0011: '--art-cream',
    0xFFFE0012: '--art-ripe',
    0xFFFE0013: '--art-sour',
    0xFFFE0014: '--art-roast-light',
    0xFFFE0015: '--art-roast-mid',
    0xFFFE0016: '--art-roast-dark',
    0xFFFE0017: '--art-seed-crease',
    0xFFFE0021: '--art-cherry-skin',
    0xFFFE0022: '--art-cherry-pulp',
    0xFFFE0023: '--art-cherry-gel',
    0xFFFE0024: '--art-cherry-parchment',
    0xFFFE0025: '--art-cherry-silverskin',
    0xFFFE0026: '--art-cherry-seed',
  };

  final MoodColors mood;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    final token = _artTokens[color.toARGB32()];
    if (token != null) return ArtColors.ofToken(token);

    return switch (color) {
      _ink => mood.ink,
      _inkMute => mood.inkMute,
      _rule => mood.rule,
      _surface => mood.surface,
      _surface2 => mood.surface2,
      _accent => mood.accent,
      _sage => mood.sage,
      _berry => mood.berry,
      _ => color,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _ArtColorMapper && other.mood == mood;

  @override
  int get hashCode => mood.hashCode;
}

/// Draws one collectible's own illustration.
///
/// This is the only way the app should draw one: the arts paint in sentinel
/// colours, and reaching for `SvgPicture` directly would render them
/// literally — magenta where the design drew a cherry.
///
/// **A kind the design has not drawn falls back to [fallback]**, the module's
/// mark, which is what every card showed before the art existed. Content can
/// name a new kind before anyone re-runs the extractor, and a card with no
/// picture is better than a card with a hole in it.
class CardArtMark extends StatelessWidget {
  /// Draws the art for [kind] at [size], or [fallback] where there is none.
  const CardArtMark({
    required this.kind,
    required this.fallback,
    required this.size,
    this.semanticLabel,
    super.key,
  });

  /// The collectible kind, as the content bank names it.
  final String kind;

  /// The mark to draw when the design has drawn no art for [kind].
  final AppIcon fallback;

  /// The square box the art is drawn into.
  final double size;

  /// Read out in place of the drawing.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final asset = cardArtAsset(kind);
    if (asset == null) {
      return IconMark(
        fallback,
        size: size,
        semanticLabel: semanticLabel,
      );
    }

    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorMapper: _ArtColorMapper(context.mood),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}
