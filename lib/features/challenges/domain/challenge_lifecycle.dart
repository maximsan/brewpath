/// When a Coffee Challenge may be offered, how long it stays in play, and what
/// starting one displaces.
///
/// Pure, and scalars in: a millisecond clock reading and the sets the snapshot
/// already stores. Nothing here writes — the reads are read-side filters and
/// the transitions return values for a caller to persist, so the whole
/// lifecycle is testable without a database or a pumped widget.
library;

import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';

/// How long a started challenge stays on Today.
///
/// **Elapsed wall clock, not a calendar boundary.** "Next brews" is a
/// duration — the brew happens away from the app and the log arrives after —
/// so aligning this to local midnight would change what it means. Stated here
/// so nobody later "fixes" it into days.
const Duration challengeWindow = Duration(hours: 48);

/// Whether [challenge] may be offered yet.
///
/// A capstone needs every lesson of its module finished; a lesson challenge
/// needs its own lesson finished. Derived from the completed set — there is no
/// "unlocked" state to store, and one fewer stored thing is one fewer thing
/// that can disagree with the progress it was derived from.
bool challengeOfferable({
  required BrewChallenge challenge,
  required Set<String> moduleLessonIds,
  required Set<String> completedLessonIds,
}) {
  final lessonId = challenge.lessonId;
  return switch (challenge.scope) {
    ChallengeScope.module =>
      moduleLessonIds.isNotEmpty &&
          moduleLessonIds.every(completedLessonIds.contains),
    // A lesson challenge with no lesson can never be earned. The record shape
    // allows it, so the rule says what happens rather than crashing.
    ChallengeScope.lesson =>
      lessonId != null && completedLessonIds.contains(lessonId),
  };
}

/// Whether [active] has run out of time at [nowMillis].
///
/// Exactly at the window it is **still live**: the boundary belongs to the
/// learner, matching the design's own comparison.
bool challengeWindowLapsed(
  ActiveChallenge active, {
  required int nowMillis,
}) => nowMillis - active.startedAt > challengeWindow.inMilliseconds;

/// The challenge id Today should show, or null when nothing is in play.
///
/// **A read-side filter that writes nothing.** A lapsed challenge stops
/// showing here, but clearing the stored pair — and parking the challenge
/// rather than dropping it — belongs to the expiry path, which owns that
/// write. If this cleared as a side effect of being read, there would be
/// nothing left to park.
String? liveChallengeId(ActiveChallenge? active, {required int nowMillis}) {
  if (active == null) return null;
  return challengeWindowLapsed(active, nowMillis: nowMillis) ? null : active.id;
}

/// What starting a challenge does: the one now in play, and the one it pushed
/// out, if any.
typedef ChallengeStart = ({ActiveChallenge active, String? displaced});

/// Starts — or replays — the challenge [id].
///
/// The returned `displaced` names the challenge this pushed out, so the caller
/// can park it. **Never dropped silently**: the learner said they wanted it by
/// starting it, and expiry discarding that intent is the one place it is lost.
///
/// A challenge already finished is not displaced. Replays do not re-queue —
/// putting a completed challenge back in the saved list would ask the learner
/// to do again what they have already done.
ChallengeStart startChallengeTransition({
  required String id,
  required ActiveChallenge? current,
  required Set<String> completed,
  required int nowMillis,
}) {
  final previous = current?.id;
  final displaces =
      previous != null && previous != id && !completed.contains(previous);

  return (
    active: ActiveChallenge(id: id, startedAt: nowMillis),
    displaced: displaces ? previous : null,
  );
}
