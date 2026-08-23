/// The module a locked game points at.
library;

import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'teaching_module.g.dart';

/// The module owning [moduleId], or null when the catalog names one the
/// modules bank does not carry.
///
/// A locked game's offer is a pitch for the module that teaches its topic, so
/// the sheet needs the module's own words rather than the game's.
@riverpod
Future<ModuleModel?> teachingModule(Ref ref, String moduleId) async {
  final modules = await ref.watch(contentRepositoryProvider).getModules();
  for (final module in modules) {
    if (module.id == moduleId) return module;
  }
  return null;
}
