/// What logging a Coffee Challenge is worth, and what it records.
library;

import 'package:brew_path/core/constants/points_values.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';

/// How many challenges have been brewed, out of the bank's own count.
typedef ChallengeTally = ({int brewed, int total});

/// The fraction every surface reporting Coffee Challenges folds.
///
/// Counted only for ids [bank] still carries, so a challenge dropped from the
/// course cannot push the numerator past the denominator.
ChallengeTally challengeTally({
  required List<BrewChallenge> bank,
  required Set<String> completed,
}) => (
  brewed: bank.where((challenge) => completed.contains(challenge.id)).length,
  total: bank.length,
);

/// Whether logging [id] is its first completion.
///
/// The one guard the payout, the celebration copy and the record all read, so
/// they cannot disagree about which run this was.
bool isFirstCompletion({
  required String id,
  required Set<String> completed,
}) => !completed.contains(id);

/// The points logging [id] pays.
///
/// Flat, and only the first time. A replay pays nothing — points measure what
/// a learner has covered, not how often they repeat it — and the challenge
/// stays repeatable precisely because repeating it buys nothing.
int challengePayout({
  required String id,
  required Set<String> completed,
}) => isFirstCompletion(id: id, completed: completed)
    ? PointsValues.challengeCompletion
    : 0;

/// Whether the done action may fire yet.
///
/// False until an outcome is picked, so a logged challenge always carries a
/// real answer. Every reaction the design authors asserts the brew happened —
/// the "I didn't do it" escape hatch was deliberately removed — so logging
/// without a pick would record a claim the learner never made.
bool canLogResult(String? picked) => picked != null;

/// The reaction to store for a challenge logged on [day].
///
/// The **text**, never an index: the design has rewritten every reaction once
/// already, so a stored `0` meant *"Tasted the difference"* under the old set
/// and *"Preferred 1:15"* under the new. A string either still matches an
/// authored option or visibly does not.
ChallengeReaction logReaction({
  required String reaction,
  required int day,
}) => ChallengeReaction(reaction: reaction, at: day);
