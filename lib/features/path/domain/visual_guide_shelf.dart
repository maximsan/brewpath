import 'package:brew_path/shared/models/content/visual_guide.dart';

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
