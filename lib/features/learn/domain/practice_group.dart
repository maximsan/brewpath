/// The two groups of the Today tab's practice list, which Keep Sharp's Start
/// can open and a tap on the group's own header opens and shuts.
enum PracticeGroupKind {
  /// Finished lessons, one sub-group per module.
  lessons,

  /// The dictionary drills, then the mini-games, one sub-group per kind.
  games,
}
