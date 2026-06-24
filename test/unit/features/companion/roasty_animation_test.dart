import 'dart:math' as math;

import 'package:coffee_quest/features/companion/domain/roasty_state.dart';
import 'package:coffee_quest/features/companion/presentation/roasty_animation.dart';
import 'package:flutter_test/flutter_test.dart';

// Values below are pinned to the current easing formulas (copied 1:1 from the
// design bundle). They lock behavior: changing any extracted coefficient must
// fail a test here.
void main() {
  group('roastyDuration', () {
    test('returns the per-state controller duration', () {
      expect(
        roastyDuration(RoastyState.idle),
        const Duration(seconds: 3, milliseconds: 200),
      );
      expect(
        roastyDuration(RoastyState.correct),
        const Duration(milliseconds: 900),
      );
      expect(
        roastyDuration(RoastyState.wrong),
        const Duration(milliseconds: 500),
      );
      expect(
        roastyDuration(RoastyState.lesson),
        const Duration(milliseconds: 1100),
      );
      expect(
        roastyDuration(RoastyState.module),
        const Duration(milliseconds: 900),
      );
      expect(
        roastyDuration(RoastyState.xp),
        const Duration(milliseconds: 1300),
      );
      expect(
        roastyDuration(RoastyState.card),
        const Duration(milliseconds: 1600),
      );
      expect(
        roastyDuration(RoastyState.sleep),
        const Duration(milliseconds: 3400),
      );
      expect(
        roastyDuration(RoastyState.awake),
        const Duration(milliseconds: 400),
      );
    });
  });

  group('roastyLoops', () {
    test('loops only for idle, card, and sleep', () {
      expect(roastyLoops(RoastyState.idle), isTrue);
      expect(roastyLoops(RoastyState.card), isTrue);
      expect(roastyLoops(RoastyState.sleep), isTrue);
      for (final state in const [
        RoastyState.correct,
        RoastyState.wrong,
        RoastyState.lesson,
        RoastyState.module,
        RoastyState.xp,
        RoastyState.awake,
      ]) {
        expect(roastyLoops(state), isFalse, reason: '$state should not loop');
      }
    });
  });

  group('roastyBodyOffset', () {
    test('states without a translation animation return zero', () {
      for (final state in const [
        RoastyState.card,
        RoastyState.xp,
        RoastyState.module,
        RoastyState.sleep,
        RoastyState.awake,
      ]) {
        expect(roastyBodyOffset(state, 0.5), Offset.zero, reason: '$state');
      }
    });

    test('correct hops to -10 at the quarter beat', () {
      final offset = roastyBodyOffset(RoastyState.correct, 0.25);
      expect(offset.dx, closeTo(0, 1e-9));
      expect(offset.dy, closeTo(-10, 1e-9));
    });

    test('lesson jump follows its keyframes', () {
      expect(roastyBodyOffset(RoastyState.lesson, 0.15).dy, closeTo(-9, 1e-9));
      expect(roastyBodyOffset(RoastyState.lesson, 0.3).dy, closeTo(-18, 1e-9));
      expect(roastyBodyOffset(RoastyState.lesson, 0.5).dy, closeTo(-8, 1e-9));
      expect(roastyBodyOffset(RoastyState.lesson, 0.7).dy, closeTo(-14, 1e-9));
      expect(roastyBodyOffset(RoastyState.lesson, 1).dy, closeTo(0, 1e-9));
    });

    test('wrong shake decays with time', () {
      // amplitude (1-t)*5 at the first sine peak (t = 1/16 → phase = π/2).
      expect(
        roastyBodyOffset(RoastyState.wrong, 0.0625).dx,
        closeTo(4.6875, 1e-9),
      );
      expect(roastyBodyOffset(RoastyState.wrong, 0.0625).dy, closeTo(0, 1e-9));
      expect(roastyBodyOffset(RoastyState.wrong, 1).dx, closeTo(0, 1e-9));
    });

    test('idle breathe is zero at t=0 and dips mid-cycle', () {
      expect(roastyBodyOffset(RoastyState.idle, 0).dy, closeTo(0, 1e-9));
      expect(
        roastyBodyOffset(RoastyState.idle, 0.25).dy,
        closeTo(-3 * math.sin(math.pi / 4), 1e-9),
      );
    });
  });

  group('roastyBodyScale', () {
    test('module grow keyframes', () {
      expect(roastyBodyScale(RoastyState.module, 0), closeTo(1, 1e-9));
      expect(roastyBodyScale(RoastyState.module, 0.4), closeTo(1.12, 1e-9));
      expect(roastyBodyScale(RoastyState.module, 1), closeTo(1.05, 1e-9));
    });

    test('awake blink-pop keyframes', () {
      expect(roastyBodyScale(RoastyState.awake, 0), closeTo(0.94, 1e-9));
      expect(roastyBodyScale(RoastyState.awake, 0.5), closeTo(1.04, 1e-9));
      expect(roastyBodyScale(RoastyState.awake, 1), closeTo(1, 1e-9));
    });

    test('idle squash and default scale', () {
      expect(roastyBodyScale(RoastyState.idle, 0.25), closeTo(1.005, 1e-9));
      expect(roastyBodyScale(RoastyState.card, 0.5), closeTo(1, 1e-9));
    });
  });

  group('roastyBodyRotation', () {
    test('correct tilts 3° on the hop peak', () {
      expect(
        roastyBodyRotation(RoastyState.correct, 0.25),
        closeTo(3 * math.pi / 180, 1e-9),
      );
    });

    test('sleep holds a fixed 6° tilt regardless of t', () {
      expect(
        roastyBodyRotation(RoastyState.sleep, 0),
        closeTo(6 * math.pi / 180, 1e-9),
      );
      expect(
        roastyBodyRotation(RoastyState.sleep, 0.9),
        closeTo(6 * math.pi / 180, 1e-9),
      );
    });

    test('default states have no rotation', () {
      expect(roastyBodyRotation(RoastyState.card, 0.5), closeTo(0, 1e-9));
    });
  });
}
