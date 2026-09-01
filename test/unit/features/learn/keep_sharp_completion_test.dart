import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_completion.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:flutter_test/flutter_test.dart';

/// One day's entries, minted the way the activity layer mints them.
Set<String> _entries(List<(ActivityType, String)> completions) => {
  for (final (type, subject) in completions)
    activityEntry(type: type, token: mintActivityToken(), subject: subject),
};

bool ruleMet(
  PracticeType type, {
  int distinctGamesToday = 0,
  bool replayedToday = false,
  bool vocabRoundToday = false,
  bool reviewedFlashcardsToday = false,
}) => keepSharpRuleMet(
  type,
  distinctGamesToday: distinctGamesToday,
  replayedToday: replayedToday,
  vocabRoundToday: vocabRoundToday,
  reviewedFlashcardsToday: reviewedFlashcardsToday,
);

void main() {
  group('keepSharpRuleMet', () {
    test('mini-games need two different games — one game twice is not two', () {
      expect(ruleMet(PracticeType.miniGames, distinctGamesToday: 1), isFalse);
      expect(ruleMet(PracticeType.miniGames, distinctGamesToday: 2), isTrue);
    });

    test('a replay acknowledges only the replay recommendation', () {
      expect(ruleMet(PracticeType.lessonReplay, replayedToday: true), isTrue);
      // The same completed replay does not satisfy a mini-games
      // recommendation — each type is judged by its own rule.
      expect(ruleMet(PracticeType.miniGames, replayedToday: true), isFalse);
    });

    test('a finished vocab round acknowledges only the vocab game', () {
      expect(ruleMet(PracticeType.vocabGame, vocabRoundToday: true), isTrue);
      expect(ruleMet(PracticeType.vocabGame), isFalse);
      // Another type's completion is not this one's.
      expect(
        ruleMet(
          PracticeType.miniGames,
          distinctGamesToday: 1,
          vocabRoundToday: true,
        ),
        isFalse,
      );
    });

    test('a finished review acknowledges only the flashcards pick', () {
      expect(
        ruleMet(PracticeType.flashcards, reviewedFlashcardsToday: true),
        isTrue,
      );
      expect(
        ruleMet(
          PracticeType.flashcards,
          distinctGamesToday: 2,
          replayedToday: true,
          vocabRoundToday: true,
        ),
        isFalse,
        reason: "a busy day of other practice is not this card's own rule",
      );
    });
  });

  group('anyFlashcardReviewToday', () {
    test('a finished review counts', () {
      expect(
        anyFlashcardReviewToday(_entries([(ActivityType.flashcards, '')])),
        isTrue,
      );
    });

    test('a day of every other kind of practice does not', () {
      expect(
        anyFlashcardReviewToday(
          _entries([
            (ActivityType.miniGame, 'g-quiz'),
            (ActivityType.vocab, ''),
            (ActivityType.replay, 'm1l1'),
          ]),
        ),
        isFalse,
      );
    });

    test('an abandoned review leaves no entry, so no day holds one', () {
      expect(anyFlashcardReviewToday(const {}), isFalse);
    });
  });

  group('anyVocabRoundToday', () {
    test("a finished round among the day's entries counts", () {
      expect(
        anyVocabRoundToday(_entries([(ActivityType.vocab, '')])),
        isTrue,
      );
    });

    test('another activity does not', () {
      expect(
        anyVocabRoundToday(_entries([(ActivityType.miniGame, 'g-quiz')])),
        isFalse,
      );
    });

    test('an empty day counts for nothing', () {
      expect(anyVocabRoundToday(const <String>{}), isFalse);
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
