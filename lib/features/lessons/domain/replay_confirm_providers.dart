import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'replay_confirm_providers.g.dart';

/// What the sheet is drawn from. The words are the widget's, off the `.arb`.
typedef ReplayConfirmFacts = ({
  String lessonTitle,
  int minutes,
  int cards,
  bool dayAlreadyEarned,
  int? lastCompletedDay,
  DateTime today,
});

/// What to ask before replaying [lessonId], or null when nothing should be
/// asked — the lesson is unfinished, or the course no longer carries it.
///
/// The day is [currentDayProvider]'s, not the clock's, so the streak line
/// agrees with every other day surface on which day today is. The sheet is
/// read once, at the tap; one left open over midnight keeps its lines.
@riverpod
Future<ReplayConfirmFacts?> replayConfirm(Ref ref, String lessonId) async {
  final today = ref.watch(currentDayProvider);
  final completedFuture = ref.watch(completedLessonsProvider.future);
  final daysFuture = ref.watch(activeDaySetProvider.future);
  final content = ref.watch(contentRepositoryProvider);

  final lesson = await content.getLessonById(lessonId);
  final completed = await completedFuture;
  if (lesson == null || !completed.contains(lessonId)) return null;

  return (
    lessonTitle: lesson.title,
    minutes: lesson.time,
    cards: lesson.cards.length,
    dayAlreadyEarned: (await daysFuture).contains(epochDay(today)),
    lastCompletedDay: completed.lastRunDay(lessonId),
    today: today,
  );
}
