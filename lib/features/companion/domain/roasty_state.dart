// Self-descriptive mascot-state enum.
// ignore_for_file: public_member_api_docs

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
  /// **Drawn, and reached by nothing yet.** The design gives this pose to one
  /// moment — Coffee Duel's round-complete beat — and the v1 readiness audit
  /// holds Duel to v2. Every v1 moment that pays already opens on a larger
  /// celebration and states its real amount on the screen behind it, so
  /// handing this to one of them would be a design decision about what happens
  /// to the first celebration rather than a port (#212, #518).
  points,
  card,
  sleep,
  awake,
}
