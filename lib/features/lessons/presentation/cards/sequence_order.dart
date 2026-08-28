/// The rules a sequence card is judged by, with no widget attached.
///
/// A sequence round is a set of steps and the order they belong in. The learner
/// taps them into place and commits the whole run at once, and the card pays
/// its one success signal only if every step landed in its authored position —
/// all-or-nothing, like every other graded kind. See `card_boundary.dart`.
///
/// Keeping the rules here means "is this run of taps the authored order" and
/// "can this display order open the card already solved" are answerable without
/// pumping a widget (#124).
library;

import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';

/// Pulls the seeded draw somewhere else when the first one lands on the answer.
/// Any constant would do; this is the one `card_seed.dart` already mixes with.
const int _redrawStride = 0x9E3779B1;

/// The steps in the order the card opens with — seeded, and never the answer.
///
/// Every other card's shuffle is cosmetic: moving four choices around cannot
/// hand the learner anything. **This one can.** A sequence round is authored in
/// its correct order, so the identity permutation opens the card already
/// solved, and a seeded draw that happens to land on it does exactly the same.
/// A round that opens solved is not a hard round — it is a round the learner
/// wins by tapping down the list without reading it.
///
/// So the draw is taken, checked, and re-taken from a derived seed if it was
/// the answer; a second landing on it is answered by reversing, which cannot be
/// the answer for two steps or more. All of it is decided by [seed] alone, so
/// the round stays reproducible from the run's nonce — the property the whole
/// shuffle discipline rests on.
///
/// A round of fewer than two steps is returned untouched: there is no order to
/// get wrong, so there is nothing to protect.
List<SequenceItem> sequenceDisplayOrder(List<SequenceItem> items, int seed) {
  if (items.length < 2) return List.of(items);

  final first = shuffledBySeed(items, seed);
  if (!sequenceIsSolution(first)) return first;

  final second = shuffledBySeed(items, seed ^ _redrawStride);
  if (!sequenceIsSolution(second)) return second;

  return second.reversed.toList();
}

/// Whether [items], read top to bottom, are already in their authored order.
bool sequenceIsSolution(List<SequenceItem> items) {
  for (final (index, item) in items.indexed) {
    if (!sequencePlacedRight(item: item, position: index)) return false;
  }
  return true;
}

/// Whether the step tapped into [position] belongs there.
///
/// Positions are counted from zero and authored orders from one, and that
/// off-by-one is the only arithmetic a sequence card has. It lives here so the
/// reveal, the per-step mark and the verdict all read it from one place rather
/// than each writing `+ 1` and one of them writing it wrong.
bool sequencePlacedRight({required SequenceItem item, required int position}) =>
    item.order == position + 1;

/// Whether a committed run of [tapped] steps is the authored order.
///
/// A partial run is never correct, however right its start: the card is
/// answered by the whole sequence, not by a prefix of it. An empty round is
/// never correct either — there is nothing to have got right.
bool sequenceIsCorrect({
  required List<SequenceItem> tapped,
  required int total,
}) => total > 0 && tapped.length == total && sequenceIsSolution(tapped);

/// The authored order, for the reveal after a wrong run.
List<SequenceItem> sequenceSolution(List<SequenceItem> items) =>
    List.of(items)..sort((left, right) => left.order.compareTo(right.order));
