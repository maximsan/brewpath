// The nine rules of `docs/decisions.md` §10, one group each, read as
// executable specification. Every case is a set of day indices and a `today`,
// because that is the engine's whole input.
import 'package:brew_path/features/progress/domain/streak_engine.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:flutter_test/flutter_test.dart';

/// Day 0 of every fixture below. The absolute value is irrelevant — the engine
/// only ever compares indices — so a small number keeps the cases readable.
const int day0 = 100;

/// `count` qualifying days in a row starting at [day0] + `from`.
Set<int> run(int from, int count) => {
  for (var offset = 0; offset < count; offset++) day0 + from + offset,
};

StreakStatus derive(Set<int> days, {required int today}) =>
    deriveStreak(activeDays: days, today: day0 + today);

void main() {
  group('rule 1 — a freeze is earned after seven qualifying days in a row', () {
    test('six days in a row earn nothing', () {
      final status = derive(run(0, 6), today: 5);

      expect(status.streak, 6);
      expect(status.freezeHeld, isFalse);
      expect(status.daysToNextFreeze, 1);
    });

    test('the seventh earns it', () {
      final status = derive(run(0, 7), today: 6);

      expect(status.streak, 7);
      expect(status.freezeHeld, isTrue);
    });

    test('seven days broken by a miss earn nothing', () {
      // Four days, a miss, three days: seven qualifying days, never in a row.
      final status = derive({...run(0, 4), ...run(5, 3)}, today: 7);

      expect(status.streak, 3);
      expect(status.freezeHeld, isFalse);
    });
  });

  group('rule 2 — at most one freeze is held', () {
    test('fourteen days in a row still hold exactly one', () {
      final status = derive(run(0, 14), today: 13);

      expect(status.streak, 14);
      expect(status.freezeHeld, isTrue);
      expect(maxFreezesHeld, 1, reason: 'the cap the boolean encodes');
    });
  });

  group('rule 3 — the freeze is spent automatically on a missed day', () {
    test('a miss after seven days covers the day and keeps the streak', () {
      // Seven days, then a miss, then today.
      final status = derive(run(0, 7), today: 8);

      expect(status.freezeHeld, isFalse);
      expect(status.freezesSpent, 1);
      expect(status.frozenDays, {day0 + 7});
      expect(status.streak, 7);
    });

    test('nothing is spent while the learner keeps showing up', () {
      final status = derive(run(0, 10), today: 9);

      expect(status.freezesSpent, 0);
      expect(status.frozenDays, isEmpty);
    });
  });

  group('rule 4 — a covered day preserves but does not raise the streak', () {
    test('seven days, a covered miss, then one more day reads 8 and not 9', () {
      final status = derive({...run(0, 7), day0 + 8}, today: 8);

      expect(status.streak, 8);
      expect(status.frozenDays, {day0 + 7});
    });
  });

  group('rule 5 — a frozen day earns no progress toward another freeze', () {
    test('a covered day does not stand in for the day it replaced', () {
      // Seven days earn a freeze. A miss spends it. Six more days follow: the
      // covered day would make seven if it counted, and it must not.
      final status = derive({...run(0, 7), ...run(8, 6)}, today: 13);

      expect(status.frozenDays, {day0 + 7});
      expect(status.freezeHeld, isFalse);
      expect(status.daysToNextFreeze, 1);
    });
  });

  group('rule 6 — holding a freeze pauses accrual', () {
    test('seven more days while holding earn nothing further', () {
      final status = derive(run(0, 14), today: 13);

      expect(status.freezesSpent, 0);
      expect(
        status.daysToNextFreeze,
        isNull,
        reason: 'nothing is accruing, so there is no countdown to show',
      );
    });

    test('the second freeze needs seven days that start after the spend', () {
      // 14 days (one freeze, seven of them accruing nothing), a covered miss,
      // then seven fresh days.
      final status = derive({...run(0, 14), ...run(15, 7)}, today: 21);

      expect(status.freezesSpent, 1);
      expect(status.freezeHeld, isTrue);
    });
  });

  group('rule 7 — seven new days in a row are required after a spend', () {
    test('six days after the spend are not enough', () {
      final status = derive({...run(0, 7), ...run(8, 6)}, today: 13);

      expect(status.freezeHeld, isFalse);
      expect(status.daysToNextFreeze, 1);
    });

    test('the seventh day after the spend earns the next one', () {
      final status = derive({...run(0, 7), ...run(8, 7)}, today: 14);

      expect(status.freezeHeld, isTrue);
      expect(status.freezesSpent, 1);
    });
  });

  group('rule 8 — two consecutive misses cover the first and reset', () {
    test('the freeze covers day one and the streak resets on day two', () {
      // Seven days, then days 7 and 8 both missed, then today.
      final status = derive(run(0, 7), today: 9);

      expect(status.frozenDays, {day0 + 7}, reason: 'day one was covered');
      expect(status.freezesSpent, 1, reason: 'it is spent, not refunded');
      expect(status.streak, 0, reason: 'day two ends it');
      expect(status.freezeHeld, isFalse);
      expect(status.daysToNextFreeze, freezeEarnDays);
    });

    test('two misses with no freeze held reset and cover nothing', () {
      final status = derive(run(0, 3), today: 5);

      expect(status.streak, 0);
      expect(status.frozenDays, isEmpty);
      expect(status.freezesSpent, 0);
    });

    test('a single uncovered miss already resets the streak', () {
      final status = derive(run(0, 3), today: 4);

      expect(status.streak, 0);
      expect(status.frozenDays, isEmpty);
    });
  });

  group('rule 9 — freezes are free for everyone', () {
    test('the derivation takes no entitlement to take away', () {
      // Structural, not behavioural: there is no tier, subscription or
      // entitlement parameter on `deriveStreak`, so no build can gate a freeze
      // behind one without changing this signature. §2 rules the same way for
      // qualifying itself — a completed accessible activity always counts.
      final status = derive(run(0, 7), today: 6);

      expect(status.freezeHeld, isTrue);
    });
  });

  group('today is in play, not judged', () {
    test('an unfinished today breaks nothing and spends nothing', () {
      final status = derive(run(0, 7), today: 7);

      expect(status.streak, 7);
      expect(status.freezeHeld, isTrue);
      expect(status.frozenDays, isEmpty);
    });

    test('finishing today advances it', () {
      final status = derive(run(0, 8), today: 7);

      expect(status.streak, 8);
    });

    test('a day ahead of today is ignored rather than folded', () {
      // A peer whose clock runs ahead. Counting it would open a gap behind it.
      final status = derive({...run(0, 3), day0 + 20}, today: 2);

      expect(status.streak, 3);
      expect(status.frozenDays, isEmpty);
    });
  });

  group('boundaries', () {
    test('the first ever qualifying day reads 1', () {
      final status = derive(run(0, 1), today: 0);

      expect(status.streak, 1);
      expect(status.freezeHeld, isFalse);
      expect(status.daysToNextFreeze, freezeEarnDays - 1);
      expect(status.frozenDays, isEmpty);
    });

    test('a spend landing on the most recent completed day', () {
      // Seven days, yesterday missed and covered, today not yet active. The
      // freeze is spent on the newest day the fold is allowed to judge.
      final status = derive(run(0, 7), today: 8);

      expect(status.frozenDays, {day0 + 7});
      expect(status.streak, 7);
    });

    test('a multi-year history folds without walking every day', () {
      // Five years of dormancy, then a fortnight back. The fold walks the set
      // and not the calendar, so the dormant span costs nothing — and the
      // long silence must not leave a freeze or a streak behind it.
      const fiveYears = 365 * 5;
      final status = derive({
        ...run(0, 30),
        ...run(fiveYears, 14),
      }, today: fiveYears + 13);

      expect(status.streak, 14);
      expect(status.freezeHeld, isTrue, reason: 'earned inside the fortnight');
      expect(
        status.freezesSpent,
        1,
        reason:
            'the freeze held after the first run covered the first day '
            'of the silence, and the second ended the streak',
      );
    });
  });

  group('an empty history', () {
    test('no active days at all derive the idle status', () {
      expect(derive(const {}, today: 0), StreakStatus.idle);
    });

    test('only future days still derive idle', () {
      expect(derive({day0 + 5}, today: 0), StreakStatus.idle);
    });
  });
}
