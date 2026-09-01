/// The flashcard deck: which saved terms are dealt, and in what order.
///
/// Everything here is pure — a deck is decided from the saved keys, the
/// learner's reach and the term bank, so the whole rule is testable without a
/// widget or a database. The screen holds only where in the deal it is.
library;

import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';

/// The terms this learner may be dealt.
///
/// Plus reaches every term, reference-only ones included — #98's ruling, which
/// this consumes rather than restates. A free learner reaches what they have
/// **learned**, and only that: the drill flips a definition face-up, so a deck
/// must never deal a word the course has not taught them yet.
///
/// A saved term outside the set is not an error and gets no explanation. It
/// simply is not in the deck, and finishing its lesson puts it there.
Set<String> accessibleTermIds(
  List<DictionaryTerm> terms, {
  required Set<String> completedLessonIds,
  required bool isPlus,
}) => {
  for (final term in terms)
    if (isPlus ||
        dictionaryStatusOf(term, completedLessonIds) ==
            DictionaryStatus.learned)
      term.id,
};

/// The deck: **saved ∩ accessible**, in bank order.
///
/// Bank order rather than save order, for the same reason the shelf reads in
/// course order: a deck that remembered when each card was bookmarked would
/// deal the learner their own browsing history.
///
/// A saved id the bank no longer carries falls out here by never matching a
/// term — the same silent skip the shelf makes, and for the same reason.
List<DictionaryTerm> deriveFlashcardDeck({
  required Set<String> savedKeys,
  required Set<String> accessibleIds,
  required List<DictionaryTerm> terms,
}) => [
  for (final term in terms)
    if (accessibleIds.contains(term.id) &&
        savedKeys.contains(formatSavedKey(SavedKind.term, term.id)))
      term,
];

/// The order one review deals in: display position → deck index.
///
/// [seededOrder]'s permutation, so a deal is reproducible from its nonce alone
/// and the shuffle can be asserted without a clock. The lesson player's own
/// shuffle, reused rather than re-invented.
List<int> flashcardDeal(int size, {required int nonce}) =>
    seededOrder(size, nonce);

/// [order] made valid again for a deck that now holds [size] cards.
///
/// The saved set can move while the drill is open — the learner un-saves the
/// card in front of them, or a peer device does — and a deal holding an index
/// past the end of the deck would throw on the next card. So the deal is
/// reconciled on every build rather than trusted.
///
/// Indices past the end are dropped. What survives is distinct (it came from a
/// permutation), so surviving exactly [size] of them **is** a complete
/// permutation of the smaller deck: the shuffle is kept, and the learner
/// carries on. Anything else — a deck that grew, a deal that never fitted — is
/// re-dealt in order, which is the one arrangement always valid for any size.
List<int> reconcileFlashcardOrder(List<int> order, int size) {
  final kept = [
    for (final index in order)
      if (index < size) index,
  ];
  return kept.length == size
      ? kept
      : List<int>.generate(size, (index) => index);
}
