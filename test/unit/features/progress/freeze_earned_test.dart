import 'package:brew_path/features/progress/domain/streak_engine.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:flutter_test/flutter_test.dart';

/// A run of qualifying days ending on [last], inclusive.
Set<int> _run({required int last, required int length}) => {
  for (var day = last - length + 1; day <= last; day++) day,
};

const int _today = 100;

void main() {
  group('the day that earns it', () {
    test('the seventh qualifying day earns the freeze', () {
      expect(
        freezeEarnedBetween(
          before: _run(last: _today - 1, length: freezeEarnDays - 1),
          after: _run(last: _today, length: freezeEarnDays),
          today: _today,
        ),
        isTrue,
      );
    });

    test('the sixth does not', () {
      expect(
        freezeEarnedBetween(
          before: _run(last: _today - 1, length: freezeEarnDays - 2),
          after: _run(last: _today, length: freezeEarnDays - 1),
          today: _today,
        ),
        isFalse,
      );
    });

    test('the eighth does not — the freeze was already held', () {
      expect(
        freezeEarnedBetween(
          before: _run(last: _today - 1, length: freezeEarnDays),
          after: _run(last: _today, length: freezeEarnDays + 1),
          today: _today,
        ),
        isFalse,
      );
    });
  });

  group('runs that change nothing', () {
    test('a second lesson on a day already marked earns nothing', () {
      final days = _run(last: _today, length: freezeEarnDays);
      expect(
        freezeEarnedBetween(before: days, after: days, today: _today),
        isFalse,
      );
    });

    test('a first lesson ever earns nothing', () {
      expect(
        freezeEarnedBetween(
          before: const <int>{},
          after: {_today},
          today: _today,
        ),
        isFalse,
      );
    });
  });

  // The freeze is reported by the run that earns it, so a learner who broke
  // their streak and built a fresh seven-day run meets the row a second time.
  // That is the design's intent — it is the payout for keeping the streak, not
  // a once-per-install introduction.
  test('a rebuilt run earns it again', () {
    const broken = 40;
    final before = {
      ..._run(last: broken, length: freezeEarnDays + 2),
      ..._run(last: _today - 1, length: freezeEarnDays - 1),
    };
    expect(
      freezeEarnedBetween(
        before: before,
        after: {...before, _today},
        today: _today,
      ),
      isTrue,
    );
  });

  // Guards the ordering the service depends on: the day set only ever grows,
  // so "earned" is a rise and never a fall.
  test('losing days never reads as earning one', () {
    expect(
      freezeEarnedBetween(
        before: _run(last: _today, length: freezeEarnDays),
        after: const <int>{},
        today: _today,
      ),
      isFalse,
    );
  });
}
