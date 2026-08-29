/// Where the learner is in the course, decided once.
///
/// Two screens ask the same question and must not answer it differently: the
/// Today card offers the day's lesson, and Path marks that lesson current. If
/// each walked the course itself, one could point at a lesson the other did
/// not, and the learner would be in two places at once.
library;

import 'package:brew_path/features/learn/domain/learn_providers.dart';

/// The course's next lesson: the first unfinished one, in course order.
///
/// Null once every lesson is done — a finished course has no "next", and the
/// caller decides what to show instead.
///
/// Reads the module's own `lessonIds` rather than any rendered list, so a
/// lesson missing from the bank cannot promote the one after it.
String? firstUnfinishedLessonId(
  List<ModuleWithProgress> modules,
  Set<String> completedIds,
) {
  for (final item in modules) {
    for (final lessonId in item.module.lessonIds) {
      if (!completedIds.contains(lessonId)) return lessonId;
    }
  }
  return null;
}
