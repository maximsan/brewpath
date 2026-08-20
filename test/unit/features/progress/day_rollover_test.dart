import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/day_rollover.dart';
import 'package:flutter_test/flutter_test.dart';

/// Proves the rollover decision is a change of *local calendar day*, not
/// elapsed time — and that it fires in both directions, because the streak is
/// folded against "today" and a clock moved backwards changes that answer too.
void main() {
  group('a rollover is a change of local calendar day', () {
    test('two moments in the same evening are not a rollover', () {
      expect(
        dayHasRolledOver(
          lastSeenDay: epochDay(DateTime(2026, 8, 20, 22)),
          now: DateTime(2026, 8, 20, 23, 59),
        ),
        isFalse,
      );
    });

    test('crossing midnight is a rollover, two minutes later', () {
      expect(
        dayHasRolledOver(
          lastSeenDay: epochDay(DateTime(2026, 8, 20, 23, 59)),
          now: DateTime(2026, 8, 21, 0, 1),
        ),
        isTrue,
      );
    });

    test('crossing a month boundary is a rollover', () {
      expect(
        dayHasRolledOver(
          lastSeenDay: epochDay(DateTime(2026, 8, 31, 12)),
          now: DateTime(2026, 9, 1, 12),
        ),
        isTrue,
      );
    });

    test('several days away is a rollover', () {
      expect(
        dayHasRolledOver(
          lastSeenDay: epochDay(DateTime(2026, 8, 20, 9)),
          now: DateTime(2026, 8, 27, 9),
        ),
        isTrue,
      );
    });

    test('a clock moved back a day is also a rollover', () {
      // Travelling west, or a wrong clock corrected. The fold ignores days
      // after `today`, so a smaller today is a different answer — the surfaces
      // must recompute rather than keep the larger day's value.
      expect(
        dayHasRolledOver(
          lastSeenDay: epochDay(DateTime(2026, 8, 21, 9)),
          now: DateTime(2026, 8, 20, 9),
        ),
        isTrue,
      );
    });

    test('the same instant is not a rollover', () {
      final at = DateTime(2026, 8, 20, 12);
      expect(
        dayHasRolledOver(lastSeenDay: epochDay(at), now: at),
        isFalse,
      );
    });
  });
}
