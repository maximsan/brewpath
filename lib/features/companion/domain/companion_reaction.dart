/// A transient, imperative one-shot the companion plays in response to a
/// discrete app event. A reaction plays its (non-looping) animation, then the
/// companion reverts to its current `CompanionMood`.
///
/// **Every member is fired by a surface.** A face a widget simply draws — the
/// verdict block's, the predict card's held guess — is set on the mascot
/// directly, the way the design does it, so it is not a reaction. Three
/// members that named such faces and fired nowhere were deleted under
/// [#219](https://github.com/maximsan/brewpath/issues/219).
enum CompanionReaction {
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

  /// A fresh streak milestone — the streak screen's opening beat (#236).
  streakMilestone,
}
