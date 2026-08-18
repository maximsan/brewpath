import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_completion.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/storage/progress_record.dart';
import 'package:flutter_test/flutter_test.dart';

ProgressRecord _record({DateTime? practicedAt}) => ProgressRecord(
  lessonId: 'm1l1',
  isCompleted: true,
  xpEarned: 10,
  completedAt: DateTime(2026, 8, 2),
  mastery: const MasteryResult(correct: 1, total: 1),
  lastPracticeXpDate: practicedAt,
);

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
    final now = DateTime(2026, 8, 18, 14);

    test('a practice stamp from today counts', () {
      final records = [_record(practicedAt: DateTime(2026, 8, 18, 9))];

      expect(anyReplayToday(records, now), isTrue);
    });

    test("yesterday's practice does not", () {
      final records = [_record(practicedAt: DateTime(2026, 8, 17, 23))];

      expect(anyReplayToday(records, now), isFalse);
    });

    test('a never-practiced record does not', () {
      expect(anyReplayToday([_record()], now), isFalse);
    });
  });
}
