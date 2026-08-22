import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Square stat tile used in the "Your progress" grid: a tinted icon badge
/// floats above a large value and a small caption.
class StatTile extends StatelessWidget {
  /// Creates a [StatTile].
  const StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    super.key,
  });

  /// Icon shown in the badge.
  final IconData icon;

  /// Caption shown under the value.
  final String label;

  /// The stat value text.
  final String value;

  /// Invoked when the tile is tapped; when null the tile is inert.
  final VoidCallback? onTap;

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
          IconBadge.rounded(
            icon: icon,
            size: _badgeSize,
            iconSize: _iconSize,
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
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
