import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_unlock.g.dart';

/// How an unearned card says it is earned.
///
/// Names the lesson when one awards the card, because that is the single
/// action that ends the wait. A module-awarded card has none to name, and
/// neither does one whose lesson this build does not carry, so both fall back
/// to the module, which every card has.
String earnLine(
  AppLocalizations strings, {
  required String? lessonTitle,
  required String moduleTag,
}) => lessonTitle == null || lessonTitle.isEmpty
    ? strings.collectibleEarnByModule(moduleTag)
    : strings.collectibleEarnByLesson(lessonTitle);

/// The title of the lesson that awards a card, or null when none does.
@riverpod
Future<String?> cardUnlockLessonTitle(Ref ref, String? lessonId) async {
  if (lessonId == null) return null;
  final lesson = await ref
      .watch(contentRepositoryProvider)
      .getLessonById(lessonId);
  return lesson?.title;
}
