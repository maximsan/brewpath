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
