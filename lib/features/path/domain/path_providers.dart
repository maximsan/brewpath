import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/path/domain/path_module_view.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'path_providers.g.dart';

/// The whole course as Path draws it — every module at its density, with its
/// lessons already paired to the learner's progress.
///
/// One provider for the screen rather than a family per module: Path shows all
/// five modules at once, so a per-module fetch would be five reads of the same
/// two banks, and the "current lesson" rule has to see the course in order
/// anyway.
@riverpod
Future<List<PathModule>> pathModules(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final modules = await ref.watch(modulesWithProgressProvider.future);
  final completed = await ref.watch(completedLessonsProvider.future);
  final hasCourse = await ref.watch(courseEntitlementProvider.future);
  final lessons = await content.getLessons();

  return buildPathModules(
    modules: modules,
    lessonsById: {for (final lesson in lessons) lesson.id: lesson},
    completedIds: completed.ids,
    masteryById: completed.best,
    // Awaited, not `.value ?? false`. The screen is already behind a
    // `FutureProvider`, so no half-built Path is ever drawn.
    hasCourse: hasCourse,
  );
}
