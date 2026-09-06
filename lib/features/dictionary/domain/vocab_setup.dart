/// What a learner chooses before a drill starts: which deck, and how long.
///
/// Separate from the round generator because these rules have to give the same
/// answers to the setup screen (which greys a deck) and to the start action
/// (which must never run a deck the screen greyed).
library;

import 'package:brew_path/features/dictionary/domain/vocab_round.dart';

/// The decks a drill can be drawn from.
enum VocabDeck {
  /// The terms the learner bookmarked, where there are enough of them.
  saved,

  /// Everything the learner's tier can reach.
  all,

  /// The terms they got wrong more recently than right.
  misses,
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

/// Whether a deck of [size] may be offered. All is exempt: it is the deck the
/// others fall back *to*, and the too-small case is the teaching state's.
bool vocabDeckAvailable(int size) => size >= vocabMinimumPool;

/// The deck actually in play, given what the learner chose and how big that
/// deck currently is.
///
/// Saved and Misses both fall back to All the moment they drop below the
/// minimum, so un-saving a term — or answering the last missed one correctly —
/// cannot leave Start running a deck the rules say cannot exist.
///
/// Takes the *chosen* deck's size rather than each deck's, so a third deck
/// could not be added and silently left out of the rule.
VocabDeck resolveVocabDeck({
  required VocabDeck chosen,
  required int chosenPoolSize,
}) => chosen != VocabDeck.all && !vocabDeckAvailable(chosenPoolSize)
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
