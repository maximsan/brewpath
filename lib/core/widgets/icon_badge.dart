import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
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
/// progression indicators shedding their fills entirely: module rows are a bare
/// glyph (`ModuleGlyph`), and the lesson node is a `BeanGauge` filled to the
/// lesson's best-score ratio. Neither is an icon well, and neither should
/// adopt this widget.
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
    required IconData icon,
    required this.size,
    double radius = AppRadii.chrome,
    this.iconSize,
    this.background,
    this.foreground,
    this.borderColor,
    this.semanticLabel,
    super.key,
  }) : _icon = icon,
       _mark = null,
       _radius = radius,
       _shape = BoxShape.rectangle;

  /// A circular badge.
  const IconBadge.circle({
    required IconData icon,
    required this.size,
    this.iconSize,
    this.background,
    this.foreground,
    this.borderColor,
    this.semanticLabel,
    super.key,
  }) : _icon = icon,
       _mark = null,
       _shape = BoxShape.circle,
       _radius = 0;

  /// A rounded badge carrying one of the design's own marks.
  const IconBadge.roundedMark({
    required AppIcon mark,
    required this.size,
    double radius = AppRadii.chrome,
    this.iconSize,
    this.background,
    this.foreground,
    this.borderColor,
    this.semanticLabel,
    super.key,
  }) : _mark = mark,
       _icon = null,
       _radius = radius,
       _shape = BoxShape.rectangle;

  /// A circular badge carrying one of the design's own marks.
  const IconBadge.circleMark({
    required AppIcon mark,
    required this.size,
    this.iconSize,
    this.background,
    this.foreground,
    this.borderColor,
    this.semanticLabel,
    super.key,
  }) : _mark = mark,
       _icon = null,
       _shape = BoxShape.circle,
       _radius = 0;

  /// The stock glyph at the centre, for a badge whose subject the design has
  /// not drawn a mark for. Null when [_mark] carries the drawing instead.
  ///
  /// Two sources, on purpose and not forever: the design's family covers the
  /// app's concepts and its chrome, but not every switch and toggle Settings
  /// puts a badge on. Those keep Material until the design draws them, and
  /// this pair of constructors is what lets the rest move now rather than
  /// waiting for all of it.
  final IconData? _icon;

  /// The design's own mark at the centre, where the family has one.
  final AppIcon? _mark;

  /// Width and height of the badge; it is always square.
  final double size;

  /// Icon size. When null the ambient [IconTheme] decides.
  final double? iconSize;

  /// Fill. Defaults to the mood's accent.
  final Color? background;

  /// Icon colour. Defaults to the mood's accent ink.
  final Color? foreground;

  /// Hairline around the badge, where the design outlines one.
  ///
  /// Null for the filled badges that are the common case: a badge that carries
  /// its own fill needs no edge. Set where the design draws the badge as an
  /// empty *well* rather than a chip — the Cards tab's lock sits in one — and
  /// the outline is what says the slot is waiting rather than occupied.
  final Color? borderColor;

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
        border: borderColor == null ? null : Border.all(color: borderColor!),
        borderRadius: isCircle ? null : BorderRadius.circular(_radius),
      ),
      child: _mark == null
          ? Icon(
              _icon,
              size: iconSize,
              color: foreground ?? mood.accentInk,
              semanticLabel: semanticLabel,
            )
          : IconMark(
              _mark,
              size: iconSize,
              color: foreground ?? mood.accentInk,
              semanticLabel: semanticLabel,
            ),
    );
  }
}
