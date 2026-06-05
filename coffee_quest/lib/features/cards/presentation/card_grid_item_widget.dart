import 'package:coffee_quest/core/utils/module_icons.dart';
import 'package:coffee_quest/features/cards/domain/cards_providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// One tile in the Cards grid. Collected → category icon badge, title, and
/// tag, tappable; locked → muted silhouette with "???" and inert.
class CardGridItemWidget extends StatelessWidget {
  const CardGridItemWidget({super.key, required this.item});

  final CardWithCollection item;

  @override
  Widget build(BuildContext context) {
    final collected = item.isCollected;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: collected ? () => context.go('/cards/${item.card.id}') : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: collected
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  collected
                      ? moduleIcon(item.card.iconName)
                      : Icons.help_outline,
                  size: 28,
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
