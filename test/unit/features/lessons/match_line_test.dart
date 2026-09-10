import 'dart:math' as math;

import 'package:brew_path/features/lessons/presentation/cards/match_line.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the arrowhead', () {
    test('lands its barbs behind the tip, one either side of the line', () {
      final barbs = matchArrowBarbs(
        from: const Offset(0, 100),
        to: const Offset(200, 100),
      );

      // A horizontal line, so both barbs sit the same distance back along it
      // and mirror each other across it.
      expect(barbs, hasLength(2));
      expect(barbs[0].dx, lessThan(200));
      expect(barbs[1].dx, lessThan(200));
      expect(barbs[0].dx, closeTo(barbs[1].dx, 0.001));
      expect(barbs[0].dy, closeTo(100 - (barbs[1].dy - 100), 0.001));
    });

    test('sits its barbs exactly the design size back from the tip', () {
      const tip = Offset(120, 40);
      final barbs = matchArrowBarbs(from: const Offset(10, 90), to: tip);

      for (final barb in barbs) {
        expect((tip - barb).distance, closeTo(matchArrowSize, 0.001));
      }
    });

    test('opens at twice the design spread', () {
      const from = Offset.zero;
      const to = Offset(100, 0);
      final barbs = matchArrowBarbs(from: from, to: to);

      final first = (barbs[0] - to).direction;
      final second = (barbs[1] - to).direction;
      // The smaller of the two angles between them: `direction` wraps at pi,
      // so a head straddling it reports its own outside.
      final between = (first - second).abs();
      final opening = between > math.pi ? 2 * math.pi - between : between;
      expect(opening, closeTo(2 * matchArrowSpread, 0.001));
    });

    test('takes the tip twice when the two anchors have not separated', () {
      const tip = Offset(50, 50);
      final barbs = matchArrowBarbs(from: tip, to: tip);

      expect(
        barbs,
        [tip, tip],
        reason:
            'a zero-length line has no direction, and NaN would paint '
            'nothing while raising nothing',
      );
    });

    test('follows the line round, not just along one axis', () {
      final barbs = matchArrowBarbs(
        from: Offset.zero,
        to: const Offset(0, 100),
      );

      // Pointing straight down: both barbs are above the tip.
      for (final barb in barbs) {
        expect(barb.dy, lessThan(100));
      }
    });
  });

  group('the line drawing itself in', () {
    test('starts at nothing and ends whole', () {
      expect(matchLineDrawFraction(Duration.zero), 0);
      expect(matchLineDrawFraction(matchLineDrawDuration), 1);
    });

    test('stays whole for the rest of the run, after the line is done', () {
      expect(matchLineDrawFraction(matchLineRunDuration), 1);
    });

    test('is ahead of linear, as the design ease is', () {
      final half = matchLineDrawFraction(
        Duration(milliseconds: matchLineDrawDuration.inMilliseconds ~/ 2),
      );

      expect(
        half,
        greaterThan(0.5),
        reason: 'cubic-bezier(.3,1,.4,1) front-loads the draw',
      );
    });
  });

  group('the arrowhead fading in', () {
    test('waits out the design delay before it shows at all', () {
      expect(matchArrowOpacity(Duration.zero), 0);
      expect(matchArrowOpacity(matchArrowFadeDelay), 0);
    });

    test('is whole once its own duration has run out', () {
      expect(
        matchArrowOpacity(matchArrowFadeDelay + matchArrowFadeDuration),
        1,
      );
      expect(matchArrowOpacity(matchLineRunDuration), 1);
    });

    test('is half way through at half its duration', () {
      final part = matchArrowOpacity(
        matchArrowFadeDelay +
            Duration(milliseconds: matchArrowFadeDuration.inMilliseconds ~/ 2),
      );

      expect(part, closeTo(0.5, 0.01));
    });
  });

  group('the snap', () {
    test('rests at its own size off either end of the run', () {
      expect(matchSnapScale(0), 1);
      expect(matchSnapScale(1), 1);
      expect(matchSnapScale(-1), 1);
      expect(matchSnapScale(2), 1);
    });

    test('reaches the design peak at the design stop, not the middle', () {
      expect(matchSnapScale(0.45), closeTo(1.06, 0.0001));
      expect(
        matchSnapScale(0.5),
        lessThan(1.06),
        reason:
            'the peak is at 45%, so the halfway frame is already easing '
            'back down',
      );
    });

    test('never overshoots the peak', () {
      for (var step = 0; step <= 100; step++) {
        expect(matchSnapScale(step / 100), lessThanOrEqualTo(1.06 + 0.0001));
      }
    });
  });

  group('the wrong shake', () {
    test('rests where it stands off either end of the run', () {
      expect(matchShakeOffset(0), 0);
      expect(matchShakeOffset(1), 0);
    });

    test('hits the design stops at each fifth', () {
      expect(matchShakeOffset(0.2), closeTo(-5, 0.0001));
      expect(matchShakeOffset(0.4), closeTo(5, 0.0001));
      expect(matchShakeOffset(0.6), closeTo(-3, 0.0001));
      expect(matchShakeOffset(0.8), closeTo(3, 0.0001));
    });

    test('decays — each swing is smaller than the one before it', () {
      final swings = [0.2, 0.4, 0.6, 0.8].map(matchShakeOffset).toList();

      for (var index = 1; index < swings.length; index++) {
        expect(swings[index].abs(), lessThanOrEqualTo(swings[index - 1].abs()));
      }
    });

    test('crosses back through nothing between each pair of stops', () {
      final crossing = matchShakeOffset(0.3);

      expect(crossing.abs(), lessThan(5));
    });
  });

  test('the run outlasts both the draw and the delayed head', () {
    expect(matchLineRunDuration, greaterThanOrEqualTo(matchLineDrawDuration));
    expect(
      matchLineRunDuration,
      matchArrowFadeDelay + matchArrowFadeDuration,
      reason: 'the head is the last thing to finish, so it sets the run',
    );
  });

  test('the design spread is an angle, not a fraction of the head', () {
    expect(
      matchArrowSpread,
      lessThan(math.pi / 2),
      reason: 'a spread past a right angle would fold the head inside out',
    );
  });
}
