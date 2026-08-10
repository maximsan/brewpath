import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// One tile in the Cards grid. Collected → category icon badge, title, and
/// tag, tappable; locked → muted silhouette with "???" and inert.
class CardGridItemWidget extends StatelessWidget {
  /// Creates a [CardGridItemWidget].
  const CardGridItemWidget({required this.item, super.key});

  /// The card paired with its collected state.
  final CardWithCollection item;

  static const double _cornerRadius = 12;
  static const double _badgeSize = 56;
  static const double _badgeRadius = 14;
  static const double _iconSize = 28;

  @override
  Widget build(BuildContext context) {
    final collected = item.isCollected;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: collected ? () => context.go('/cards/${item.card.id}') : null,
        borderRadius: BorderRadius.circular(_cornerRadius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _badgeSize,
                height: _badgeSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: collected
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(_badgeRadius),
                ),
                child: Icon(
                  collected
                      ? moduleIcon(item.card.iconName)
                      : Icons.help_outline,
                  size: _iconSize,
                  color: collected
                      ? colors.onPrimaryContainer
                      : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                collected ? item.card.title : '???',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: collected ? colors.onSurface : colors.onSurfaceVariant,
                ),
              ),
              if (collected) ...[
                const SizedBox(height: 4),
                Text(
                  item.card.moduleTag,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
