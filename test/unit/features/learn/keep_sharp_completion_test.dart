import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_completion.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:flutter_test/flutter_test.dart';

/// One day's entries, minted the way the activity layer mints them.
Set<String> _entries(List<(ActivityType, String)> completions) => {
  for (final (type, subject) in completions)
    activityEntry(type: type, token: mintActivityToken(), subject: subject),
};

void main() {
  group('keepSharpRuleMet', () {
    test('mini-games need two different games — one game twice is not two', () {
      expect(
        keepSharpRuleMet(
          PracticeType.miniGames,
          distinctGamesToday: 1,
          replayedToday: false,
        ),
        isFalse,
      );
      expect(
        keepSharpRuleMet(
          PracticeType.miniGames,
          distinctGamesToday: 2,
          replayedToday: false,
        ),
        isTrue,
      );
    });

    test('a replay acknowledges only the replay recommendation', () {
      expect(
        keepSharpRuleMet(
          PracticeType.lessonReplay,
          distinctGamesToday: 0,
          replayedToday: true,
        ),
        isTrue,
      );
      // The same completed replay does not satisfy a mini-games
      // recommendation — each type is judged by its own rule.
      expect(
        keepSharpRuleMet(
          PracticeType.miniGames,
          distinctGamesToday: 0,
          replayedToday: true,
        ),
        isFalse,
      );
    });

    test('unrecorded types never acknowledge', () {
      for (final type in [PracticeType.vocabGame, PracticeType.flashcards]) {
        expect(
          keepSharpRuleMet(type, distinctGamesToday: 2, replayedToday: true),
          isFalse,
        );
      }
    });
  });

  group('anyReplayToday', () {
    test("a replay among the day's entries counts", () {
      expect(
        anyReplayToday(_entries([(ActivityType.replay, 'm1l1')])),
        isTrue,
      );
    });

    test('a day holding no entries at all does not', () {
      expect(anyReplayToday(const {}), isFalse);
    });

    test('a first completion is not a replay', () {
      expect(
        anyReplayToday(_entries([(ActivityType.lesson, 'm1l1')])),
        isFalse,
      );
    });

    test('another practice type on the same day is not a replay', () {
      expect(
        anyReplayToday(
          _entries([
            (ActivityType.miniGame, 'g-quiz'),
            (ActivityType.lesson, 'm1l2'),
          ]),
        ),
        isFalse,
      );
    });

    test('a replay alongside other work still counts', () {
      expect(
        anyReplayToday(
          _entries([
            (ActivityType.miniGame, 'g-quiz'),
            (ActivityType.replay, 'm1l1'),
          ]),
        ),
        isTrue,
      );
    });

    test('an entry naming a type this build does not know is inert', () {
      expect(anyReplayToday({'seance:token-1:m1l1'}), isFalse);
    });
  });
}
