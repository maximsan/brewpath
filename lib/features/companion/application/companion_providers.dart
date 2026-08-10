import 'package:brew_path/features/companion/data/companion_lines_repository.dart';
import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:brew_path/features/companion/domain/companion_mood.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'companion_providers.g.dart';

/// Minimum streak (in days) at which the companion's baseline mood turns happy.
const int _activeStreakThreshold = 1;

/// The companion's ambient baseline mood, derived reactively from the streak.
/// Stays [CompanionMood.idle] until the streak loads, then turns
/// [CompanionMood.happy] while a streak is active. This is the slow-moving
/// baseline; discrete celebrations are `CompanionReaction`s fired per-instance.
@riverpod
CompanionMood companionMood(Ref ref) {
  final streakDays = ref.watch(streakProvider).asData?.value ?? 0;
  return streakDays >= _activeStreakThreshold
      ? CompanionMood.happy
      : CompanionMood.idle;
}

/// Singleton repository for the companion's speech lines.
@riverpod
CompanionLinesRepository companionLinesRepository(Ref ref) =>
    CompanionLinesRepository();

/// The loaded companion speech lines.
@riverpod
Future<CompanionLines> companionLines(Ref ref) =>
    ref.watch(companionLinesRepositoryProvider).getLines();
