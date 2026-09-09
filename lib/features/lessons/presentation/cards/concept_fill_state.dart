import 'package:brew_path/core/widgets/fill_slot.dart';

/// How a concept sentence's blank stands, from what the learner picked and
/// whether they have checked yet — their own word, shown and then marked.
///
/// It used to resolve to the authored answer whichever word was tapped, taken
/// from a stale comment atop the design's concept card rather than the code
/// beneath it, which has always shown the pick and graded it (#546).
FillSlotState conceptFillState({
  required String? pick,
  required String answer,
  required bool checked,
}) {
  if (pick == null) return FillSlotState.empty;
  if (!checked) return FillSlotState.filled;
  return pick == answer ? FillSlotState.right : FillSlotState.wrong;
}

/// How an option in the bank below stands once the card is checked.
///
/// The answer is always marked, so a learner who missed sees which word was
/// right; their own wrong pick is marked too, and everything else stays as it
/// was. Before checking only the pick is held.
enum ConceptOptionMark {
  /// Nothing to say about it.
  none,

  /// Picked, and nothing has judged it yet.
  picked,

  /// The authored answer.
  right,

  /// Picked, and it was not the answer.
  wrong;

  /// The mark [option] carries for a blank answered [answer], given the
  /// learner's [pick] and whether they have [checked].
  static ConceptOptionMark of({
    required String option,
    required String answer,
    required String? pick,
    required bool checked,
  }) {
    if (!checked) {
      return option == pick ? ConceptOptionMark.picked : ConceptOptionMark.none;
    }
    if (option == answer) return ConceptOptionMark.right;
    return option == pick ? ConceptOptionMark.wrong : ConceptOptionMark.none;
  }
}
