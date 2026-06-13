import 'package:flutter/material.dart';

/// Square stat tile used in the "Your progress" grid: a tinted icon badge
/// floats above a large value and a small caption.
class StatTile extends StatelessWidget {
  /// Creates a [StatTile].
  const StatTile({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  /// Icon shown in the badge.
  final IconData icon;

  /// Caption shown under the value.
  final String label;

  /// The stat value text.
  final String value;

  static const double _cornerRadius = 20;
  static const double _badgeSize = 48;
  static const double _badgeRadius = 14;
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: colors.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _badgeSize,
            height: _badgeSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(_badgeRadius),
            ),
            child: Icon(
              icon,
              size: _iconSize,
              color: colors.onPrimaryContainer,
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
