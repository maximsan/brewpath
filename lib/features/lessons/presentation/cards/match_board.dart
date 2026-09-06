/// The rules a match board is judged by, with no widget attached.
///
/// A board is a set of facts and the few answers they sort into. It clears
/// when every fact is placed, but it only *pays* when it clears without a
/// wrong drop — the card's single success signal is all-or-nothing, so a
/// board finished the hard way scores zero while still letting the learner
/// move on. Keeping that here means the rule is unit-testable and the widget
/// holds none of it (#122).
library;

import 'package:brew_path/shared/models/content/card_parts.dart';

/// The distinct answers the facts sort into, in first-appearance order.
///
/// Order is deliberately stable: the display shuffle is seeded by the host,
/// so this must not introduce a second, unseeded source of order.
List<String> matchTargets(Iterable<MatchPair> pairs) {
  final targets = <String>[];
  for (final pair in pairs) {
    if (!targets.contains(pair.right)) targets.add(pair.right);
  }
  return targets;
}

/// Whether [pair] belongs under [target].
bool matchAccepts(MatchPair pair, String target) => pair.right == target;

/// Whether every fact has been placed. An empty board never clears — there is
/// nothing to have achieved.
bool matchBoardCleared({required int solvedCount, required int total}) =>
    total > 0 && solvedCount >= total;

/// Whether the board earns the card's one success signal: cleared, and
/// cleared without a wrong drop.
bool matchBoardPaysSignal({required bool cleared, required bool faulted}) =>
    cleared && !faulted;

/// What a finished board is called: clean, or the drops it cost.
///
/// The design names the cost rather than only the miss — `2 WRONG DROPS` — so
/// the count has to reach the wording, and the singular has to be right at one.
/// Here rather than in the widget so it can be checked without pumping a board.
String matchBoardVerdict(int wrongDrops) => switch (wrongDrops) {
  0 => 'Clean board',
  1 => '1 wrong drop',
  _ => '$wrongDrops wrong drops',
};
