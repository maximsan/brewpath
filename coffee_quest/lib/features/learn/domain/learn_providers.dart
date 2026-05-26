import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:coffee_quest/shared/models/lesson_model.dart';
import 'package:coffee_quest/shared/models/lesson_step_model.dart';
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

/// One row per lesson plus its owning module — used by the Learn screen's
/// "Practice Any Lesson" section to render a grouped, all-lessons list.
class LessonWithModule {
  const LessonWithModule({required this.lesson, required this.module});

  final LessonModel lesson;
  final ModuleModel module;
}

/// Flat ordered list of every lesson, joined with its module so the Learn
/// screen can group them without re-querying.
@riverpod
Future<List<LessonWithModule>> allLessonsWithModule(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final modules = await content.getModules();
  final lessons = await content.getLessons();
  final byId = {for (final l in lessons) l.id: l};

  final out = <LessonWithModule>[];
  for (final module in modules) {
    for (final lessonId in module.lessonIds) {
      final lesson = byId[lessonId];
      if (lesson != null) {
        out.add(LessonWithModule(lesson: lesson, module: module));
      }
    }
  }
  return out;
}

/// How many practiceable steps the user currently has for each game type,
/// counting only steps that live in lessons the user has completed. Drives
/// the enabled state of the "Practice by Game Type" chips on the Learn screen.
@riverpod
Future<Map<String, int>> gameTypePracticeCounts(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final completed = await ref.watch(completedLessonsProvider.future);
  final completedIds = completed.map((r) => r.lessonId).toSet();
  if (completedIds.isEmpty) return const {};

  final lessons = await content.getLessons();
  final counts = <String, int>{};
  for (final lesson in lessons) {
    if (!completedIds.contains(lesson.id)) continue;
    for (final step in lesson.steps) {
      final key = stepTypeKey(step);
      counts[key] = (counts[key] ?? 0) + 1;
    }
  }
  return counts;
}

/// String discriminator that mirrors the JSON `type` field used by Drift /
/// Freezed serialization. Kept centralized so practice flows and selection
/// widgets can refer to one place.
String stepTypeKey(LessonStepModel step) => switch (step) {
  MultipleChoiceStep() => 'multiple_choice',
  DragDropStep() => 'drag_drop',
  SliderStep() => 'slider',
  TapOrderStep() => 'tap_order',
};

/// Ordered list of the four supported game-type discriminators paired with
/// their user-facing labels. Stable ordering so the Learn-tab chip row is
/// predictable across rebuilds.
const gameTypeLabels = <(String, String)>[
  ('multiple_choice', 'Multiple Choice'),
  ('drag_drop', 'Matching'),
  ('tap_order', 'Ordering'),
  ('slider', 'Slider'),
];

String gameTypeDisplayName(String key) =>
    gameTypeLabels.firstWhere((e) => e.$1 == key, orElse: () => (key, key)).$2;
