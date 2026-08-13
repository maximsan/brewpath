import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Fixed-size icon well: a token-filled square or circle with one centred
/// [Icon]. The single implementation of the shape that card grids, stat tiles,
/// preference rows, module heroes and reward rows all draw.
///
/// Colours default to the mood's accent fill and accent ink, which is what
/// almost every badge wants; pass [background] and [foreground] for the few
/// that signal a state instead (an uncollected card, for example).
///
/// **This is not the badge for progression state.** The design has the
/// progression indicators shedding their fills entirely: module rows became a
/// bare glyph (`ModuleGlyph`), and lesson nodes are to become a mastery gauge —
/// a ring filled to the lesson's best-score ratio. The two lesson sites
/// (`_LessonBadge`, `_NodeCircle`) still hand-roll a fill only because that
/// gauge is blocked on the schema v4 score change; adopting this widget there
/// would make the fill look deliberate right before it is meant to go away.
///
/// Sizing is per call site rather than a shared scale, because the design has
/// no badge ladder to draw one from. Most sites happen to set [iconSize] to
/// half [size]; that is an observation, not a rule this widget enforces —
/// omitting it leaves the ambient [IconTheme] in charge.
class IconBadge extends StatelessWidget {
  /// A rounded-rectangle badge.
  ///
  /// [radius] defaults to [AppRadii.chrome], the design's soft-chrome token; a
  /// badge that needs its own corner may sit in the 12–20 slack around it.
  /// Anything sharper belongs to the editorial language and is probably not a
  /// badge.
  ///
  /// One caller passes 10, below that slack. It is inherited rather than
  /// sanctioned — it predates this widget and is kept only so the migration
  /// moves no pixels; it wants a design call, not an `OffTokens` entry.
  const IconBadge.rounded({
    required this.icon,
    required this.size,
    double radius = AppRadii.chrome,
    this.iconSize,
    this.background,
    this.foreground,
    this.semanticLabel,
    super.key,
  }) : _radius = radius,
       _shape = BoxShape.rectangle;

  /// A circular badge.
  const IconBadge.circle({
    required this.icon,
    required this.size,
    this.iconSize,
    this.background,
    this.foreground,
    this.semanticLabel,
    super.key,
  }) : _shape = BoxShape.circle,
       _radius = 0;

  /// The glyph at the centre of the badge.
  final IconData icon;

  /// Width and height of the badge; it is always square.
  final double size;

  /// Icon size. When null the ambient [IconTheme] decides.
  final double? iconSize;

  /// Fill. Defaults to the mood's accent.
  final Color? background;

  /// Icon colour. Defaults to the mood's accent ink.
  final Color? foreground;

  /// Screen-reader label for the icon. Omit for decorative badges whose
  /// meaning is already carried by adjacent text.
  final String? semanticLabel;

  /// Corner radius, meaningless for [IconBadge.circle] — private so a circular
  /// badge has no radius to read.
  final double _radius;

  final BoxShape _shape;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final isCircle = _shape == BoxShape.circle;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? mood.accent,
        shape: _shape,
        borderRadius: isCircle ? null : BorderRadius.circular(_radius),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: foreground ?? mood.accentInk,
        semanticLabel: semanticLabel,
      ),
    );
  }
}
