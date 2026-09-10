/// The module a locked game points at.
library;

import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'teaching_module.g.dart';

/// The module teaching [lessonId], or null when the catalog names a lesson
/// the banks do not carry.
///
/// A locked game's offer pitches the module that teaches its topic, so the
/// sheet needs the module's own words rather than the game's.
@riverpod
Future<ModuleModel?> teachingModule(Ref ref, String lessonId) async {
  final content = ref.watch(contentRepositoryProvider);
  final lesson = await content.getLessonById(lessonId);
  if (lesson == null) return null;
  final modules = await content.getModules();
  for (final module in modules) {
    if (module.id == lesson.moduleId) return module;
  }
  return null;
}
