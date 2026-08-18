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

/// Highest tree stage ever reached, as the stored snapshot holds it.
///
/// The stored half only. `ClearedByReset.treeStage` describes itself as read
/// `max(stored, derived)`, but nothing in the app writes the field or derives
/// a stage yet, so the max would be over one operand — see #150. Deriving from
/// the completed-lesson count to fill the gap is precisely the
/// growing-the-course-shrinks-the-tree bug that field's doc warns against, so
/// this reads what is stored and nothing more.
@riverpod
Future<int> treeStage(Ref ref) async {
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();
  return snapshot.clearedByReset.treeStage;
}
