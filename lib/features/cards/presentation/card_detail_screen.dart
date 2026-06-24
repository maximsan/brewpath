import 'package:coffee_quest/core/utils/module_icons.dart';
import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/features/cards/domain/cards_providers.dart';
import 'package:coffee_quest/features/cards/domain/favorite_cards_provider.dart';
import 'package:coffee_quest/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detail view for a single collectible card, reached from the Cards grid via
/// the `cardDetail` route. Renders the card's icon, title, description and
/// category, and lets the user favorite it.
class CardDetailScreen extends ConsumerWidget {
  /// Creates a [CardDetailScreen] for the card identified by [cardId].
  const CardDetailScreen({required this.cardId, super.key});

  /// Content id of the card to display (from the route path parameter).
  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsWithCollectionProvider);

    return Scaffold(
      appBar: AppBar(),
      body: cards.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(message: '$e'),
        data: (list) {
          final match = list.where((c) => c.card.id == cardId).toList();
          if (match.isEmpty) {
            return const Center(
              child: Text('Card not found', semanticsLabel: 'Card not found'),
            );
          }
          return _CardDetailBody(item: match.first);
        },
      ),
    );
  }
}

class _CardDetailBody extends ConsumerWidget {
  const _CardDetailBody({required this.item});

  static const double _iconSize = 96;

  final CardWithCollection item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final card = item.card;
    final isFavorite = ref.watch(favoriteCardsProvider).contains(card.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(
              item.isCollected ? moduleIcon(card.iconName) : Icons.help_outline,
              size: _iconSize,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  card.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? colors.error : colors.onSurfaceVariant,
                ),
                tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                onPressed: () =>
                    ref.read(favoriteCardsProvider.notifier).toggle(card.id),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(card.moduleTag, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.md),
          Text(card.description, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
