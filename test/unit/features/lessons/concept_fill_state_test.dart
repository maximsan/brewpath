import 'package:brew_path/core/widgets/fill_slot.dart';
import 'package:brew_path/features/lessons/presentation/cards/concept_fill_state.dart';
import 'package:flutter_test/flutter_test.dart';

// The behaviour #546 corrected: the sentence shows the learner's own word and
// marks it, where it used to swap in the authored answer whichever was tapped.
void main() {
  group('the slot in the sentence', () {
    test('waits empty until a word is picked', () {
      expect(
        conceptFillState(pick: null, answer: 'seed', checked: false),
        FillSlotState.empty,
      );
    });

    test('holds the pick unmarked until the card is checked', () {
      expect(
        conceptFillState(pick: 'skin', answer: 'seed', checked: false),
        FillSlotState.filled,
      );
    });

    test('marks a right pick right', () {
      expect(
        conceptFillState(pick: 'seed', answer: 'seed', checked: true),
        FillSlotState.right,
      );
    });

    test('marks a wrong pick wrong, and keeps the learner’s word', () {
      expect(
        conceptFillState(pick: 'skin', answer: 'seed', checked: true),
        FillSlotState.wrong,
        reason: 'the sentence no longer swaps the answer in silently',
      );
    });
  });

  group('the options below', () {
    ConceptOptionMark mark(
      String option, {
      String? pick,
      bool checked = false,
    }) => ConceptOptionMark.of(
      option: option,
      answer: 'seed',
      pick: pick,
      checked: checked,
    );

    test('nothing is marked before a pick', () {
      expect(mark('seed'), ConceptOptionMark.none);
      expect(mark('skin'), ConceptOptionMark.none);
    });

    test('a pick is held, not judged', () {
      expect(mark('skin', pick: 'skin'), ConceptOptionMark.picked);
      expect(mark('seed', pick: 'skin'), ConceptOptionMark.none);
    });

    test('checking marks the answer, whichever was picked', () {
      expect(
        mark('seed', pick: 'skin', checked: true),
        ConceptOptionMark.right,
        reason: 'a learner who missed still has to see which word was right',
      );
      expect(
        mark('skin', pick: 'skin', checked: true),
        ConceptOptionMark.wrong,
      );
    });

    test('a right pick leaves the other option unmarked', () {
      expect(
        mark('seed', pick: 'seed', checked: true),
        ConceptOptionMark.right,
      );
      expect(mark('skin', pick: 'seed', checked: true), ConceptOptionMark.none);
    });
  });
}
