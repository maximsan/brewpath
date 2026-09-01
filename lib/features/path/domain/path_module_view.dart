/// What Path draws: each module at its density, with the lessons under it
/// already paired to the learner's progress.
///
/// Pure, so the whole arrangement — which module is open, which lesson is the
/// learner's next move — is testable without pumping a screen.
library;

import 'package:brew_path/features/learn/domain/course_order.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/features/path/domain/path_density.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/models/lesson_model.dart';

/// One lesson as a Path row draws it.
class PathLesson {
  /// Creates a [PathLesson].
  const PathLesson({
    required this.lesson,
    required this.isCompleted,
    required this.isCurrent,
    required this.isPurchaseLocked,
    required this.mastery,
  });

  /// The lesson itself.
  final LessonModel lesson;

  /// Whether the learner has finished it.
  final bool isCompleted;

  /// Whether this is the learner's next lesson — true for **one** lesson in
  /// the whole course, never one per module.
  final bool isCurrent;

  /// Whether the free tier does not carry this lesson.
  ///
  /// **Not the same lock as [PathModuleDensity.locked].** That one is
  /// progression — finish the module before and it opens. This one is the
  /// purchase, and no amount of learning moves it. A row says which it is,
  /// because "finish the lesson before" is a lie to someone whose next lesson
  /// is behind a wall.
  final bool isPurchaseLocked;

  /// The best stored result, driving how full the row's bean reads.
  final MasteryResult mastery;
}

/// One module as Path draws it.
class PathModule {
  /// Creates a [PathModule].
  const PathModule({
    required this.item,
    required this.density,
    required this.isPurchaseLocked,
    required this.lessons,
  });

  /// The module and its progress.
  final ModuleWithProgress item;

  /// How densely it draws.
  final PathModuleDensity density;

  /// Whether the free tier does not carry this module.
  ///
  /// Decided by its **first** lesson, as the design decides it
  /// (`screens.jsx:1417`): the free set is a lesson list, so a module is
  /// bought-or-not at the point a learner would enter it.
  final bool isPurchaseLocked;

  /// Its lessons in course order, each paired to the learner's progress.
  final List<PathLesson> lessons;

  /// The module's id, which is what the screen keys its expansion on.
  String get id => item.module.id;

  /// The module's own name.
  String get title => item.module.title;

  /// The glyph the module is drawn with.
  String get iconName => item.module.iconName;

  /// How many lessons it holds, reachable or not.
  int get totalCount => item.totalCount;
}

/// Arranges [modules] into what Path draws.
///
/// [lessonsById] is the lessons bank; a module lesson id with no entry is
/// dropped rather than rendered as a blank row. **Currency is still decided
/// over the module's own id list**, not over the rows that survived that drop
/// — otherwise one missing bank entry would promote a later lesson to
/// "current" and point the learner past the one they actually owe.
///
/// [hasCourse] is the learner's entitlement, and it decides the purchase lock
/// alone — the free lesson list ([isLessonFree]) is the same one every other
/// tier question is answered from (ADR-0007). **Pass `false` while it is
/// unresolved**, which is what `courseEntitlement` asks of every caller: a
/// lock shown to a payer for one frame is recoverable, a paid lesson opened
/// for a free learner is not.
List<PathModule> buildPathModules({
  required List<ModuleWithProgress> modules,
  required Map<String, LessonModel> lessonsById,
  required Set<String> completedIds,
  required Map<String, MasteryResult> masteryById,
  required bool hasCourse,
}) {
  final currentId = firstUnfinishedLessonId(modules, completedIds);

  // A finished lesson is never purchase-locked: replay is what a learner keeps
  // when the wall moves behind them, and the design guards its own buy branch
  // the same way (`screens.jsx:1477`).
  bool lockedToPurchase(String lessonId, {required bool isCompleted}) =>
      !hasCourse && !isCompleted && !isLessonFree(lessonId);

  return [
    for (final item in modules)
      PathModule(
        item: item,
        density: pathModuleDensity(item),
        isPurchaseLocked:
            item.module.lessonIds.isNotEmpty &&
            lockedToPurchase(
              item.module.lessonIds.first,
              isCompleted: completedIds.contains(item.module.lessonIds.first),
            ),
        lessons: [
          for (final lessonId in item.module.lessonIds)
            if (lessonsById[lessonId] case final lesson?)
              PathLesson(
                lesson: lesson,
                isCompleted: completedIds.contains(lessonId),
                isCurrent: lessonId == currentId,
                isPurchaseLocked: lockedToPurchase(
                  lessonId,
                  isCompleted: completedIds.contains(lessonId),
                ),
                mastery: masteryById[lessonId] ?? MasteryResult.unscored,
              ),
        ],
      ),
  ];
}
