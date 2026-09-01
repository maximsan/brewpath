import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:brew_path/shared/models/lesson_model.dart';

/// What the Reference section shows: the guides a learner has earned, and how
/// many are still ahead.
///
/// **A locked guide never leaves [deriveVisualGuideShelf].** "Locked guides are
/// not drawn" is a property of the data the screen receives rather than a rule
/// the screen has to remember — which is the difference between a rule and a
/// convention.
class VisualGuideShelf {
  /// Creates a [VisualGuideShelf].
  const VisualGuideShelf({required this.earned, required this.remaining});

  /// The earned guides, in bank order — so the one opened yesterday is where
  /// it was left.
  final List<VisualGuide> earned;

  /// How many guides the course has still to teach.
  final int remaining;

  /// Whether nothing has been earned yet. The section shows its lock copy and
  /// refuses to open rather than opening onto nothing.
  bool get isLocked => earned.isEmpty;
}

/// Splits [guides] by what [completedLessonIds] has earned.
///
/// The unlock rule and nothing else: no clock, no tier, no context. A guide is
/// earned when the lesson that teaches it is complete, which the extractor has
/// already guaranteed is the *earliest* lesson that teaches it.
VisualGuideShelf deriveVisualGuideShelf(
  List<VisualGuide> guides,
  Set<String> completedLessonIds,
) {
  final earned = guides
      .where((guide) => completedLessonIds.contains(guide.unlockLessonId))
      .toList();
  return VisualGuideShelf(
    earned: earned,
    remaining: guides.length - earned.length,
  );
}

/// The title of the lesson that earns the **next** guide, or null when there
/// is none to name.
///
/// Kept apart from [deriveVisualGuideShelf] because only the Reference
/// heading needs it: the shelf itself is read by lesson cards and the bookmark
/// button, and those must not have to supply the whole course to ask whether
/// one guide is earned.
///
/// [courseLessons] is the course **in the order the learner walks it**, which
/// is the only order in which "next" means anything — the guide bank is drawn
/// in its own order, where the first entry unlocks at `m3l1` and the sixth at
/// `m1l6`. Given an empty course, it answers null rather than guessing.
String? nextGuideUnlockTitle(
  List<VisualGuide> guides,
  Set<String> completedLessonIds, {
  required List<LessonModel> courseLessons,
}) {
  final position = {
    for (var index = 0; index < courseLessons.length; index++)
      courseLessons[index].id: index,
  };

  int? earliest;
  for (final guide in guides) {
    if (completedLessonIds.contains(guide.unlockLessonId)) continue;
    final at = position[guide.unlockLessonId];
    if (at == null) continue;
    if (earliest == null || at < earliest) earliest = at;
  }

  return earliest == null ? null : courseLessons[earliest].title;
}
