/// Choice display order, derived on every render and never stored.
///
/// A lesson attempt mints one nonce; each card derives its own order from that
/// nonce and its position. Neither the nonce nor the resulting order is
/// persisted, and that is the point: a stored order re-fixes answer positions
/// across replays and across devices, so a learner who replays a lesson can
/// pass it by remembering *where* the answer sat rather than what it was. The
/// shuffle exists to kill exactly that, and storing it would bring it back.
///
/// The generator is written out here rather than taken from `dart:math` so the
/// order is reproducible from the seed alone — the same nonce and index give
/// the same permutation on every platform and every SDK, which is what makes
/// this unit-testable without pumping a widget.
library;

/// Knuth's MMIX-flavoured LCG constants, over a 32-bit modulus.
const int _multiplier = 1664525;
const int _increment = 1013904223;
const int _modulus = 0x100000000;

/// Mixed into a card's seed so two cards in one attempt do not shuffle alike.
const int _cardStride = 0x9E3779B1;

/// The seed a single card shuffles with.
///
/// [nonce] identifies the lesson *attempt*; [cardIndex] the card's position in
/// it. Both are needed: without the nonce every attempt repeats one order,
/// without the index every card in an attempt repeats another.
int cardSeed({required int nonce, required int cardIndex}) =>
    (nonce + (cardIndex + 1) * _cardStride) % _modulus;

/// A second seed derived from [seed], for a card that has to draw again.
///
/// One card kind needs this: a `sequence` round is authored in its own answer,
/// so a draw that lands on the solution has to be re-taken. Re-taking it must
/// stay a function of the run's nonce, or the round stops being reproducible —
/// so the new seed is derived here, with the same stride a card's own seed is
/// mixed with, rather than restated wherever a redraw happens to be needed.
int derivedSeed(int seed) => (seed ^ _cardStride) % _modulus;

/// A permutation of `0 …  length - 1`, decided entirely by [seed].
///
/// Returns display position → source index, so a caller reorders its own list
/// without the shuffle needing to know what is in it.
List<int> seededOrder(int length, int seed) {
  final order = List<int>.generate(length, (index) => index);
  var state = seed % _modulus;
  // Fisher-Yates, walking down so each draw is uniform over what is left.
  for (var position = length - 1; position > 0; position--) {
    state = (state * _multiplier + _increment) % _modulus;
    final pick = state % (position + 1);
    final held = order[position];
    order[position] = order[pick];
    order[pick] = held;
  }
  return order;
}

/// Applies [seededOrder] to [items].
List<T> shuffledBySeed<T>(List<T> items, int seed) => [
  for (final index in seededOrder(items.length, seed)) items[index],
];

/// Mints the nonce for one lesson *attempt*.
///
/// Called once when an attempt begins and held for its duration — one nonce per
/// attempt, so every card in a run shuffles from the same draw while a replay
/// draws again. The clock is the source only because any fresh value will do:
/// nothing reads the nonce back, and nothing stores it.
int mintLessonNonce() => DateTime.now().microsecondsSinceEpoch % _modulus;
