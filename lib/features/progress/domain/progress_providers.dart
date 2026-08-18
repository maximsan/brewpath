import 'package:brew_path/features/progress/domain/tree_growth.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/progress_record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_providers.g.dart';

/// The user's total XP.
@riverpod
Future<int> totalXp(Ref ref) async {
  final settings = await ref.watch(settingsRepositoryProvider).getSettings();
  return settings.totalXp;
}

/// The user's current streak in days.
@riverpod
Future<int> streak(Ref ref) async {
  final settings = await ref.watch(settingsRepositoryProvider).getSettings();
  return settings.streakDays;
}

/// All of the user's completed-lesson records.
@riverpod
Future<List<ProgressRecord>> completedLessons(Ref ref) =>
    ref.watch(progressRepositoryProvider).getAllCompleted();

/// The ids of all cards the user has collected.
@riverpod
Future<List<String>> collectedCards(Ref ref) =>
    ref.watch(cardRepositoryProvider).getAllCollectedCardIds();

/// Highest tree stage ever reached: `max(stored, derived)`, as the field has
/// always described itself.
///
/// The stored half is written by first-time lesson completion and never goes
/// down. The derived half is what the *current* course size implies, and it
/// is here to heal a learner whose stored stage predates the writer — taking
/// the max is what stops it doing harm, because a grown course derives lower
/// for the same learner and the stored floor wins.
@riverpod
Future<int> treeStage(Ref ref) async {
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();
  final completed = await ref.watch(completedLessonsProvider.future);
  final lessons = await ref.watch(contentRepositoryProvider).getLessons();
  final derived = treeStageForProgress(
    completed: completed.length,
    total: lessons.length,
  );
  final stored = snapshot.clearedByReset.treeStage;
  return stored > derived ? stored : derived;
}
