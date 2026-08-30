/// What grows the Coffee Tree: course progress in, stage out.
///
/// Pure, so every boundary is testable without a database. The result is only
/// ever used to *raise* the stored stage — see `ClearedByReset.treeStage` for
/// why the stage is stored as an outcome rather than recomputed from a stored
/// lesson count (#150).
library;

import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/shared/models/module_model.dart';

/// The stage [completed] core lessons have earned, given the course's
/// [moduleSizes] in path order.
///
/// **Pinned to the modules, never a lesson ratio.** The design states the rule
/// beside its table (`prototype/data.jsx:2942-2959`): *"The 10 stages are
/// pinned to the 5 modules so a module boundary is always a visible jump. Each
/// module owns two growth steps — one at its halfway point, one on completion
/// — except the last, whose single step IS the harvest"*, giving
/// `start 1 · M1 2→3 · M2 4→5 · M3 6→7 · M4 8→9 · M5 →10`.
///
/// A ratio rounded up agreed with that for four growth events and then parted:
/// on the shipped course it reached the last stage at lesson 29, so the tree
/// stopped growing three lessons before Foundations ended and the completion
/// the whole course is built toward moved nothing (#376).
///
/// A course with no modules yields the fresh value rather than dividing by
/// zero. Note this is the stage *this* course shape implies; it is never
/// written on its own, because growing the course lowers what it returns for
/// the same learner — which is why the stored stage is a floor it can only
/// raise.
int treeStageForProgress({
  required int completed,
  required List<int> moduleSizes,
}) {
  if (moduleSizes.isEmpty || completed <= 0) return freshTreeStage;

  var remaining = completed;
  var stage = _seedStage;
  for (var index = 0; index < moduleSizes.length; index++) {
    final size = moduleSizes[index];
    final isLast = index == moduleSizes.length - 1;
    if (remaining >= size) {
      // A finished module is worth both of its steps at once — except the
      // last, whose completion is the single step that is the harvest.
      stage += isLast ? 1 : 2;
      remaining -= size;
      continue;
    }
    if (!isLast && remaining >= _halfway(size)) stage += 1;
    break;
  }
  return stage.clamp(_seedStage, treeStageCount);
}

/// The first stage with a frame, and where a learner one lesson in stands.
const int _seedStage = 1;

/// A module's halfway point, rounded up — the design's `Math.ceil(size / 2)`.
int _halfway(int size) => (size + 1) ~/ 2;

/// The core-lesson counts at which the tree advances, in order.
///
/// Two per module — its halfway point and its completion — and one for the
/// last, whose completion is the harvest. Derived from [moduleSizes] rather
/// than listed, so a content change cannot leave a hand-written table behind.
List<int> treeStageThresholds(List<int> moduleSizes) {
  final thresholds = <int>[];
  var reached = 0;
  for (var index = 0; index < moduleSizes.length; index++) {
    final size = moduleSizes[index];
    if (index != moduleSizes.length - 1) {
      thresholds.add(reached + _halfway(size));
    }
    reached += size;
    thresholds.add(reached);
  }
  return thresholds;
}

/// How many more core lessons reach the next stage, or null when the tree has
/// nowhere further to go.
///
/// **This is what a still tree says instead of nothing.** Most completions
/// cross no threshold — the design's own comment is *"Most completions do not
/// cross a stage threshold"* — so the completion screen prints how far the
/// next one is, and a tree that did not move reads as progress rather than as
/// a picture that failed to load.
int? lessonsToNextStage({
  required int completed,
  required List<int> moduleSizes,
}) {
  final reached = completed < 0 ? 0 : completed;
  for (final threshold in treeStageThresholds(moduleSizes)) {
    if (threshold > reached) return threshold - reached;
  }
  return null;
}

/// Each module's lesson count, in path order — the shape the stage math folds
/// over.
///
/// Sorted by course position rather than trusting the bank's order, because
/// the walk is positional: two modules swapped would move every threshold
/// after them.
List<int> moduleSizesInOrder(List<ModuleModel> modules) {
  final ordered = [...modules]..sort((a, b) => a.n.compareTo(b.n));
  return [for (final module in ordered) module.lessonIds.length];
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
