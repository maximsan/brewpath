import 'package:brew_path/features/onboarding/presentation/loading/wake_sequence_controller.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

/// The brand mark reads `BREWPATH` on the first cycle and
/// `TAP ANYWHERE TO CONTINUE` on every cycle after — `roasty.jsx:708`.
///
/// Driven through the controller rather than the screen: the rule is about
/// how many cycles have played, which is the controller's own state, and a
/// widget test would have to pump real durations to reach the second one.
void main() {
  test('the cue holds off until a full cycle has played', () {
    fakeAsync((async) {
      final controller = WakeSequenceController(
        reduceMotion: false,
        loopForever: true, // never advance, so the loop keeps cycling
        isGateResolved: () => false,
        onAdvance: () {},
      )..start();

      expect(
        controller.showsTapCue,
        isFalse,
        reason: 'the first cycle shows the brand mark',
      );

      // Run well past one full cycle of the phase machine.
      async.elapse(const Duration(seconds: 30));

      expect(
        controller.showsTapCue,
        isTrue,
        reason: 'later cycles tell the learner they can tap',
      );

      controller.dispose();
    });
  });

  test('reduced motion offers the cue immediately', () {
    final controller = WakeSequenceController(
      reduceMotion: true,
      loopForever: false,
      isGateResolved: () => false,
      onAdvance: () {},
    )..start();

    // There is no cycle to wait through in reduced motion — the static frame
    // is the steady state from the first paint. Withholding the cue would
    // leave a reduced-motion learner with no sign the screen is tappable.
    expect(controller.showsTapCue, isTrue);

    controller.dispose();
  });
}
