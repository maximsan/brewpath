/// What finishing a lesson did.
library;

import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';

/// Outcome of finishing a lesson — which path the run actually took, and what
/// it paid.
///
/// **One type for both**, because the caller no longer chooses between them:
/// the service resolves first completion versus replay from the progress store
/// and reports what it did. A shape with a branch per path would put the
/// question back in the caller's hands, which is the defect (#188).
class LessonFinishResult {
  /// Creates a [LessonFinishResult].
  const LessonFinishResult({
    required this.isReplay,
    required this.pointsEarned,
    required this.mastery,
    this.moduleCompleted = false,
    this.moduleCard,
  });

  /// Whether the lesson had already been finished before this run.
  ///
  /// Derived from the progress store, so it reports what happened rather than
  /// what the caller believed. The completion screen renders on it.
  final bool isReplay;

  /// Points awarded for finishing the lesson itself — the flat value the
  /// lesson authors. Zero on a replay, and the only payout a lesson makes.
  final int pointsEarned;

  /// The lesson's best stored result after this run. On a replay this is the
  /// never-downgraded best, which may be better than the run just played.
  final MasteryResult mastery;

  /// Whether finishing this lesson was the last lesson its module needed.
  ///
  /// **Its own fact, never inferred from a reward.** It used to read
  /// `moduleBonusXp > 0`, and replacing that with `moduleCard != null` would
  /// only swap one payout proxy for another: a module whose Module Reward card
  /// went missing from the bank would silently stop routing to its recap, and
  /// the screen would report the module unfinished because a *content* lookup
  /// came back empty. Completing a module and being handed a card for it are
  /// two different things, so they are two fields.
  final bool moduleCompleted;

  /// The Module Reward card handed over because this run closed its module, or
  /// null when it did not — or when the module awards none.
  ///
  /// **The module's whole reward.** Module completion used to bank a bonus and
  /// show a number; the design pays nothing for a module, because what waits
  /// at the moment is this collectible (§5.1, #16).
  final CoffeeCardModel? moduleCard;
}
