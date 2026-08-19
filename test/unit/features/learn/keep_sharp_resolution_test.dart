// The whole recommendation as a function of the day and the learner's
// material: which practice type, and the one screen its CTA opens.
//
// The provider used to read the clock itself, so none of this was assertable
// without pumping. Every case below injects the day.
import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_destination.dart';
import 'package:flutter_test/flutter_test.dart';

/// The two formats a free learner can actually play.
const _playable = ['g-quiz', 'g-match'];

KeepSharpResolution? resolve({
  required int day,
  List<String> playable = _playable,
  Set<String> playedToday = const {},
  List<String> completed = const ['m1l1'],
}) => keepSharpResolutionFor(
  dayNumber: day,
  playableFormatIds: playable,
  formatsPlayedToday: playedToday,
  completedLessonIds: completed,
);

/// A day whose rotation lands on [type], searched rather than hardcoded so the
/// cases survive a change to the rotation order.
int dayLandingOn(PracticeType type, {List<String> playable = _playable}) {
  for (var day = 0; day < PracticeType.values.length * 2; day++) {
    if (resolve(day: day, playable: playable)?.type == type) return day;
  }
  fail('no day in one full rotation lands on $type');
}

void main() {
  group("eligibility is the type's own rule, asked of the material", () {
    test('mini-games need two playable formats', () {
      final day = dayLandingOn(PracticeType.miniGames);

      expect(resolve(day: day)?.type, PracticeType.miniGames);
    });

    test('one playable format is never recommended', () {
      // The card would state a rule the learner's material cannot satisfy.
      final day = dayLandingOn(PracticeType.miniGames);

      expect(
        resolve(day: day, playable: const ['g-quiz'])?.type,
        isNot(PracticeType.miniGames),
      );
    });

    test('no playable formats, and the rotation moves past them', () {
      final day = dayLandingOn(PracticeType.miniGames);

      expect(
        resolve(day: day, playable: const [])?.type,
        PracticeType.lessonReplay,
      );
    });

    test('a replay needs a finished lesson', () {
      final day = dayLandingOn(PracticeType.lessonReplay);

      expect(
        resolve(day: day, completed: const [])?.type,
        isNot(PracticeType.lessonReplay),
      );
    });

    test('nothing to offer resolves to nothing at all', () {
      for (var day = 0; day < PracticeType.values.length; day++) {
        expect(
          resolve(day: day, playable: const [], completed: const []),
          isNull,
        );
      }
    });

    test('vocab and flashcards stay out until their surfaces register', () {
      // They qualify for the streak already; they have no screen.
      expect(builtPracticeSurfaces, isNot(contains(PracticeType.vocabGame)));
      expect(builtPracticeSurfaces, isNot(contains(PracticeType.flashcards)));
    });
  });

  group('the mini-games CTA opens a game, and never the same one twice', () {
    late int day;
    setUp(() => day = dayLandingOn(PracticeType.miniGames));

    test('it opens a playable game', () {
      final destination = resolve(day: day)!.destination;

      expect(
        _playable.map(miniGameRun),
        contains(destination),
        reason: 'the card says "play two different games" — so it opens one',
      );
    });

    test('a game already played today is skipped', () {
      final first = resolve(day: day)!.destination;
      final playedFirst = _playable.firstWhere(
        (id) => miniGameRun(id) == first,
      );

      final second = resolve(day: day, playedToday: {playedFirst})!.destination;

      expect(
        second,
        isNot(first),
        reason:
            'pressing Start twice must reach two different games, or '
            'following the card could never satisfy the card',
      );
    });

    test('two presses of Start reach both playable games', () {
      final first = resolve(day: day)!.destination;
      final firstId = _playable.firstWhere((id) => miniGameRun(id) == first);
      final second = resolve(day: day, playedToday: {firstId})!.destination;

      expect({first, second}, _playable.map(miniGameRun).toSet());
    });

    test('every game played, and it still resolves rather than throwing', () {
      // The rule is already met and the card stops offering a CTA — but the
      // resolution must not blow up on an empty candidate list.
      final destination = resolve(
        day: day,
        playedToday: _playable.toSet(),
      )!.destination;

      expect(_playable.map(miniGameRun), contains(destination));
    });
  });

  group('the replay CTA', () {
    test("opens one of the learner's finished lessons", () {
      final day = dayLandingOn(PracticeType.lessonReplay);

      final destination = resolve(
        day: day,
        completed: const ['m1l1', 'm1l2'],
      )!.destination;

      expect(
        const ['m1l1', 'm1l2'].map(lessonPractice),
        contains(destination),
      );
    });

    test('is stable across the day', () {
      final day = dayLandingOn(PracticeType.lessonReplay);

      expect(
        resolve(day: day, completed: const ['m1l1', 'm1l2'])!.destination,
        resolve(day: day, completed: const ['m1l1', 'm1l2'])!.destination,
      );
    });
  });

  group('the rotation itself', () {
    test('the type is stable for a given day', () {
      for (var day = 0; day < 10; day++) {
        expect(resolve(day: day)?.type, resolve(day: day)?.type);
      }
    });

    test('consecutive days do not repeat the same type', () {
      final types = [
        for (var day = 0; day < 4; day++) resolve(day: day)?.type,
      ];

      expect(types.toSet().length, greaterThan(1), reason: 'it rotates');
    });
  });
}
