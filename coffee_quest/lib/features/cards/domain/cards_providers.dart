import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:coffee_quest/shared/models/coffee_card_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';

part 'cards_providers.g.dart';

/// A content card paired with whether the user has collected it. Derived
/// read-side value — not persisted or serialized.
class CardWithCollection {
  const CardWithCollection({required this.card, required this.isCollected});

  final CoffeeCardModel card;
  final bool isCollected;
}

@riverpod
Future<List<CardWithCollection>> cardsWithCollection(Ref ref) async {
  final cards = await ref.watch(contentRepositoryProvider).getCards();
  final collected = (await ref.watch(collectedCardsProvider.future)).toSet();
  return cards
      .map(
        (c) =>
            CardWithCollection(card: c, isCollected: collected.contains(c.id)),
      )
      .toList();
}
