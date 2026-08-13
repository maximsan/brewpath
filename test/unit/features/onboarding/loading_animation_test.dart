import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/onboarding/presentation/loading/loading_animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WakePhase', () {
    test('next cycles through all phases and loops back to sleeping', () {
      final visited = <WakePhase>[];
      var phase = WakePhase.sleeping;
      for (var i = 0; i < WakePhase.values.length; i++) {
        visited.add(phase);
        phase = phase.next;
      }
      expect(visited, WakePhase.values);
      expect(phase, WakePhase.sleeping, reason: 'hold wraps back to sleeping');
    });

    test('caption is hidden until brewing, then visible', () {
      expect(WakePhase.sleeping.showsCaption, isFalse);
      expect(WakePhase.sproutGrows.showsCaption, isFalse);
      expect(WakePhase.brewing.showsCaption, isTrue);
      expect(WakePhase.hold.showsCaption, isTrue);
    });

    test('drop overlay shows only during dropFalling', () {
      for (final phase in WakePhase.values) {
        expect(phase.showsDrop, phase == WakePhase.dropFalling);
      }
    });

    test('roastyState maps each phase to the correct pose', () {
      expect(WakePhase.sleeping.roastyState, RoastyState.sleep);
      expect(WakePhase.dropFalling.roastyState, RoastyState.sleep);
      expect(WakePhase.awake.roastyState, RoastyState.awake);
      expect(WakePhase.sproutGrows.roastyState, RoastyState.awake);
      expect(WakePhase.brewing.roastyState, RoastyState.idle);
      expect(WakePhase.hold.roastyState, RoastyState.idle);
    });

    test('growsSprout is true only during sproutGrows', () {
      for (final phase in WakePhase.values) {
        expect(phase.growsSprout, phase == WakePhase.sproutGrows);
      }
    });

    test('hasFullSprout holds from brewing onward', () {
      expect(WakePhase.sleeping.hasFullSprout, isFalse);
      expect(WakePhase.awake.hasFullSprout, isFalse);
      expect(WakePhase.sproutGrows.hasFullSprout, isFalse);
      expect(WakePhase.brewing.hasFullSprout, isTrue);
      expect(WakePhase.hold.hasFullSprout, isTrue);
    });
  });

  group('wakeDropFrame', () {
    test('starts at the top, fully transparent, unsquashed', () {
      final frame = wakeDropFrame(0);
      expect(frame.top, closeTo(0.14, 1e-9));
      expect(frame.opacity, 0);
      expect(frame.scaleX, 1);
      expect(frame.scaleY, 1);
    });

    test('reaches the impact point (41%) by t=0.75', () {
      expect(wakeDropFrame(0.75).top, closeTo(0.41, 1e-9));
      // Clamped: top does not advance past the impact point.
      expect(wakeDropFrame(1).top, closeTo(0.41, 1e-9));
    });

    test('is fully opaque across the mid-fall plateau', () {
      expect(wakeDropFrame(0.3).opacity, closeTo(1, 1e-9));
      expect(wakeDropFrame(0.6).opacity, closeTo(1, 1e-9));
    });

    test('fades back out on impact (opaque at 0.85, gone by t=1)', () {
      expect(wakeDropFrame(0.85).opacity, closeTo(1, 1e-9));
      expect(wakeDropFrame(1).opacity, closeTo(0, 1e-9));
    });

    test('squashes on impact: scaleX grows, scaleY shrinks after 0.75', () {
      final frame = wakeDropFrame(1);
      expect(frame.scaleX, greaterThan(1));
      expect(frame.scaleY, lessThan(1));
    });

    test('opacity always stays within 0..1', () {
      for (var t = 0.0; t <= 1.0; t += 0.05) {
        final o = wakeDropFrame(t).opacity;
        expect(o, inInclusiveRange(0, 1));
      }
    });
  });

  group('wakeSproutScale', () {
    test('starts fully hidden so no sprout nub shows while sleeping', () {
      expect(wakeSproutScale(0), closeTo(0, 1e-9));
    });

    test('overshoots to 1.18 at 60% before settling to 1', () {
      expect(wakeSproutScale(0.6), closeTo(1.18, 1e-9));
      expect(wakeSproutScale(1), closeTo(1, 1e-9));
    });

    test('grows monotonically up to the overshoot peak', () {
      var previous = wakeSproutScale(0);
      for (var t = 0.05; t <= 0.6; t += 0.05) {
        final current = wakeSproutScale(t);
        expect(current, greaterThanOrEqualTo(previous));
        previous = current;
      }
    });

    test('peak exceeds the resting scale (the overshoot is real)', () {
      expect(wakeSproutScale(0.6), greaterThan(wakeSproutScale(1)));
    });

    test('clamps input so out-of-range progress is well defined', () {
      expect(wakeSproutScale(-0.5), closeTo(0, 1e-9));
      expect(wakeSproutScale(1.5), closeTo(1, 1e-9));
    });
  });

  group('pulsingDotOpacity', () {
    test('peaks at the half-period and dips at the edges', () {
      expect(pulsingDotOpacity(0.5, 0), closeTo(1, 1e-9));
      expect(pulsingDotOpacity(0, 0), closeTo(0.22, 1e-9));
      expect(pulsingDotOpacity(1, 0), closeTo(0.22, 1e-9));
    });

    test('delay shifts the peak forward in the period', () {
      const delay = 0.25;
      expect(pulsingDotOpacity(0.5 + delay, delay), closeTo(1, 1e-9));
    });

    test('stays within the 0.22..1 band for any input', () {
      for (var t = 0.0; t <= 1.0; t += 0.05) {
        final o = pulsingDotOpacity(t, 0.3);
        expect(o, inInclusiveRange(0.22, 1.0));
      }
    });
  });
}
