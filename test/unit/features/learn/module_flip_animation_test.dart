import 'dart:math' as math;

import 'package:brew_path/features/learn/presentation/module_flip_animation.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('flipRestValue', () {
    test('the back rests fully over, not half way', () {
      // ⚠️ The bug this pins: `0.5` is the *edge-on* frame, where a face has
      // no width at all. Resting the reduced-motion path there showed the
      // learner a blank screen.
      expect(flipRestValue(showingBack: true), flipTurnedOver);
      expect(flipRestValue(showingBack: false), flipFaceOn);
      expect(flipRestValue(showingBack: true), isNot(flipSwapPoint));
    });

    test('both rest positions are fully readable', () {
      for (final showingBack in [true, false]) {
        expect(
          flipVisibleFraction(flipRestValue(showingBack: showingBack)),
          closeTo(1, 1e-9),
          reason: 'a face at rest must be face-on',
        );
      }
    });
  });

  group('flipVisibleFraction', () {
    test('is nothing at the swap point — the card is side-on', () {
      expect(flipVisibleFraction(flipSwapPoint), closeTo(0, 1e-9));
    });

    test('falls away from face-on and returns as the turn completes', () {
      expect(flipVisibleFraction(0), closeTo(1, 1e-9));
      expect(flipVisibleFraction(0.25), lessThan(1));
      expect(flipVisibleFraction(1), closeTo(1, 1e-9));
    });
  });

  group('flipAngle', () {
    test('runs from face-on to half a rotation', () {
      expect(flipAngle(flipFaceOn), 0);
      expect(flipAngle(flipTurnedOver), closeTo(math.pi, 1e-9));
    });
  });

  group('flipShowsBack', () {
    test('the front holds until the edge, then the back takes over', () {
      expect(flipShowsBack(0), isFalse);
      expect(flipShowsBack(flipSwapPoint - 0.001), isFalse);
      expect(flipShowsBack(flipSwapPoint), isTrue);
      expect(flipShowsBack(flipTurnedOver), isTrue);
    });
  });

  group('the design’s numbers', () {
    test('820ms, on its own curve', () {
      expect(flipDuration, const Duration(milliseconds: 820));
      expect(flipCurve, const Cubic(0.62, 0.04, 0.2, 1));
    });
  });
}
