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

/// Reads the collected ids **off the snapshot directly** rather than chaining
/// through `collectedCardsProvider.future`. The chained form hits a Riverpod
/// 3.2.1 internal-pause-state assertion (issue #4709) when the
/// `StatefulShellRoute` toggles `TickerMode` after the lesson-completion
/// screen invalidates the inner provider. Callers that mutate collected
/// cards must invalidate this provider alongside `collectedCardsProvider`.
@riverpod
Future<List<CardWithCollection>> cardsWithCollection(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final snapshots = ref.watch(snapshotRepositoryProvider);
  final cards = await content.getCards();
  final collected = (await snapshots.read()).clearedByReset.ownedCollectibles;
  return cards
      .map(
        (c) =>
            CardWithCollection(card: c, isCollected: collected.contains(c.id)),
      )
      .toList();
}
