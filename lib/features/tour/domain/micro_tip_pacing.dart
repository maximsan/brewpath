/// How long the tip layer stays quiet after something has just been said.
///
/// Two tips in a row read as a chain — a tutorial the learner did not ask for —
/// so every beat that puts something on screen buys the next one some silence.
/// The values are the design's own.
abstract final class MicroTipPacing {
  /// After the learner dismisses a tip, on the screen they dismissed it on.
  static const Duration afterDismissal = Duration(seconds: 12);

  /// After a screen change that had nothing on screen to retire. Short: the new
  /// screen is a natural boundary, and the tip that belongs to it should not
  /// feel withheld.
  static const Duration afterQuietScreenChange = Duration(milliseconds: 1600);

  /// After a screen change that retired a visible tip. Longer than
  /// [afterQuietScreenChange] so the two do not read as one following the
  /// other across the transition.
  static const Duration afterRetiringTip = Duration(seconds: 6);

  /// How long the layer waits when the learner moves to another screen.
  static Duration afterLeaving({required bool tipWasShowing}) =>
      tipWasShowing ? afterRetiringTip : afterQuietScreenChange;
}
