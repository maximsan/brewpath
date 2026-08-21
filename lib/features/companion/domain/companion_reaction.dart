/// A transient, imperative one-shot the companion plays in response to a
/// discrete app event. A reaction plays its (non-looping) animation, then the
/// companion reverts to its current `CompanionMood`.
///
/// Whether the values marked unwired below ever ship — and what they would
/// displace on screens that already celebrate — is open on
/// [#219](https://github.com/maximsan/brewpath/issues/219). A points-earned
/// value was deleted rather than wired (#212): it stated a payout no rule
/// produced.
enum CompanionReaction {
  /// Right answer (unwired in v1 — inline mini-game feedback handles it).
  correct,

  /// Wrong answer (unwired in v1).
  wrong,

  /// A lesson was completed.
  lessonComplete,

  /// A module's final lesson was completed.
  moduleComplete,

  /// Foundations itself was completed — the course's one-off ending.
  courseComplete,

  /// Today's Keep Sharp recommendation met its own completion rule.
  keepSharpComplete,

  /// A Coffee Challenge was logged — a real brew, made away from the app.
  challengeComplete,

  /// A collectible card was earned (unwired in v1 — card screen has no mascot).
  cardEarned,
}
