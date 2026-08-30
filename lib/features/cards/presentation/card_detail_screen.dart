import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/challenges/presentation/card_stamp_section.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detail view for a single collectible card, reached from the Cards grid via
/// the `cardDetail` route. Renders the card's icon, title, description and
/// category.
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

class _CardDetailBody extends StatelessWidget {
  const _CardDetailBody({required this.item});

  static const double _iconSize = 96;

  final CardWithCollection item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final card = item.card;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            // As on the grid: the design has a mark for every module and none
            // for "not collected yet", so only the collected side moves.
            child: item.isCollected
                ? IconMark(
                    moduleMark(card.iconName),
                    size: _iconSize,
                    color: mood.accent,
                  )
                : Icon(
                    Icons.help_outline,
                    size: _iconSize,
                    color: mood.accent,
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            card.title,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(card.moduleTag, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.md),
          Text(card.description, style: theme.textTheme.bodyLarge),
          CardStampSection(cardId: card.id, isCollected: item.isCollected),
        ],
      ),
    );
  }
}
