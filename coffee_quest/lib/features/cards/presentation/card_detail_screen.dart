import 'package:coffee_quest/core/utils/module_icons.dart';
import 'package:coffee_quest/core/widgets/error_view.dart';
import 'package:coffee_quest/core/widgets/loading_indicator.dart';
import 'package:coffee_quest/shared/models/coffee_card_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detail screen for a single collected coffee card.
class CardDetailScreen extends ConsumerWidget {
  /// Creates a [CardDetailScreen].
  const CardDetailScreen({required this.cardId, super.key});

  /// Id of the card to display.
  final String cardId;

  static const double _badgeSize = 80;
  static const double _badgeRadius = 20;
  static const double _iconSize = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(contentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Card')),
      body: FutureBuilder<CoffeeCardModel?>(
        future: repo.getCards().then(
          (cards) => cards.where((c) => c.id == cardId).firstOrNull,
        ),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }
          if (snap.hasError) return ErrorView(message: '${snap.error}');
          final card = snap.data;
          if (card == null) {
            return const ErrorView(message: 'Card not found');
          }
          final theme = Theme.of(context);
          final colors = theme.colorScheme;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                    moduleIcon(card.iconName),
                    size: _iconSize,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 20),
                Text(card.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Chip(label: Text(card.moduleTag)),
                const SizedBox(height: 16),
                Text(card.description, style: theme.textTheme.bodyLarge),
              ],
            ),
          );
        },
      ),
    );
  }
}
