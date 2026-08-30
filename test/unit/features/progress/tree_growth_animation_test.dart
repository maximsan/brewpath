import 'package:brew_path/features/progress/presentation/tree_growth_animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the bounce follows the design keyframes', () {
    test('it starts under size and settles at one', () {
      expect(treeBounceScaleAt(0), 0.85);
      expect(treeBounceScaleAt(1), 1);
    });

    test('it overshoots before it settles', () {
      expect(treeBounceScaleAt(0.55), closeTo(1.06, 0.001));
      expect(treeBounceScaleAt(0.8), closeTo(0.98, 0.001));
    });

    test('the overshoot is the largest the tree ever gets', () {
      var largest = 0.0;
      for (var step = 0; step <= 100; step++) {
        largest = [largest, treeBounceScaleAt(step / 100)].reduce(
          (a, b) => a > b ? a : b,
        );
      }
      expect(largest, closeTo(1.06, 0.001));
    });

    test('it clamps rather than running past its keyframes', () {
      expect(treeBounceScaleAt(-1), 0.85);
      expect(treeBounceScaleAt(2), 1);
    });
  });

  group('the glow ring', () {
    test('opens and closes at nothing', () {
      expect(treeGlowOpacityAt(0), 0);
      expect(treeGlowOpacityAt(1), closeTo(0, 0.001));
    });

    test('peaks at four tenths through, as the design writes it', () {
      expect(treeGlowOpacityAt(0.4), closeTo(0.8, 0.001));
    });

    test('grows outward the whole way', () {
      expect(treeGlowScaleAt(0), 0.6);
      expect(treeGlowScaleAt(1), 2.2);
      expect(treeGlowScaleAt(0.5), greaterThan(treeGlowScaleAt(0.25)));
    });
  });

  group('the leaves', () {
    test('every one takes a different heading', () {
      final headings = {
        for (var index = 0; index < treeLeafCount; index++)
          treeLeafDrift(index).dx.toStringAsFixed(3) +
              treeLeafDrift(index).dy.toStringAsFixed(3),
      };
      expect(headings, hasLength(treeLeafCount));
    });

    test('they leave the canopy rather than the roots', () {
      final rising = [
        for (var index = 0; index < treeLeafCount; index++)
          treeLeafDrift(index).dy,
      ].where((dy) => dy < 0);
      expect(rising, isNotEmpty);
    });

    test('every third is an accent dot', () {
      expect(treeLeafIsDot(0), isTrue);
      expect(treeLeafIsDot(1), isFalse);
      expect(treeLeafIsDot(3), isTrue);
    });

    // Deterministic where the design rolls dice, so a widget test can assert
    // what it drew and a golden does not flicker between runs.
    test('the same leaf drifts the same way every time', () {
      expect(treeLeafDrift(2), treeLeafDrift(2));
    });
  });

  group('phase timing', () {
    test('a phase is nothing before it starts', () {
      expect(
        phaseProgress(
          elapsed: Duration.zero,
          starts: treeGrowthDelay,
          lasts: treeCrossfadeDuration,
        ),
        0,
      );
    });

    test('and finished after it ends', () {
      expect(
        phaseProgress(
          elapsed: const Duration(seconds: 5),
          starts: treeGrowthDelay,
          lasts: treeCrossfadeDuration,
        ),
        1,
      );
    });

    test('it runs half way at half its length', () {
      expect(
        phaseProgress(
          elapsed: treeGrowthDelay + treeCrossfadeDuration ~/ 2,
          starts: treeGrowthDelay,
          lasts: treeCrossfadeDuration,
        ),
        closeTo(0.5, 0.001),
      );
    });

    test('a zero-length phase is over rather than dividing by zero', () {
      expect(
        phaseProgress(
          elapsed: Duration.zero,
          starts: Duration.zero,
          lasts: Duration.zero,
        ),
        1,
      );
    });
  });

  // The hand-over fires while the last leaves are still drifting, so the
  // content behind arrives without a dead pause.
  test('the beat hands over before it has finished drawing', () {
    expect(
      treeGrowthDelay + treeCrossfadeDuration + treeGrowthHandover,
      lessThan(treeGrowthTotal),
    );
  });
}
