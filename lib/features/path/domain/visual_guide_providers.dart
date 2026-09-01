import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/path/domain/visual_guide_shelf.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/visual_guide_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'visual_guide_providers.g.dart';

/// The Reference section's contents for this learner.
///
/// It watches completed lessons, so finishing the lesson that teaches a guide
/// fills the section in while the learner is still holding the phone — the
/// reward lands without a restart, and a reset locks it again for free.
@riverpod
Future<VisualGuideShelf> visualGuideShelfFor(Ref ref) async {
  final guides = await ref.watch(visualGuideRepositoryProvider).getGuides();
  final completed = await ref.watch(completedLessonsProvider.future);

  return deriveVisualGuideShelf(guides, {
    for (final record in completed) record.lessonId,
  });
}

/// The lesson the Reference heading names as opening the next guide.
///
/// Its own provider rather than a field on the shelf: this is the only reader
/// that needs the whole course in order, and putting it on the shelf would
/// make every `earnedGuideFor` caller — lesson cards, the bookmark button —
/// load the module and lesson banks to ask about one guide.
///
/// **Every `watch` happens before the first `await`.** Reading a `Ref` after
/// an async gap throws once the provider has been disposed, which is what a
/// widget test tearing down mid-load does.
@riverpod
Future<String?> nextGuideUnlock(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final guideRepository = ref.watch(visualGuideRepositoryProvider);
  final completedLessons = ref.watch(completedLessonsProvider.future);

  final guides = await guideRepository.getGuides();
  final completed = await completedLessons;
  final modules = await content.getModules();
  final lessons = await content.getLessons();
  final byId = {for (final lesson in lessons) lesson.id: lesson};

  return nextGuideUnlockTitle(
    guides,
    {for (final record in completed) record.lessonId},
    // The course flattened in module order — the order the learner walks it.
    courseLessons: <LessonModel>[
      for (final module in modules)
        for (final lessonId in module.lessonIds) ?byId[lessonId],
    ],
  );
}

/// Whether the Reference shelf's lock is the purchase rather than progress.
///
/// The two locks need different words, and only one of them is true for a
/// given learner — the words themselves live in `LockedRowCopy`.
@riverpod
Future<bool> referenceLockedByPurchase(Ref ref) async =>
    !await ref.watch(courseEntitlementProvider.future);

/// The earned guide covering [subject], or null when none is earned.
///
/// Lives here rather than at the call site so nothing outside this feature has
/// to know that a guide is found by subject, or that only earned ones count.
@riverpod
Future<VisualGuide?> earnedGuideFor(Ref ref, String subject) async {
  final shelf = await ref.watch(visualGuideShelfForProvider.future);
  return shelf.earned.where((guide) => guide.subject == subject).firstOrNull;
}
