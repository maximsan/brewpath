import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
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
  static const double _iconSize = 28;

  @override
  Widget build(BuildContext context) {
    final collected = item.isCollected;
    final theme = Theme.of(context);
    final mood = context.mood;

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
              IconBadge.rounded(
                icon: collected
                    ? moduleIcon(item.card.iconName)
                    : Icons.help_outline,
                size: _badgeSize,
                iconSize: _iconSize,
                background: collected ? mood.accent : mood.surface2,
                foreground: collected ? mood.accentInk : mood.inkMute,
              ),
              const SizedBox(height: 10),
              Text(
                collected ? item.card.title : '???',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: collected ? mood.ink : mood.inkMute,
                ),
              ),
              if (collected) ...[
                const SizedBox(height: 4),
                Text(
                  item.card.moduleTag,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: mood.inkMute,
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
