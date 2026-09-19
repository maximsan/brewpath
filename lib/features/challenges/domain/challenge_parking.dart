/// Parking a Coffee Challenge for later, and what a lapsed window owes.
///
/// **Park, don't drop.** Every path that would otherwise lose a challenge the
/// learner asked for puts it in the saved queue instead — discarding an intent
/// quietly is the one place it goes missing.
library;

import 'package:brew_path/features/challenges/domain/challenge_lifecycle.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';

/// The saved queue with [id] parked. Idempotent — parking twice is parking.
Set<String> parkChallenge(Set<String> saved, String id) => {...saved, id};

/// The saved queue with [id] removed.
///
/// Removal is a first-class action, which is why the stored field is
/// last-writer-wins rather than a union: unioning the queue would resurrect
/// every challenge the learner ever dismissed, from any device that still
/// remembered it.
Set<String> unparkChallenge(Set<String> saved, String id) =>
    {...saved}..remove(id);

/// What an expiry check should write: the queue, and the cleared pair.
typedef ExpiryPark = ({Set<String> saved, ActiveChallenge? active});

/// The write an expiry check owes, or **null when it owes nothing**.
///
/// That null is the whole idempotence: a cleared pair, a live window and an
/// already-finished challenge each owe no write, so a re-run on either device
/// changes nothing and neither churns the last-writer-wins stamp. A logged
/// challenge is cleared but not queued — the learner has done it.
ExpiryPark? expiryPark({
  required ActiveChallenge? active,
  required Set<String> saved,
  required Set<String> completed,
  required int nowMillis,
}) {
  if (active == null) return null;
  if (!challengeWindowLapsed(active, nowMillis: nowMillis)) return null;

  // A lapsed pair always owes at least the clear, which is what makes the
  // check idempotent: once written, `active` is null and the next call
  // returns before reaching here.
  final alreadyDone = completed.contains(active.id);
  return (
    saved: alreadyDone ? saved : parkChallenge(saved, active.id),
    active: null,
  );
}

/// The challenges the saved list should show, in bank order.
///
/// Excludes only what is in play, and never advertises a challenge whose
/// lesson the learner has not reached. **One already logged still belongs
/// here**: logging unparks it, so it can only be back by having been brewed
/// again and parked, and vanishing was the gesture lying about where it went.
List<String> visibleSavedChallenges({
  required Set<String> saved,
  required String? activeId,
  required List<String> bankOrder,
  required bool Function(String id) isOfferable,
}) => [
  for (final id in bankOrder)
    if (saved.contains(id) && id != activeId && isOfferable(id)) id,
];
