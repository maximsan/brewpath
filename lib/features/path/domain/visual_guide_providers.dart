import 'package:brew_path/features/path/domain/visual_guide_shelf.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
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

  return visualGuideShelf(guides, {
    for (final record in completed) record.lessonId,
  });
}
