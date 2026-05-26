import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:coffee_quest/shared/models/coffee_card_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
import 'package:coffee_quest/shared/repositories/repository_providers.dart';

part 'cards_providers.g.dart';

/// A content card paired with whether the user has collected it. Derived
/// read-side value — not persisted or serialized.
class CardWithCollection {
  const CardWithCollection({required this.card, required this.isCollected});

  final CoffeeCardModel card;
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
