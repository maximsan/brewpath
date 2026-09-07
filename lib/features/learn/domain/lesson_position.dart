/// Where a lesson sits inside its module, as Today's card prints it.
///
/// Pure, so the line the card draws can be asserted without pumping the card:
/// `LESSON 1/7 · ~3 MIN` is the design's one mono line under the title, and
/// the number in it is a position in the module rather than in the course.
library;

import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/shared/models/module_model.dart';

/// A lesson's place in its module: its 1-based number, and how many lessons
/// the module has.
typedef LessonPosition = ({int number, int total});

/// The module with [moduleId] among [modules], or null when none carries it.
ModuleModel? moduleOwning(
  Iterable<ModuleWithProgress> modules,
  String moduleId,
) => modules
    .map((item) => item.module)
    .where((module) => module.id == moduleId)
    .firstOrNull;

/// [lessonId]'s place in [module], or null when the module does not list it —
/// a bank whose lesson and module disagree draws no position rather than a
/// wrong one.
LessonPosition? lessonPositionIn(ModuleModel module, String lessonId) {
  final index = module.lessonIds.indexOf(lessonId);
  if (index < 0) return null;
  return (number: index + 1, total: module.lessonIds.length);
}

/// The line as the card letters it — dot-joined, in the design's words.
String todayMetaLine(LessonPosition position, {required int minutes}) =>
    'LESSON ${position.number}/${position.total} · ~$minutes MIN';

/// The same line as a screen reader should hear it.
String todayMetaSemantics(LessonPosition position, {required int minutes}) =>
    'Lesson ${position.number} of ${position.total}, '
    'about $minutes minutes';
