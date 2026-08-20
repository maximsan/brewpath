/// What finishing a lesson did.
library;

import 'package:brew_path/features/progress/domain/mastery.dart';

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
    required this.lessonXp,
    required this.moduleBonusXp,
    required this.mastery,
    required this.practiceXpAwarded,
  });

  /// Whether the lesson had already been finished before this run.
  ///
  /// Derived from the progress store, so it reports what happened rather than
  /// what the caller believed. The completion screen renders on it.
  final bool isReplay;

  /// Points awarded for finishing the lesson itself. Zero on a replay.
  final int lessonXp;

  /// Points awarded for completing the lesson's module, or zero — on a replay,
  /// and on a first completion that did not finish the module.
  final int moduleBonusXp;

  /// The lesson's best stored result after this run. On a replay this is the
  /// never-downgraded best, which may be better than the run just played.
  final MasteryResult mastery;

  /// Whether the once-a-day practice reward paid. Only ever true on a replay.
  final bool practiceXpAwarded;

  /// Whether finishing this lesson also completed its module.
  bool get moduleCompleted => moduleBonusXp > 0;
}
