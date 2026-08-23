import 'package:brew_path/features/path/domain/visual_guide_shelf.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
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

/// The earned guide covering [subject], or null when none is earned.
///
/// Lives here rather than at the call site so nothing outside this feature has
/// to know that a guide is found by subject, or that only earned ones count.
@riverpod
Future<VisualGuide?> earnedGuideFor(Ref ref, String subject) async {
  final shelf = await ref.watch(visualGuideShelfForProvider.future);
  return shelf.earned.where((guide) => guide.subject == subject).firstOrNull;
}
