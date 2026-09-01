/// What a learner chooses before a drill starts: which deck, and how long.
///
/// Separate from the round generator because these rules have to give the same
/// answers to the setup screen (which greys a deck) and to the start action
/// (which must never run a deck the screen greyed).
library;

import 'package:brew_path/features/dictionary/domain/vocab_round.dart';

/// The decks a drill can be drawn from.
///
/// The prototype's third — the terms you have missed before — is deferred to
/// #298 with the persistence decision it carries.
enum VocabDeck {
  /// The terms the learner bookmarked, where there are enough of them.
  saved,

  /// Everything the learner's tier can reach.
  all,
}

/// The round lengths the design offers, shortest first.
const List<int> vocabLengths = [5, 8, 12];

/// The fewest terms a drill can run on: enough to fill one question's options
/// without padding from outside the learner's pool.
const int vocabMinimumPool = vocabChoiceCount;

/// The lengths [poolSize] can honestly fill.
///
/// Empty when the pool cannot reach even the shortest — the caller then runs
/// the whole pool rather than offering a length that would repeat a term.
List<int> vocabLengthsFor(int poolSize) => [
  for (final length in vocabLengths)
    if (length <= poolSize) length,
];

/// Whether a deck of [size] may be offered.
bool vocabDeckAvailable(int size) => size >= vocabMinimumPool;

/// The deck actually in play, given what the learner chose.
///
/// Saved falls back to All the moment it drops below the minimum, so un-saving
/// a term mid-session cannot leave Start running a deck the rules say cannot
/// exist.
VocabDeck resolveVocabDeck({
  required VocabDeck chosen,
  required int savedPoolSize,
}) => chosen == VocabDeck.saved && !vocabDeckAvailable(savedPoolSize)
    ? VocabDeck.all
    : chosen;

/// How many rounds a drill of [poolSize] plays, given the choice.
///
/// Never more than the pool, so no term is asked about twice in one drill.
int resolveVocabLength({required int chosen, required int poolSize}) {
  if (chosen <= poolSize) return chosen;
  final fits = vocabLengthsFor(poolSize);
  return fits.isEmpty ? poolSize : fits.last;
}
