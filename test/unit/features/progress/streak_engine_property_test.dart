// Property tests over randomly generated day sets.
//
// The nine §10 behaviours are pinned case by case in `streak_engine_test.dart`.
// This file attacks the *shape* of the fold instead: the engine walks the gaps
// between active days, which is where an off-by-one hides, so every generated
// case is also run through a day-by-day oracle that cannot have one.
import 'dart:math';

import 'package:brew_path/features/progress/domain/streak_engine.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cases per property. Large enough to hit long runs, gaps of every width and
/// spends followed by re-earns; small enough to stay a unit test.
const int _caseCount = 400;

/// The generated window. Wide enough for several earn-and-spend cycles.
const int _windowDays = 40;

/// Fixed, so a failure is reproducible from the seed printed in the name.
const int _seed = 20260819;

/// The same rules written the slow, obvious way: one step per calendar day,
/// no gap arithmetic at all. Deliberately not a refactor of the engine — its
/// value is that the two were written from §10 independently.
StreakStatus oracle(Set<int> activeDays, int today) {
  final past = activeDays.where((day) => day <= today).toList()..sort();
  if (past.isEmpty) return StreakStatus.idle;

  var streak = 0;
  var freezeHeld = false;
  var towardFreeze = 0;
  final frozen = <int>{};

  for (var day = past.first; day < today; day++) {
    if (activeDays.contains(day)) {
      streak++;
      if (!freezeHeld) {
        towardFreeze++;
        if (towardFreeze == freezeEarnDays) {
          freezeHeld = true;
          towardFreeze = 0;
        }
      }
    } else if (freezeHeld) {
      freezeHeld = false;
      towardFreeze = 0;
      frozen.add(day);
    } else {
      streak = 0;
      towardFreeze = 0;
    }
  }
  // Today counts when it qualifies and is otherwise left alone.
  if (activeDays.contains(today)) {
    streak++;
    if (!freezeHeld) {
      towardFreeze++;
      if (towardFreeze == freezeEarnDays) {
        freezeHeld = true;
        towardFreeze = 0;
      }
    }
  }

  return StreakStatus(
    streak: streak,
    freezeHeld: freezeHeld,
    daysToNextFreeze: freezeHeld ? null : freezeEarnDays - towardFreeze,
    freezesSpent: frozen.length,
    frozenDays: frozen,
  );
}

void main() {
  final random = Random(_seed);

  /// A day set over `0.._windowDays`, at a density that varies per case so
  /// long unbroken runs and sparse scatter both appear.
  Set<int> generate() {
    final density = random.nextDouble();
    return {
      for (var day = 0; day < _windowDays; day++)
        if (random.nextDouble() < density) day,
    };
  }

  void forEachCase(void Function(Set<int> days, int today) check) {
    for (var index = 0; index < _caseCount; index++) {
      final days = generate();
      final today = random.nextInt(_windowDays);
      check(days, today);
    }
  }

  group('the gap fold agrees with a day-by-day oracle (seed $_seed)', () {
    test('on every generated day set', () {
      forEachCase((days, today) {
        expect(
          deriveStreak(activeDays: days, today: today),
          oracle(days, today),
          reason: 'days: ${days.toList()..sort()}, today: $today',
        );
      });
    });
  });

  group('invariants that hold for any history (seed $_seed)', () {
    test('a spend and a covered day are the same event, counted once', () {
      forEachCase((days, today) {
        final status = deriveStreak(activeDays: days, today: today);
        expect(status.freezesSpent, status.frozenDays.length);
      });
    });

    test('a covered day is never also an active day', () {
      forEachCase((days, today) {
        final status = deriveStreak(activeDays: days, today: today);
        expect(status.frozenDays.intersection(days), isEmpty);
      });
    });

    test('today is never covered — it has not been missed yet', () {
      forEachCase((days, today) {
        final status = deriveStreak(activeDays: days, today: today);
        expect(status.frozenDays.every((day) => day < today), isTrue);
      });
    });

    test('the countdown is absent exactly while a freeze is held', () {
      forEachCase((days, today) {
        final status = deriveStreak(activeDays: days, today: today);
        expect(status.daysToNextFreeze == null, status.freezeHeld);
        final remaining = status.daysToNextFreeze;
        if (remaining != null) {
          expect(remaining, inInclusiveRange(1, freezeEarnDays));
        }
      });
    });

    test('the streak never exceeds the days actually completed', () {
      forEachCase((days, today) {
        final status = deriveStreak(activeDays: days, today: today);
        expect(status.streak, lessThanOrEqualTo(days.length));
        expect(status.streak, greaterThanOrEqualTo(0));
      });
    });

    test('a live streak reaches back no further than a covered day allows', () {
      forEachCase((days, today) {
        final status = deriveStreak(activeDays: days, today: today);
        if (status.streak == 0) return;
        final past = days.where((day) => day <= today);
        // Today may be unfinished and the day before it may be covered; a
        // third silent day cannot be survived.
        expect(past.reduce(max), greaterThanOrEqualTo(today - 2));
      });
    });

    test('completing today never lowers anything', () {
      forEachCase((days, today) {
        final before = deriveStreak(activeDays: days, today: today);
        final after = deriveStreak(activeDays: {...days, today}, today: today);
        expect(after.streak, greaterThanOrEqualTo(before.streak));
        expect(after.freezesSpent, before.freezesSpent);
      });
    });

    test('the same history derives the same answer twice', () {
      forEachCase((days, today) {
        expect(
          deriveStreak(activeDays: days, today: today),
          deriveStreak(activeDays: days, today: today),
        );
      });
    });

    test('days after today change nothing', () {
      forEachCase((days, today) {
        expect(
          deriveStreak(
            activeDays: {...days, today + 1, today + 9},
            today: today,
          ),
          deriveStreak(
            activeDays: days.where((day) => day <= today).toSet(),
            today: today,
          ),
        );
      });
    });
  });
}
