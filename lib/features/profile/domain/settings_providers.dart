import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/account_wipe.dart';
import 'package:brew_path/shared/storage/settings_record.dart';
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

/// Wipes the learner's progress and rebuilds the screens that showed it.
///
/// *What* a reset clears belongs to [AccountWipe] — it publishes the tombstone
/// the second device reads, and clears the stores this app still keeps
/// alongside it. Only the invalidations are here, because only the widget layer
/// knows what was on screen. Takes a [WidgetRef] (not a provider [Ref]) so the
/// caller's lifetime owns the reads and invalidations across this async work.
Future<void> resetProgress(WidgetRef ref) async {
  await ref.read(accountWipeProvider).resetProgress();

  ref.invalidate(totalXpProvider);
  ref.invalidate(streakStatusProvider);
  ref.invalidate(completedLessonsProvider);
  ref.invalidate(collectedCardsProvider);
  ref.invalidate(cardsWithCollectionProvider);
  ref.invalidate(modulesWithProgressProvider);
  ref.invalidate(todayLessonProvider);
  ref.invalidate(gameTypePracticeCountsProvider);
  ref.invalidate(settingsControllerProvider);
}
