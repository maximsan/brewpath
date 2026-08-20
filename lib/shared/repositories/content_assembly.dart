import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/content/collectible.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';

/// Raised when a bundled bank cannot be assembled into a usable course.
///
/// The banks ship inside the app, so this is a build defect rather than a
/// runtime condition — which is exactly why it throws instead of degrading. A
/// course that silently loses a lesson looks like a course with fewer lessons,
/// and nothing downstream can tell the difference.
class ContentFormatException implements Exception {
  /// Creates a [ContentFormatException].
  const ContentFormatException(this.message);

  /// What was wrong with the bank.
  final String message;

  @override
  String toString() => 'ContentFormatException: $message';
}

/// Lesson id → the id of the module that lists it.
///
/// The course records ownership in one direction only: a module names its
/// lessons, and a lesson carries a display label. This inverts that once so no
/// reader has to parse `MODULE 1 · BEANS` back into `m1`.
Map<String, String> lessonOwners(List<ModuleModel> modules) => {
  for (final module in modules)
    for (final lesson in module.lessons) lesson.id: module.id,
};

/// The lessons bank, with each record's owning module resolved onto it.
///
/// A lesson no module claims is fatal: it would be unreachable from the Path,
/// uncountable in any module's progress, and invisible to every gate that asks
/// what a module contains.
List<LessonModel> assembleLessons(
  List<Map<String, dynamic>> records,
  List<ModuleModel> modules,
) {
  final owners = lessonOwners(modules);
  return [
    for (final record in records)
      LessonModel.fromJson({
        ...record,
        'moduleId': _ownerOf(record['id'], owners),
      }),
  ];
}

String _ownerOf(Object? lessonId, Map<String, String> owners) {
  final owner = owners[lessonId];
  if (owner == null) {
    throw ContentFormatException('no module claims lesson "$lessonId"');
  }
  return owner;
}

/// Every collectible, joined to the words of whatever unlocks it.
///
/// This is the second reverse lookup: the pointer runs collectible → source,
/// so a card's text is fetched by following it back. A dangling pointer throws
/// rather than yielding a wordless card, because a card with no title is
/// indistinguishable on screen from one that failed to load.
List<CoffeeCardModel> assembleCards({
  required List<Collectible> collectibles,
  required List<LessonModel> lessons,
  required List<ModuleModel> modules,
}) {
  final lessonById = {for (final lesson in lessons) lesson.id: lesson};
  final moduleById = {for (final module in modules) module.id: module};

  return [
    for (final collectible in collectibles)
      _cardFor(collectible, lessonById, moduleById),
  ];
}

CoffeeCardModel _cardFor(
  Collectible collectible,
  Map<String, LessonModel> lessonById,
  Map<String, ModuleModel> moduleById,
) {
  final unlock = collectible.unlock;
  if (!unlock.isValid) {
    throw ContentFormatException(
      'collectible "${collectible.id}" must name exactly one source',
    );
  }

  final lesson = unlock.lessonId == null ? null : lessonById[unlock.lessonId];
  final moduleId = lesson?.moduleId ?? unlock.moduleId;
  final module = moduleId == null ? null : moduleById[moduleId];
  if (module == null || (unlock.lessonId != null && lesson == null)) {
    throw ContentFormatException(
      'collectible "${collectible.id}" points at content that does not exist',
    );
  }

  final reward = lesson?.reward ?? module.reward;
  return CoffeeCardModel(
    id: collectible.id,
    title: reward.title,
    description: reward.summary,
    fact: reward.fact,
    moduleTag: module.title,
    iconName: module.iconName,
    lessonId: lesson?.id,
    moduleId: unlock.moduleId,
  );
}
