/// What grows the Coffee Tree: course progress in, stage out.
///
/// Pure, so every boundary is testable without a database. The result is only
/// ever used to *raise* the stored stage — see `ClearedByReset.treeStage` for
/// why the stage is stored as an outcome rather than recomputed from a stored
/// lesson count (#150).
library;

import 'package:brew_path/features/progress/domain/tree_frames.dart';

/// The stage [completed] lessons out of [total] have earned.
///
/// Rounds up, so any progress at all has left the fresh-install value behind
/// and finishing the course lands exactly on the last stage. A course with no
/// lessons yields the fresh value rather than dividing by zero.
///
/// Note this is the stage *this* course size implies. It is never written on
/// its own: growing the course lowers what it returns for the same learner,
/// which is exactly why the stored stage is a floor it can only raise.
int treeStageForProgress({required int completed, required int total}) {
  if (total <= 0 || completed <= 0) return freshTreeStage;
  final earned = (completed * treeStageCount + total - 1) ~/ total;
  return earned.clamp(freshTreeStage, treeStageCount);
}

/// The smallest bar the tree screen will draw, as a fraction of full width.
///
/// The design's floor (`screens.jsx:439`). A learner with nothing finished
/// still sees a bar rather than an empty track they might read as a broken
/// one — it says "here is the thing that fills", not "you have progress".
const double minTreeProgressFraction = 0.03;

/// How full the tree screen's bar is with [completed] of [total] lessons done.
///
/// Separate from [treeStageForProgress] because it answers a different
/// question: that one returns which of ten stages has been *earned*, this one
/// is the continuous fill between them. A course with no lessons reads as the
/// floor rather than dividing by zero, and completions beyond the course size
/// — which a grown-then-shrunk course can produce — clamp to full.
double treeProgressFraction({required int completed, required int total}) {
  if (total <= 0) return minTreeProgressFraction;
  final filled = completed / total;
  return filled.clamp(minTreeProgressFraction, 1);
}
