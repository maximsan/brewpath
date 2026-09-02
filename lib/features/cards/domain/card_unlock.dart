import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_unlock.g.dart';

/// How an unearned card says it is earned.
///
/// Names the lesson when one awards the card, because that is the single
/// action that ends the wait. A module-awarded card has no lesson to name,
/// and neither does one whose lesson this build does not carry — a link
/// minted by a newer build can outrun an older install's content — so both
/// fall back to the module, which is always present on the card.
String earnLine({required String? lessonTitle, required String moduleTag}) =>
    lessonTitle == null || lessonTitle.isEmpty
    ? 'Earn this by finishing $moduleTag'
    : 'Earn this by completing $lessonTitle';

/// The title of the lesson that awards a card, or null when none does.
@riverpod
Future<String?> cardUnlockLessonTitle(Ref ref, String? lessonId) async {
  if (lessonId == null) return null;
  final lesson = await ref
      .watch(contentRepositoryProvider)
      .getLessonById(lessonId);
  return lesson?.title;
}
