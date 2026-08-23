/// One run of a mini-game: the order it plays in, and how it is judged.
///
/// Everything here is pure. A run writes nothing — no points, no tree growth,
/// no cards, no progress — so all of it is decided from a nonce and a score,
/// and all of it is testable without pumping a widget (#121).
library;

import 'package:brew_path/features/lessons/domain/card_seed.dart';

/// The four-in-five mark the companion celebrates at.
const double _celebrationMark = 0.8;

/// The games whose kind renderers exist in this build.
///
/// The catalog lists every game and every row opens its intro; this decides
/// only whether that intro can start a run, and games join the set as their
/// sibling slices land. Keeping it a registry rather than a card-kind lookup
/// means a game is playable only when someone says so, not incidentally
/// because its kind happens to render.
///
/// Read by the intro's action and by Keep Sharp, which must never recommend a
/// game that cannot run. Deliberately *not* read by the catalog row — a row
/// greyed for a missing renderer is indistinguishable from one behind a
/// paywall.
///
/// **An allowlist has one failure mode, and it has already happened.** A game
/// added to the catalog does not join this set, and nothing notices: the two
/// topic-slugged siblings below rendered from the day they were authored and
/// sat here unplayable for want of a line, because they entered the catalog
/// three days after this set was last written (#311). The guard test pairs
/// this set with [deliberatelyNotPlayable] so the next catalog addition fails
/// the suite until someone rules on it — which is the "someone said so"
/// property this list exists for, restated as something a build can check.
const Set<String> playableMiniGameIds = {
  'g-quiz',
  'g-match',
  'g-quiz-roast-basics',
  'g-match-washed-natural',
};

/// Games whose kind renders, kept out of [playableMiniGameIds] on purpose.
///
/// Empty, and that is the point: an exclusion here is a *decision with a
/// reason attached*, where an absence from the set above is indistinguishable
/// from an oversight. Anything that renders and is in neither place fails the
/// guard test.
const Map<String, String> deliberatelyNotPlayable = <String, String>{};

/// Mints the nonce for one run. One draw per run, held for its duration and
/// never stored — see `card_seed.dart` for why storing it would defeat the
/// shuffle.
int mintRunNonce() => mintLessonNonce();

/// The rounds in the order this run plays them.
///
/// A permutation of the bank: every round appears exactly once, decided by
/// [nonce] alone, so the same nonce replays the same run and Play again — which
/// mints a fresh nonce — does not.
List<T> roundsForRun<T>(List<T> rounds, int nonce) =>
    shuffledBySeed(rounds, nonce);

/// Whether the run earns the celebratory companion reaction.
///
/// At or above the four-in-five mark. A run with no rounds never celebrates,
/// which also keeps the ratio from dividing by zero.
bool isCelebratoryRun({required int score, required int total}) =>
    total > 0 && score / total >= _celebrationMark;

/// The supporting line under the score.
String runEncouragement({required int score, required int total}) {
  if (total == 0) return 'Nothing to play here yet.';
  if (score == total) return 'A clean sweep. Every one of them.';
  if (isCelebratoryRun(score: score, total: total)) {
    return 'Sharp work — that is the mark.';
  }
  if (score == 0) return 'Every one of these is worth another look.';
  return 'Worth another run — the explanations stick.';
}
