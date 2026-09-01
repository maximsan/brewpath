/// Where a review has got to.
library;

import 'package:brew_path/features/dictionary/domain/flashcard_deck.dart';
import 'package:flutter/foundation.dart';

/// The deal, the card in front of the learner, and which side is up.
///
/// A value rather than six fields on a `State`, so every move is a function
/// that can be asserted without pumping — including the ones that matter:
/// stepping off the last card finishes, and a deck that shrank underneath the
/// round leaves a round that can still be walked.
@immutable
class FlashcardRound {
  /// Creates a [FlashcardRound].
  const FlashcardRound({
    required this.order,
    required this.position,
    required this.isRevealed,
    required this.isFinished,
  });

  /// A fresh deal of [size] cards, from [nonce].
  factory FlashcardRound.deal(int size, {required int nonce}) => FlashcardRound(
    order: flashcardDeal(size, nonce: nonce),
    position: 0,
    isRevealed: false,
    isFinished: false,
  );

  /// Display position → deck index.
  final List<int> order;

  /// Where in [order] the learner is.
  final int position;

  /// Whether the definition is the side showing.
  final bool isRevealed;

  /// Whether every card has been seen.
  final bool isFinished;

  /// How many cards this round deals.
  int get length => order.length;

  /// The deck index of the card showing.
  int get card => order[position];

  /// Whether stepping back is possible.
  bool get isOnFirst => position == 0;

  /// Whether stepping on finishes rather than advances.
  bool get isOnLast => position >= length - 1;

  /// The same card, turned over.
  FlashcardRound flipped() => _at(position, isRevealed: !isRevealed);

  /// The card before, face down. Nothing happens on the first.
  FlashcardRound back() => isOnFirst ? this : _at(position - 1);

  /// The card after, face down — or the finish, when there is no card after.
  ///
  /// The only way to reach [isFinished], and it is reachable once per round:
  /// there is no step past the end, so a finished round stays finished until
  /// it is dealt again.
  FlashcardRound forward() => isOnLast
      ? FlashcardRound(
          order: order,
          position: position,
          isRevealed: false,
          isFinished: true,
        )
      : _at(position + 1);

  /// This round, made valid for a deck that now holds [size] cards.
  ///
  /// The saved set can move while the drill is open — the learner un-saves the
  /// card in front of them, or a peer device does — so the round is reconciled
  /// rather than trusted. [reconcileFlashcardOrder] keeps the shuffle where it
  /// can; the position follows it into range, so a learner whose deck shrank
  /// under them lands on a card rather than on an index the deck cannot answer
  /// for.
  FlashcardRound reconciled(int size) {
    final reconciled = reconcileFlashcardOrder(order, size);
    if (reconciled.isEmpty) {
      return FlashcardRound(
        order: reconciled,
        position: 0,
        isRevealed: false,
        isFinished: isFinished,
      );
    }
    return FlashcardRound(
      order: reconciled,
      position: position.clamp(0, reconciled.length - 1),
      isRevealed: isRevealed,
      isFinished: isFinished,
    );
  }

  /// The same deal at [next], face down unless told otherwise.
  FlashcardRound _at(int next, {bool isRevealed = false}) => FlashcardRound(
    order: order,
    position: next,
    isRevealed: isRevealed,
    isFinished: false,
  );
}
