import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:coffee_quest/shared/models/lesson_model.dart';
import 'package:coffee_quest/shared/models/module_model.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
import 'package:coffee_quest/shared/repositories/repository_providers.dart';

part 'learn_providers.g.dart';

/// A module paired with its derived completion state. Not persisted or
/// serialized — purely a read-side view value for the Learn screen.
class ModuleWithProgress {
  const ModuleWithProgress({
    required this.module,
    required this.completedCount,
    required this.totalCount,
    required this.isLocked,
  });

  final ModuleModel module;
  final int completedCount;
  final int totalCount;

  /// Locked until the module named by `unlockRequirement` is fully complete.
  /// The first module (no `unlockRequirement`) is always unlocked.
  final bool isLocked;

  bool get isComplete => totalCount > 0 && completedCount >= totalCount;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
}

@riverpod
Future<List<ModuleWithProgress>> modulesWithProgress(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final modules = await content.getModules();
  final completed = await ref
      .watch(progressRepositoryProvider)
      .getAllCompleted();
  final completedIds = completed.map((r) => r.lessonId).toSet();

  bool moduleComplete(ModuleModel m) =>
      m.lessonIds.isNotEmpty && m.lessonIds.every(completedIds.contains);
  final completeById = {for (final m in modules) m.id: moduleComplete(m)};

  return modules.map((m) {
    final req = m.unlockRequirement;
    return ModuleWithProgress(
      module: m,
      completedCount: m.lessonIds.where(completedIds.contains).length,
      totalCount: m.lessonIds.length,
      isLocked: req != null && !(completeById[req] ?? false),
    );
  }).toList();
}

@riverpod
Future<LessonModel?> todayLesson(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final modules = await content.getModules();
  final completed = await ref
      .watch(progressRepositoryProvider)
      .getAllCompleted();
  final completedIds = completed.map((r) => r.lessonId).toSet();

  for (final module in modules) {
    for (final lessonId in module.lessonIds) {
      if (!completedIds.contains(lessonId)) {
        return content.getLessonById(lessonId);
      }
    }
  }
  return null;
}
