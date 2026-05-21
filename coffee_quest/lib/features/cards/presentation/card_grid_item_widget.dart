import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_quest/features/cards/domain/cards_providers.dart';

/// One tile in the Cards grid. Collected → icon/title/tag and tappable;
/// locked → silhouette with "???" and inert.
class CardGridItemWidget extends StatelessWidget {
  const CardGridItemWidget({super.key, required this.item});

  final CardWithCollection item;

  @override
  Widget build(BuildContext context) {
    final collected = item.isCollected;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: collected ? () => context.go('/cards/${item.card.id}') : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                collected ? Icons.style : Icons.help_outline,
                size: 40,
                color: collected ? scheme.primary : scheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                collected ? item.card.title : '???',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (collected) ...[
                const SizedBox(height: 4),
                Text(
                  item.card.moduleTag,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
