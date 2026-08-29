import 'package:brew_path/features/learn/domain/course_order.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'learn_providers.g.dart';

/// The position of the module every learner starts unlocked.
const int _firstModule = 1;

/// A module paired with its derived completion state. Not persisted or
/// serialized — purely a read-side view value for the Learn screen.
class ModuleWithProgress {
  /// Creates a [ModuleWithProgress].
  const ModuleWithProgress({
    required this.module,
    required this.completedCount,
    required this.totalCount,
    required this.isLocked,
  });

  /// The underlying module.
  final ModuleModel module;

  /// Number of completed lessons in the module.
  final int completedCount;

  /// Total number of lessons in the module.
  final int totalCount;

  /// Locked until the module named by `unlockRequirement` is fully complete.
  /// The first module (no `unlockRequirement`) is always unlocked.
  final bool isLocked;

  /// Whether the module is finished — every lesson complete **and** the module
  /// reachable.
  ///
  /// A locked module never counts as complete, however its lesson tallies read.
  /// The two are independent: a content update that adds a lesson to a
  /// prerequisite re-locks this module without touching its own progress, and
  /// the design guards the same way (`!locked && lessons.every(...)` in
  /// `prototype/screens.jsx`). Without the guard the progression indicators
  /// signal completion by going quiet, so such a module would render with no
  /// lock, no status line and no chevron at all.
  bool get isComplete =>
      !isLocked && totalCount > 0 && completedCount >= totalCount;

  /// Completion fraction in the range 0..1.
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
}

/// All modules paired with their derived completion/lock state.
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
  final completeByPosition = {for (final m in modules) m.n: moduleComplete(m)};

  return modules.map((m) {
    return ModuleWithProgress(
      module: m,
      completedCount: m.lessonIds.where(completedIds.contains).length,
      totalCount: m.lessonIds.length,
      isLocked: !_isReached(m, completeByPosition),
    );
  }).toList();
}

/// Whether [module] has been reached: the first one always, and every later
/// one once the module before it is complete.
///
/// **Derived from position, not read from the bank.** The modules bank carries
/// a `locked` flag, but it is the prototype's demo state — one imaginary
/// learner's progress — so honouring it would lock four modules for everyone
/// forever. The chain it replaces said the same thing by naming a prerequisite
/// module; `n` says it without a second id to keep in step.
bool _isReached(ModuleModel module, Map<int, bool> completeByPosition) {
  if (module.n <= _firstModule) return true;
  return completeByPosition[module.n - 1] ?? false;
}

/// The next uncompleted lesson in order, or null if all are complete.
@riverpod
Future<LessonModel?> todayLesson(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final modules = await content.getModules();
  final completed = await ref
      .watch(progressRepositoryProvider)
      .getAllCompleted();
  final completedIds = completed.map((r) => r.lessonId).toSet();
  // Wrapped so the shared rule can read a module's lesson ids; the lock state
  // is irrelevant to "what is next in order" and is not consulted.
  final inOrder = [
    for (final module in modules)
      ModuleWithProgress(
        module: module,
        completedCount: module.lessonIds.where(completedIds.contains).length,
        totalCount: module.lessonIds.length,
        isLocked: false,
      ),
  ];

  final nextId = firstUnfinishedLessonId(inOrder, completedIds);
  return nextId == null ? null : content.getLessonById(nextId);
}

/// One row per lesson plus its owning module, for the Learn screen's practice
/// section.
class LessonWithModule {
  /// Creates a [LessonWithModule].
  const LessonWithModule({required this.lesson, required this.module});

  /// The lesson.
  final LessonModel lesson;

  /// The lesson's owning module.
  final ModuleModel module;
}

/// The lessons the learner has **finished**, in course order, each joined with
/// its module so the Learn screen can group them without re-querying.
///
/// Finished only, which the design has always said: the prototype titles this
/// section *"Completed work to revisit"* and builds it from the completed set
/// (`screens.jsx:864`), and ADR-0004 calls the group `Lessons` inside the
/// practice section. Listing every lesson — the app's previous behaviour — put
/// modules the learner has not unlocked one tap from being played.
@riverpod
Future<List<LessonWithModule>> completedLessonsWithModule(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final completed = await ref.watch(completedLessonsProvider.future);
  final finished = {for (final record in completed) record.lessonId};
  if (finished.isEmpty) return const [];

  final modules = await content.getModules();
  final lessons = await content.getLessons();
  final byId = {for (final lesson in lessons) lesson.id: lesson};

  return [
    for (final module in modules)
      for (final lessonId in module.lessonIds)
        if (finished.contains(lessonId) && byId[lessonId] != null)
          LessonWithModule(lesson: byId[lessonId]!, module: module),
  ];
}
