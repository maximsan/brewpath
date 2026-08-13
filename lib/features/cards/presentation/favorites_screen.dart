import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/presentation/card_grid_item_widget.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen listing the coffee cards the user has favorited.
class FavoritesScreen extends ConsumerWidget {
  /// Const favorite screen constructor
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteCardsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppLabels.favorites),
      ),
      body: favorites.when(
        data: (cards) => cards.isEmpty
            ? const _FavoritesEmpty()
            : _FavoritesGrid(cards: cards),
        error: (e, _) => ErrorView(message: '$e'),
        loading: () => const LoadingIndicator(),
      ),
    );
  }
}

class _FavoritesGrid extends StatelessWidget {
  const _FavoritesGrid({required this.cards});

  final List<CoffeeCardModel> cards;

  static const _tileAspectRatio = 0.85;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: _tileAspectRatio,
        crossAxisCount: 2,
      ),
      itemBuilder: (context, i) {
        return CardGridItemWidget(
          item: CardWithCollection(card: cards[i], isCollected: true),
        );
      },
    );
  }
}

class _FavoritesEmpty extends StatelessWidget {
  const _FavoritesEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Semantics(
          label: 'No favorites yet. Tap the heart on a card to save it here.',
          excludeSemantics: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border,
                size: AppSpacing.xxl,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No favorites yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tap the ♡ on any card to save it here.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
