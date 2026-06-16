import 'package:coffee_quest/features/cards/domain/favorite_cards_provider.dart';
import 'package:coffee_quest/shared/models/coffee_card_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
import 'package:coffee_quest/shared/repositories/repository_providers.dart';
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

/// Favorite user cards, derived from the in-memory favorites set.
@riverpod
Future<List<CoffeeCardModel>> favoriteCardsList(Ref ref) async {
  final favorites = ref.watch(favoriteCardsProvider);
  final cards = await ref.watch(contentRepositoryProvider).getCards();

  return cards.where((card) => favorites.contains(card.id)).toList();
}

/// Returns first equal card by Id
@riverpod
Future<CoffeeCardModel?> cardById(Ref ref, String cardId) async {
  final cards = await ref.watch(contentRepositoryProvider).getCards();

  return cards.where((card) => card.id == cardId).firstOrNull;
}
