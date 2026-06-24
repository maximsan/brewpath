/// The persistent, ambient baseline expression of the companion. Driven
/// reactively by slow-moving signals (an active streak), never by discrete
/// events — those are `CompanionReaction`s that play over the mood and revert.
enum CompanionMood {
  /// Neutral resting state.
  idle,

  /// Pleased/proud baseline, e.g. while a streak is active.
  happy,
}
