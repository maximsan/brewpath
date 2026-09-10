/// Which games a learner may open, and on what grounds.
///
/// Everything here is pure, so the whole catalog's tier map can be asserted
/// against the real shipped content without pumping a widget.
library;

import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';

/// Whether [format] opens for a learner who does or does not own the course.
///
/// Owning the course opens everything; without it, a game is free iff its
/// teaching lesson is free — ADR-0007's rule, *"never 'its module is m1'"*.
/// A tier line, never a progression line: a module the learner reached by
/// finishing the one before is not thereby free.
bool isMiniGameOpen(MiniGameFormat format, {required bool hasCourse}) =>
    hasCourse || isLessonFree(format.lessonId);

/// The ids of every game a learner without the course may open, in catalog
/// order.
List<String> freeMiniGameIds(List<MiniGameFormat> catalog) => [
  for (final format in catalog)
    if (isMiniGameOpen(format, hasCourse: false)) format.id,
];
