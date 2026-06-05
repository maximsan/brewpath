import 'package:coffee_quest/features/onboarding/presentation/loading/loading_animation.dart';
import 'package:coffee_quest/features/onboarding/presentation/loading/wake_sequence_controller.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

/// Total duration of one full wake-up cycle (all phases back-to-back).
Duration get _fullCycle => WakePhase.values.fold(
  Duration.zero,
  (sum, phase) => sum + phase.duration,
);

void main() {
  group('WakeSequenceController (animated)', () {
    test('steps through every phase and loops back to sleeping', () {
      fakeAsync((async) {
        final seen = <WakePhase>[];
        final controller = WakeSequenceController(
          reduceMotion: false,
          loopForever: false,
          isGateResolved: () => false, // never advance; just observe the loop
          onAdvance: () {},
        );
        controller.addListener(() => seen.add(controller.phase));
        controller.start();

        async.elapse(_fullCycle);

        // One full cycle visits dropFalling … hold and wraps to sleeping.
        expect(seen.first, WakePhase.dropFalling);
        expect(seen, contains(WakePhase.brewing));
        expect(seen.last, WakePhase.sleeping);
        controller.dispose();
      });
    });

    test('auto-advances once after the first cycle when the gate is ready', () {
      fakeAsync((async) {
        var advances = 0;
        final controller = WakeSequenceController(
          reduceMotion: false,
          loopForever: false,
          isGateResolved: () => true,
          onAdvance: () => advances++,
        )..start();

        async.elapse(_fullCycle * 2);

        expect(advances, 1, reason: 'fires exactly once, then stops');
        controller.dispose();
      });
    });

    test('does not advance until the gate resolves', () {
      fakeAsync((async) {
        var gateReady = false;
        var advances = 0;
        final controller = WakeSequenceController(
          reduceMotion: false,
          loopForever: false,
          isGateResolved: () => gateReady,
          onAdvance: () => advances++,
        )..start();

        async.elapse(_fullCycle);
        expect(advances, 0);

        gateReady = true;
        async.elapse(_fullCycle);
        expect(advances, 1);
        controller.dispose();
      });
    });

    test('loopForever never advances even with the gate ready', () {
      fakeAsync((async) {
        var advances = 0;
        final controller = WakeSequenceController(
          reduceMotion: false,
          loopForever: true,
          isGateResolved: () => true,
          onAdvance: () => advances++,
        )..start();

        async.elapse(_fullCycle * 3);

        expect(advances, 0);
        controller.dispose();
      });
    });
  });

  group('WakeSequenceController (reduced motion)', () {
    test('renders a static brewing frame', () {
      final controller = WakeSequenceController(
        reduceMotion: true,
        loopForever: false,
        isGateResolved: () => false,
        onAdvance: () {},
      );
      expect(controller.phase, WakePhase.brewing);
      controller.dispose();
    });

    test('advances as soon as the gate is reported resolved', () {
      var advances = 0;
      var gateReady = false;
      final controller = WakeSequenceController(
        reduceMotion: true,
        loopForever: false,
        isGateResolved: () => gateReady,
        onAdvance: () => advances++,
      )..start();

      controller.notifyGateResolved();
      expect(advances, 0, reason: 'gate not ready yet');

      gateReady = true;
      controller.notifyGateResolved();
      expect(advances, 1);

      controller.notifyGateResolved();
      expect(advances, 1, reason: 'never advances twice');
      controller.dispose();
    });
  });

  group('skip', () {
    test('advances immediately, bypassing the gate', () {
      var advances = 0;
      final controller = WakeSequenceController(
        reduceMotion: false,
        loopForever: false,
        isGateResolved: () => false,
        onAdvance: () => advances++,
      )..start();

      controller.skip();
      expect(advances, 1);
      controller.dispose();
    });

    test('is disabled while loopForever is set', () {
      var advances = 0;
      final controller = WakeSequenceController(
        reduceMotion: false,
        loopForever: true,
        isGateResolved: () => false,
        onAdvance: () => advances++,
      )..start();

      controller.skip();
      expect(advances, 0);
      controller.dispose();
    });
  });
}
