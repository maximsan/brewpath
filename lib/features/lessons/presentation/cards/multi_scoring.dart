/// How a `multi` card is scored and marked, as pure functions over indices.
///
/// Separate from the widget so the rules can be enumerated cheaply — the
/// subset, superset and same-size-wrong-members cases are the ones that
/// distinguish all-or-nothing from partial credit, and none of them need a
/// widget pumped to check.
library;

/// Whether [selected] is exactly the set of correct choices.
///
/// All-or-nothing, which is the boundary's rule and not this card's invention:
/// a fraction would have to mean something to mastery, and mastery counts
/// whole cards. See `card_boundary.dart`.
///
/// A subset fails, a superset fails, and a wrong set of the right size fails —
/// so neither picking cautiously nor picking everything is a strategy.
bool isMultiCorrect({
  required Set<int> selected,
  required List<bool> isCorrect,
}) {
  final answer = {
    for (var index = 0; index < isCorrect.length; index++)
      if (isCorrect[index]) index,
  };
  return selected.length == answer.length && selected.containsAll(answer);
}

/// How one choice is drawn once the card has been submitted.
enum MultiMark {
  /// Not picked, and not an answer — left alone.
  none(null),

  /// Picked, and an answer.
  correct('correct'),

  /// Picked, and not an answer.
  incorrect('incorrect'),

  /// Not picked, but was an answer.
  missed('missed — this was an answer');

  const MultiMark(this.semantics);

  /// Spoken suffix, because the mark is otherwise carried by colour alone.
  final String? semantics;
}

/// The mark for the choice at [index], once submitted.
///
/// [MultiMark.missed] exists because an all-or-nothing card that only marked
/// what was touched would leave a learner who under-picked with no way to see
/// what they missed.
MultiMark markFor({
  required int index,
  required Set<int> selected,
  required List<bool> isCorrect,
}) {
  final picked = selected.contains(index);
  if (isCorrect[index]) return picked ? MultiMark.correct : MultiMark.missed;
  return picked ? MultiMark.incorrect : MultiMark.none;
}
