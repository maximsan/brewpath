import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The colours a written mark stands in for, and the token each becomes.
///
/// A `.svg` file cannot hold `var(--surface)` — a CSS variable means nothing to
/// an SVG renderer — so `tool/extract_icons.js` writes a literal in its place
/// and this maps it back. The literals are magenta on purpose: one that slips
/// through unmapped is visibly wrong rather than plausibly right in one mood.
///
/// `currentColor` is not here. It is the mark's own ink, and `SvgTheme` carries
/// it, which is why the great majority of marks need no mapping at all.
@immutable
class _MoodColorMapper extends ColorMapper {
  const _MoodColorMapper(this.mood);

  static const _surface = Color(0xFFFF00FF);
  static const _surface2 = Color(0xFFFF00EE);
  static const _accentInk = Color(0xFFFF00DD);

  final MoodColors mood;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) => switch (color) {
    _surface => mood.surface,
    _surface2 => mood.surface2,
    _accentInk => mood.accentInk,
    _ => color,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _MoodColorMapper && other.mood == mood;

  @override
  int get hashCode => mood.hashCode;
}

/// Draws one mark of the design's own icon family.
///
/// This is the only way the app should draw one. The marks paint in
/// `currentColor` and in sentinel colours, and reaching for `SvgPicture`
/// directly would render both literally — magenta where a knockout should be.
class IconMark extends StatelessWidget {
  /// Draws [icon] in [color] or the mood's muted ink, at its drawn size
  /// unless [size] gives it another.
  const IconMark(
    this.icon, {
    this.size,
    this.color,
    this.active = false,
    this.semanticLabel,
    super.key,
  });

  /// The mark to draw.
  final AppIcon icon;

  /// The square box to fit the mark into, or null for the size it was drawn.
  ///
  /// Null is the honest default. The concept family is drawn 24×24, but the
  /// chrome sets are deliberately smaller — 20, 18, 16, and two that are not
  /// square at all — so one number for all of them would scale the small marks
  /// up to the size of the concepts and lose the distinction the design draws.
  /// A mark keeps its aspect inside whatever box it is given.
  final double? size;

  /// The mark's ink. Defaults to the mood's muted ink, which is what the
  /// design gives every inactive glyph.
  final Color? color;

  /// Whether to draw the design's active state, where it draws one.
  ///
  /// For a mark with no active state this changes nothing, so a call site can
  /// pass a selection flag straight through without asking first.
  final bool active;

  /// Read out in place of the drawing. Null leaves the mark unlabelled, which
  /// is right for a mark that only repeats a label already beside it.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return SvgPicture.asset(
      active ? icon.activeAsset : icon.asset,
      width: size,
      height: size,
      theme: SvgTheme(currentColor: color ?? mood.inkMute),
      colorMapper: _MoodColorMapper(mood),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}
