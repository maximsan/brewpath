import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter_test/flutter_test.dart';

/// What the design leaves above the block at each standing, read off its own
/// declarations rather than off the app: a graded card takes the block's
/// `marginTop` default, and the four callers that override it are the four
/// rows below it.
const _designRoom = <VerdictPlacement, double>{
  VerdictPlacement.card: 22,
  VerdictPlacement.conversational: 22,
  VerdictPlacement.heldGuess: 22,
  VerdictPlacement.miniGame: 20,
  VerdictPlacement.openingGuess: 18,
  VerdictPlacement.reference: 18,
  VerdictPlacement.vocabRound: 14,
};

void main() {
  group('the room above the verdict block', () {
    test('stands at the design value for every placement', () {
      for (final placement in VerdictPlacement.values) {
        expect(
          placement.room,
          _designRoom[placement],
          reason:
              'the design sets ${placement.name} at ${_designRoom[placement]}',
        );
      }
    });

    test('is named for every placement the block has', () {
      expect(_designRoom.keys, containsAll(VerdictPlacement.values));
    });
  });

  group('a wrong answer', () {
    test('is named in the accent on the two reference surfaces', () {
      const reference = {
        VerdictPlacement.reference,
        VerdictPlacement.vocabRound,
      };

      for (final placement in VerdictPlacement.values) {
        expect(
          placement.wrongTone(MoodColors.cupping),
          reference.contains(placement)
              ? MoodColors.cupping.accent
              : MoodColors.cupping.berry,
          reason:
              'berry is what the lesson player spends on a wrong answer; a '
              'look-up answering back in it reads as a worse failure',
        );
      }
    });
  });
}
