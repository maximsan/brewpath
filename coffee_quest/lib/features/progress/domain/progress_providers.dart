import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:coffee_quest/shared/repositories/repository_providers.dart';
import 'package:coffee_quest/shared/storage/progress_record.dart';

part 'progress_providers.g.dart';

@riverpod
Future<int> totalXp(TotalXpRef ref) async {
  final settings = await ref.watch(settingsRepositoryProvider).getSettings();
  return settings.totalXp;
}

@riverpod
Future<int> streak(StreakRef ref) async {
  final settings = await ref.watch(settingsRepositoryProvider).getSettings();
  return settings.streakDays;
}

@riverpod
Future<List<ProgressRecord>> completedLessons(CompletedLessonsRef ref) =>
    ref.watch(progressRepositoryProvider).getAllCompleted();

@riverpod
Future<List<String>> collectedCards(CollectedCardsRef ref) =>
    ref.watch(cardRepositoryProvider).getAllCollectedCardIds();
