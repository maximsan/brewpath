import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_cards_provider.g.dart';

/// In-memory set of favorited card IDs.
/// Phase B keeps this in memory only;
/// Phase A backs it with Drift so favorites survive a restart.
@Riverpod(keepAlive: true)
class FavoriteCards extends _$FavoriteCards {
  @override
  Set<String> build() => {};

  /// Adds [cardId] to favorites if absent, otherwise removes it.
  void toggle(String cardId) {
    state = state.contains(cardId)
        ? ({...state}..remove(cardId)) // new set, minus the id
        : ({...state, cardId}); // new set, plus the id
  }

  /// Whether [cardId] is currently favorited.
  bool isFavorite(String cardId) => state.contains(cardId);
}
