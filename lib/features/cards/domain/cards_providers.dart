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

/// Every card the bank holds, paired with whether the learner owns it.
///
/// Reads the collected ids off the snapshot, which follows the database on its
/// own, so collecting a card reaches every surface showing one (ADR-0031).
@riverpod
Future<List<CardWithCollection>> cardsWithCollection(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final snapshotFuture = ref.watch(progressSnapshotStateProvider.future);
  final cards = await content.getCards();
  final collected = (await snapshotFuture).clearedByReset.ownedCollectibles;
  return cards
      .map(
        (c) =>
            CardWithCollection(card: c, isCollected: collected.contains(c.id)),
      )
      .toList();
}
