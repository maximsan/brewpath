/// A transient, imperative one-shot the companion plays in response to a
/// discrete app event. A reaction plays its (non-looping) animation, then the
/// companion reverts to its current `CompanionMood`.
///
/// Some values are defined for completeness but are intentionally not wired to
/// a call site yet (see `docs/plans/extract-roasty-companion.md`).
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

  /// XP was gained (not companion-driven in v1 — a plain XP toast handles it).
  xpGained,

  /// A collectible card was earned (unwired in v1 — card screen has no mascot).
  cardEarned,
}
