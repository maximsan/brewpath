/// What Path draws: each module at its density, with the lessons under it
/// already paired to the learner's progress.
///
/// Pure, so the whole arrangement — which module is open, which lesson is the
/// learner's next move — is testable without pumping a screen.
library;

import 'package:brew_path/features/learn/domain/course_order.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
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
    required this.mastery,
  });

  /// The lesson itself.
  final LessonModel lesson;

  /// Whether the learner has finished it.
  final bool isCompleted;

  /// Whether this is the learner's next lesson — true for **one** lesson in
  /// the whole course, never one per module.
  final bool isCurrent;

  /// The best stored result, driving how full the row's bean reads.
  final MasteryResult mastery;
}

/// One module as Path draws it.
class PathModule {
  /// Creates a [PathModule].
  const PathModule({
    required this.item,
    required this.density,
    required this.lessons,
  });

  /// The module and its progress.
  final ModuleWithProgress item;

  /// How densely it draws.
  final PathModuleDensity density;

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
List<PathModule> buildPathModules({
  required List<ModuleWithProgress> modules,
  required Map<String, LessonModel> lessonsById,
  required Set<String> completedIds,
  required Map<String, MasteryResult> masteryById,
}) {
  final currentId = firstUnfinishedLessonId(modules, completedIds);

  return [
    for (final item in modules)
      PathModule(
        item: item,
        density: pathModuleDensity(item),
        lessons: [
          for (final lessonId in item.module.lessonIds)
            if (lessonsById[lessonId] case final lesson?)
              PathLesson(
                lesson: lesson,
                isCompleted: completedIds.contains(lessonId),
                isCurrent: lessonId == currentId,
                mastery: masteryById[lessonId] ?? MasteryResult.unscored,
              ),
        ],
      ),
  ];
}
