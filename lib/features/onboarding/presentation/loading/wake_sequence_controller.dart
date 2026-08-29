import 'dart:async';

import 'package:brew_path/features/onboarding/presentation/loading/loading_animation.dart';
import 'package:flutter/foundation.dart';

/// Drives the Roasty wake-up sequence independently of the widget tree so the
/// timing logic is unit-testable (via `fakeAsync`) without pumping the screen.
///
/// Two modes, selected at construction:
///  - **Animated:** loops the [WakePhase] state machine on a per-phase timer,
///    notifying listeners on each step. Once the first full cycle has played
///    *and* the bootstrap gate has resolved, it fires `onAdvance` once and
///    stops — guaranteeing the user sees a full wake-up even on a fast boot.
///  - **Reduced motion:** runs no timer; [phase] is a static
///    [WakePhase.brewing] frame and advancement is driven solely by
///    [notifyGateResolved].
///
/// In both modes [loopForever] (a debug toggle) suppresses advancement so the
/// animation can be inspected indefinitely.
class WakeSequenceController extends ChangeNotifier {
  /// Creates a [WakeSequenceController].
  WakeSequenceController({
    required this.reduceMotion,
    required this.loopForever,
    required bool Function() isGateResolved,
    required VoidCallback onAdvance,
  }) : _isGateResolved = isGateResolved,
       _onAdvance = onAdvance;

  /// Whether reduced-motion mode is active (static frame, no looping timer).
  final bool reduceMotion;

  /// Debug toggle: when set, advancement is suppressed indefinitely.
  final bool loopForever;
  final bool Function() _isGateResolved;
  final VoidCallback _onAdvance;

  WakePhase _phase = WakePhase.sleeping;
  int _cycle = 0;
  bool _advanced = false;
  Timer? _stepTimer;

  /// The phase to render. Reduced motion collapses to a static idle frame.
  WakePhase get phase => reduceMotion ? WakePhase.brewing : _phase;

  /// Whether the brand mark should give way to the tap cue.
  ///
  /// The design shows `BREWPATH` on the first cycle and
  /// `TAP ANYWHERE TO CONTINUE` on every cycle after (`roasty.jsx:708`): the
  /// cue earns its place once a learner has watched a whole wake-up and is
  /// still waiting.
  ///
  /// Reduced motion shows it from the first frame. There is no cycle to wait
  /// through there — the static frame *is* the steady state — so withholding
  /// the cue would leave that learner with no sign the screen is tappable,
  /// which is the one thing it has to say.
  bool get showsTapCue => reduceMotion || _cycle > 0;

  /// Begins the sequence. In reduced-motion mode there is nothing to schedule;
  /// advancement waits for [notifyGateResolved].
  void start() {
    if (!reduceMotion) _scheduleNextStep();
  }

  /// Signals that the bootstrap gate may now have resolved. In reduced-motion
  /// mode this is the sole advance trigger; in animated mode the timer loop
  /// owns advancement, so this is a no-op.
  void notifyGateResolved() {
    if (reduceMotion) _advanceIfGateResolved();
  }

  /// Manual skip (tap-anywhere): advances immediately, bypassing the gate.
  /// Disabled while [loopForever] is set.
  void skip() {
    if (loopForever) return;
    _fireAdvance();
  }

  void _scheduleNextStep() {
    _stepTimer?.cancel();
    _stepTimer = Timer(_phase.duration, () {
      _phase = _phase.next;
      if (_phase == WakePhase.sleeping) _cycle++;
      notifyListeners();
      if (_cycle >= 1 && _advanceIfGateResolved()) return;
      _scheduleNextStep();
    });
  }

  /// Advances iff the first cycle is past, the gate has resolved, and we have
  /// not already advanced. Returns whether it fired.
  bool _advanceIfGateResolved() {
    if (loopForever || _advanced || !_isGateResolved()) return false;
    _fireAdvance();
    return true;
  }

  void _fireAdvance() {
    if (_advanced) return;
    _advanced = true;
    _stepTimer?.cancel();
    _onAdvance();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }
}
