/// The Foundations completion moment's firing rule.
///
/// "The course is complete" is derived (no lesson anywhere is current) and
/// permanently true once reached, so without a marker the celebration would
/// replay on every launch. The marker is one key in the snapshot's `acks`
/// map — union-merged across devices, cleared only by Reset Progress, which
/// is the one path that can return the course to incomplete. Ruled in #56;
/// build shape in #120.
library;

/// The `acks` key recording that the completion moment has been shown.
///
/// Stored and synced: renaming it would replay the moment for every finished
/// learner.
const String courseCompleteAckKey = 'courseComplete';

/// Whether the full-screen completion moment should present now.
///
/// [hasCompletedLessons] guards the degenerate caught-up state a contentless
/// build derives — with nothing completed there is nothing to celebrate.
bool courseCompletionMomentDue({
  required bool caughtUp,
  required bool hasCompletedLessons,
  required bool acked,
}) {
  return caughtUp && hasCompletedLessons && !acked;
}
