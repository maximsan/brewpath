import 'package:coffee_quest/features/cards/domain/cards_providers.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:coffee_quest/shared/repositories/repository_providers.dart';
import 'package:coffee_quest/shared/storage/settings_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

/// Mutable settings state for the Profile screen. Class form because the
/// haptics/sound toggles mutate and persist state (per CLAUDE.md provider
/// conventions).
@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<UserSettingsRecord> build() =>
      ref.watch(settingsRepositoryProvider).getSettings();

  /// Toggles the haptics preference and persists it.
  Future<void> toggleHaptics() =>
      _update((s) => s.hapticsEnabled = !s.hapticsEnabled);

  /// Toggles the sound preference and persists it.
  Future<void> toggleSound() =>
      _update((s) => s.soundEnabled = !s.soundEnabled);

  Future<void> _update(void Function(UserSettingsRecord) mutate) async {
    final repo = ref.read(settingsRepositoryProvider);
    final settings = await repo.getSettings();
    mutate(settings);
    await repo.saveSettings(settings);
    state = AsyncData(settings);
  }
}

/// The current app version string, formatted as `x.y.z+build`.
@riverpod
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
}

/// Wipes all locally persisted user progress — completed lessons, module XP
/// ledger, collected cards, and the XP / streak / lastActivity fields on the
/// settings singleton — while preserving haptics, sound, and static content.
/// Takes a [WidgetRef] (not a provider [Ref]) so the caller's lifetime owns
/// the reads and invalidations across this async work.
Future<void> resetProgress(WidgetRef ref) async {
  await ref.read(progressRepositoryProvider).deleteAll();
  await ref.read(moduleProgressRepositoryProvider).deleteAll();
  await ref.read(cardRepositoryProvider).deleteAll();
  await ref.read(settingsRepositoryProvider).resetProgress();

  ref.invalidate(totalXpProvider);
  ref.invalidate(streakProvider);
  ref.invalidate(completedLessonsProvider);
  ref.invalidate(collectedCardsProvider);
  ref.invalidate(cardsWithCollectionProvider);
  ref.invalidate(modulesWithProgressProvider);
  ref.invalidate(todayLessonProvider);
  ref.invalidate(gameTypePracticeCountsProvider);
  ref.invalidate(settingsControllerProvider);
}
