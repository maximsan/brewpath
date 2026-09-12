/// How densely Path draws a module, and the lesson count above the trail.
///
/// Both are derivations rather than widget state, so they live here and are
/// unit-tested without pumping a screen.
library;

import 'package:brew_path/features/learn/domain/learn_providers.dart';

/// The three densities Path draws a module at.
///
/// The course is one screen, so five modules and thirty-two lessons share it.
/// Every module the learner can reach carries a caret and answers a tap; only
/// the one they are in lists its lessons before being asked.
enum PathModuleDensity {
  /// Reachable and unfinished — the module the learner is in. Opens itself,
  /// because the work in front of someone is what the screen exists to show,
  /// and folds away on a tap like any other.
  active,

  /// Every lesson done. Shut until asked, so finished work is reviewable and
  /// replayable without holding the screen.
  complete,

  /// Not yet reached. A compact static row: nothing to list, so no caret and
  /// nothing a tap could open onto.
  locked;

  /// Whether the header carries a caret and answers a tap. Everything the
  /// learner can reach; only [locked] has nothing behind it.
  bool get canCollapse => this != PathModuleDensity.locked;

  /// Whether the module lists its lessons before anyone asks. Only [active] —
  /// one module open on arrival, which is the one being worked through.
  bool get opensUnasked => this == PathModuleDensity.active;

  /// Whether the module is out of reach. Asked instead of comparing against
  /// the enum value at a call site, so every question about a density is
  /// answered by the density itself.
  bool get isLocked => this == PathModuleDensity.locked;
}

/// Which density [item] draws at.
///
/// Locked is checked first and wins outright. A locked module's lesson tallies
/// can read as complete — a content update that adds a lesson to its
/// prerequisite re-locks it without touching its own progress — and drawing
/// that as a finished module would offer a caret over nothing.
PathModuleDensity pathModuleDensity(ModuleWithProgress item) {
  if (item.isLocked) return PathModuleDensity.locked;
  if (item.isComplete) return PathModuleDensity.complete;
  return PathModuleDensity.active;
}

/// The lesson tally the Path header prints.
class PathCourseSummary {
  /// Creates a [PathCourseSummary].
  const PathCourseSummary({required this.done, required this.unlocked});

  /// Lessons finished, across reachable modules.
  final int done;

  /// Lessons the learner can currently reach.
  final int unlocked;

  /// The design's line — `{done} of {unlocked} lessons complete`, set in mono
  /// smallcaps above the trail.
  ///
  /// "lessons" stays plural at one, as the design writes it: this is a tally,
  /// and a tally that switches to "1 lesson complete" reads as a sentence
  /// about a lesson rather than a count.
  String get label => '$done of $unlocked lessons complete';
}

/// The tally for [modules], counting **lessons, not modules**, and only the
/// ones the learner can reach.
///
/// A locked module contributes to neither half: the design counts against
/// `MODULES.filter(m => !m.locked)`, so the denominator is what is open to the
/// learner now rather than a target that grows with the course.
PathCourseSummary pathCourseSummary(List<ModuleWithProgress> modules) {
  var done = 0;
  var unlocked = 0;

  for (final item in modules) {
    if (item.isLocked) continue;
    done += item.completedCount;
    unlocked += item.totalCount;
  }

  return PathCourseSummary(done: done, unlocked: unlocked);
}
