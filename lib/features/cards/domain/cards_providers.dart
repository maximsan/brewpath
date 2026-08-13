import 'package:brew_path/features/cards/domain/favorite_cards_provider.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cards_providers.g.dart';

/// A content card paired with whether the user has collected it. Derived
/// read-side value — not persisted or serialized.
class CardWithCollection {
  /// Creates a [CardWithCollection].
  const CardWithCollection({required this.card, required this.isCollected});

  /// The content card.
  final CoffeeCardModel card;

  /// Whether the user has collected [card].
  final bool isCollected;
}

/// Reads collected IDs from `cardRepositoryProvider` directly rather than
/// chaining through `collectedCardsProvider.future`. The chained form hits a
/// Riverpod 3.2.1 internal-pause-state assertion (issue #4709) when the
/// `StatefulShellRoute` toggles `TickerMode` after the lesson-completion
/// screen invalidates the inner provider. Callers that mutate collected
/// cards must invalidate this provider alongside `collectedCardsProvider`.
@riverpod
Future<List<CardWithCollection>> cardsWithCollection(Ref ref) async {
  final cards = await ref.watch(contentRepositoryProvider).getCards();
  final collected =
      (await ref.watch(cardRepositoryProvider).getAllCollectedCardIds())
          .toSet();
  return cards
      .map(
        (c) =>
            CardWithCollection(card: c, isCollected: collected.contains(c.id)),
      )
      .toList();
}

/// The cards the user has favourited, in content order.
///
/// Derived rather than stored: [favoriteCardsProvider] holds only the set of
/// ids, so this stays correct when a card is favourited or removed anywhere in
/// the app without a second source of truth to keep in step.
@riverpod
Future<List<CoffeeCardModel>> favoriteCardsList(Ref ref) async {
  final favorites = ref.watch(favoriteCardsProvider);
  final cards = await ref.watch(contentRepositoryProvider).getCards();

  return cards.where((card) => favorites.contains(card.id)).toList();
}
