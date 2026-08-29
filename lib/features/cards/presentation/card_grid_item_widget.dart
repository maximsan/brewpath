import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
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
        onTap: collected
            ? () => context.goNamed(
                AppRoutes.cardDetail.name,
                pathParameters: {'cardId': item.card.id},
              )
            : null,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // An uncollected card shows what it is not: the design draws no
              // mark for "unknown", so that branch keeps a stock glyph while
              // the collected one carries the module's own.
              if (collected)
                IconBadge.roundedMark(
                  mark: moduleMark(item.card.iconName),
                  size: _badgeSize,
                  iconSize: _iconSize,
                  background: mood.accent,
                  foreground: mood.accentInk,
                )
              else
                IconBadge.rounded(
                  icon: Icons.help_outline,
                  size: _badgeSize,
                  iconSize: _iconSize,
                  background: mood.surface2,
                  foreground: mood.inkMute,
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
