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
