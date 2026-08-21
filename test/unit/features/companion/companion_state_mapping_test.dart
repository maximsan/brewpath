import 'package:brew_path/features/companion/domain/companion_mood.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/domain/companion_state_mapping.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('roastyStateFor', () {
    test('mood-only maps to a baseline pose', () {
      expect(
        roastyStateFor(mood: CompanionMood.idle),
        RoastyState.idle,
      );
      // happy has no dedicated skin pose yet, so it falls back to idle.
      expect(
        roastyStateFor(mood: CompanionMood.happy),
        RoastyState.idle,
      );
    });

    test('a present reaction always wins over the mood', () {
      expect(
        roastyStateFor(
          mood: CompanionMood.happy,
          reaction: CompanionReaction.wrong,
        ),
        RoastyState.wrong,
      );
    });

    test('each reaction maps to its pose', () {
      const expected = {
        CompanionReaction.correct: RoastyState.correct,
        CompanionReaction.wrong: RoastyState.wrong,
        CompanionReaction.lessonComplete: RoastyState.lesson,
        CompanionReaction.moduleComplete: RoastyState.module,
        CompanionReaction.cardEarned: RoastyState.card,
      };
      for (final entry in expected.entries) {
        expect(
          roastyStateFor(mood: CompanionMood.idle, reaction: entry.key),
          entry.value,
          reason: 'reaction ${entry.key} should map to ${entry.value}',
        );
      }
    });
  });
}
