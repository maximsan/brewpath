/// All visual states the Roasty mascot can render. Mirrors the
/// `data-state="…"` values the design's mascot component switches on.
enum RoastyState {
  idle,
  correct,
  wrong,
  lesson,
  module,

  /// The wink, over a rising `+N PTS` burst whose amount its host passes in.
  ///
  /// Drawn, and reached by nothing yet: the design gives it to Coffee Duel's
  /// round-complete beat, which is v2, and every v1 payout already opens on a
  /// larger celebration (#212, #518).
  points,
  card,
  sleep,
  awake,
}
