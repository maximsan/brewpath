/// Finished lessons arranged by module, for the practice list's Lessons group.
library;

import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/shared/models/module_model.dart';

/// One module's finished lessons, under the module's own header.
class LessonModuleGroup {
  /// Creates a [LessonModuleGroup].
  const LessonModuleGroup({required this.module, required this.lessons});

  /// The module every lesson here belongs to.
  final ModuleModel module;

  /// Its finished lessons, in course order.
  final List<LessonWithModule> lessons;

  /// The header's label: the `MODULE 1 · BEANS` eyebrow every lesson here
  /// already carries, lifted off the rows and onto the group.
  String get label => lessons.first.lesson.moduleLabel;
}

/// [lessons] grouped by module, in the order the modules are first met.
///
/// The input is already in course order, so first-met order is course order
/// too — and a lesson is never dropped: a module the learner has finished
/// nothing in simply has no group.
List<LessonModuleGroup> groupLessonsByModule(List<LessonWithModule> lessons) {
  final groups = <LessonModuleGroup>[];
  for (final entry in lessons) {
    final index = groups.indexWhere(
      (group) => group.module.id == entry.module.id,
    );
    if (index == -1) {
      groups.add(LessonModuleGroup(module: entry.module, lessons: [entry]));
    } else {
      groups[index].lessons.add(entry);
    }
  }
  return groups;
}
