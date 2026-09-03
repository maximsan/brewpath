/// Whether the course wall stands between a learner and a lesson.
///
/// Access is a **separate question from status**. How far someone has got is
/// derived from their progress and says nothing about what they may open; what
/// they may open is this, and it is the same answer on every surface — the
/// Path row that draws the lock, the Today card that sells it, and the router
/// that refuses the player. One function so the three cannot disagree, which
/// is the failure ADR-0016 was written after.
///
/// Pure, so the rule is asserted without a store, a database or a widget.
library;

import 'package:brew_path/features/monetization/domain/free_tier.dart';

/// Whether [lessonId] is behind the purchase for this learner.
///
/// [hasCourse] is the entitlement; pass `false` while it is still unresolved,
/// which is what `courseEntitlement` asks of every caller.
///
/// [isCompleted] keeps a lesson somebody has already played. ADR-0016: a
/// finished lesson never locks, so a wall that moves does not take back work
/// that is done.
bool isLessonPurchaseLocked({
  required String lessonId,
  required bool hasCourse,
  required bool isCompleted,
}) => !hasCourse && !isCompleted && !isLessonFree(lessonId);
