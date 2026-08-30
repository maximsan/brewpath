import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Square stat tile used in the "Your progress" grid: a tinted icon badge
/// floats above a large value and a small caption.
class StatTile extends StatelessWidget {
  /// Creates a [StatTile].
  const StatTile({
    required IconData icon,
    required this.label,
    required this.value,
    this.onTap,
    this.footer,
    super.key,
  }) : _icon = icon,
       _mark = null;

  /// A tile badged with one of the design's own marks.
  const StatTile.mark({
    required AppIcon mark,
    required this.label,
    required this.value,
    this.onTap,
    this.footer,
    super.key,
  }) : _mark = mark,
       _icon = null;

  /// Stock glyph in the badge, for a stat the design draws no mark for — the
  /// streak's flame is the one that stays.
  final IconData? _icon;

  /// The design's own mark in the badge.
  final AppIcon? _mark;

  /// Caption shown under the value.
  final String label;

  /// The stat value text.
  final String value;

  /// Invoked when the tile is tapped; when null the tile is inert.
  final VoidCallback? onTap;

  /// Optional row under the caption — the streak tile rides its week strip
  /// here.
  final Widget? footer;

  static const double _cornerRadius = 20;
  static const double _badgeSize = 48;
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    final card = Container(
      decoration: BoxDecoration(
        color: mood.surface,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: mood.rule),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_mark == null)
            IconBadge.rounded(
              icon: _icon!,
              size: _badgeSize,
              iconSize: _iconSize,
            )
          else
            IconBadge.roundedMark(
              mark: _mark,
              size: _badgeSize,
              iconSize: _iconSize,
            ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: mood.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: mood.inkMute,
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            footer!,
          ],
        ],
      ),
    );
    if (onTap == null) return card;
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(_cornerRadius),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
