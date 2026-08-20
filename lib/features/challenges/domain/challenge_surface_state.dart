/// How a Coffee Challenge reads on a surface that only shows it.
library;

/// What a challenge looks like wherever it is displayed.
///
/// Exhaustive on purpose: a new state does not compile until every surface
/// says how it draws it. Four surfaces show challenges, and the failure this
/// prevents is two of them disagreeing about the same challenge on the same
/// screen.
enum ChallengeSurfaceState {
  /// Its lesson or module is unfinished, so it cannot be started.
  locked,

  /// Earned and waiting to be started.
  available,

  /// In play right now.
  active,

  /// Parked in the saved queue.
  saved,

  /// Brewed and logged at least once.
  completed,
}

/// The one derivation every read surface uses.
///
/// **Order matters, and `active` beats `completed`.** A replay of a challenge
/// already earned is live progress, not a recap: a learner who has just
/// restarted one is looking at something in play, and a surface that called it
/// done would contradict the card sitting on their Today screen.
ChallengeSurfaceState challengeSurfaceState({
  required String id,
  required String? activeId,
  required Set<String> completed,
  required Set<String> saved,
  required bool offerable,
}) {
  if (id == activeId) return ChallengeSurfaceState.active;
  if (completed.contains(id)) return ChallengeSurfaceState.completed;
  if (!offerable) return ChallengeSurfaceState.locked;
  if (saved.contains(id)) return ChallengeSurfaceState.saved;
  return ChallengeSurfaceState.available;
}
