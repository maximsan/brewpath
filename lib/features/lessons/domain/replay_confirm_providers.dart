import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/lessons/domain/replay_confirm.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'replay_confirm_providers.g.dart';

/// The sheet as it will be drawn: its title, and the lines under it.
typedef ReplayConfirmView = ({String title, List<ReplayConfirmLine> lines});

/// What to ask before replaying [lessonId], or null when nothing should be
/// asked — the lesson is unfinished, or the course no longer carries it.
///
/// The day comes from [currentDayProvider] rather than the clock, so a sheet
/// left open over midnight is rebuilt with the streak line it should have.
@riverpod
Future<ReplayConfirmView?> replayConfirm(Ref ref, String lessonId) async {
  final today = ref.watch(currentDayProvider);
  final completedFuture = ref.watch(completedLessonsProvider.future);
  final daysFuture = ref.watch(activeDaySetProvider.future);
  final content = ref.watch(contentRepositoryProvider);

  final lesson = await content.getLessonById(lessonId);
  final completed = await completedFuture;
  if (lesson == null || !completed.contains(lessonId)) return null;

  return (
    title: ReplayConfirmCopy.title(lesson.title),
    lines: replayConfirmLines(
      minutes: lesson.time,
      cards: lesson.cards.length,
      dayAlreadyEarned: (await daysFuture).contains(epochDay(today)),
      lastCompletedDay: completed.lastRunDay(lessonId),
      today: today,
    ),
  );
}
