/// Which games a learner may open, and on what grounds.
///
/// Everything here is pure, so the whole catalog's tier map can be asserted
/// against the real shipped content without pumping a widget.
library;

import 'package:brew_path/shared/models/content/mini_game_format.dart';

/// The modules whose games the free tier carries.
///
/// ⚠️ **This approximates a rule stated in lessons, and owes it a fix.**
/// ADR-0007 fixes the free tier as a named *lesson* list — `m1l1`, `m1l2`,
/// `m1l3` — and says a game is free iff its advertised topic's **teaching
/// lesson** is free, *"never 'its module is m1'"*. The per-game teaching-lesson
/// pointer does not exist on the wire: authoring it is a change to the design
/// source, which #225 owns. Until it lands, the module stands in for the
/// lesson, and on today's catalog the two rules return the identical set —
/// what ADR-0007 calls correct by coincidence. The tier test pins the derived
/// free set by id so the coincidence cannot rot unnoticed.
///
/// **A tier line, never a progression line.** A module the learner opened by
/// finishing the one before it is not thereby free. That is why this does not
/// read the modules bank's own `locked` flag — `ModuleModel` deliberately drops
/// it as the prototype's demo state, and progression and payment are different
/// gates that happen to agree in a screenshot.
const Set<String> freeModuleIds = {'m1'};

/// Whether [format] opens for a learner who does or does not own the course.
///
/// Owning the course opens everything; without it, only the free tier's games.
bool isMiniGameOpen(MiniGameFormat format, {required bool hasCourse}) =>
    hasCourse || freeModuleIds.contains(format.moduleId);

/// The ids of every game a learner without the course may open, in catalog
/// order.
List<String> freeMiniGameIds(List<MiniGameFormat> catalog) => [
  for (final format in catalog)
    if (isMiniGameOpen(format, hasCourse: false)) format.id,
];
