import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:brew_path/features/profile/domain/learner_name.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/account_wipe.dart';
import 'package:brew_path/shared/storage/settings_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

/// The name the learner asked to be greeted by, or null where they skipped.
///
/// Its own provider rather than a read through the settings controller so the
/// header re-reads only this, and a haptics toggle does not rebuild it.
@riverpod
Future<String?> learnerName(Ref ref) async =>
    (await ref.watch(settingsControllerProvider.future)).learnerName;

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

  /// Toggles whether the learner wants a daily reminder.
  ///
  /// Switching it on with no time chosen takes the design's default slot, so
  /// the row never reads on-with-no-time — the state its own value has no way
  /// to show.
  ///
  /// **Nothing is scheduled** by this, here or anywhere: see #443.
  Future<void> toggleNotifications() => _update((s) {
    s.notificationsEnabled = !s.notificationsEnabled;
    if (s.notificationsEnabled) {
      s.dailyReminderTime ??= DailyReminder.defaultTime;
    }
  });

  /// Sets the reminder's time, and turns reminders on if they were off.
  ///
  /// Choosing a time *is* asking for the reminder — the design's own sheet
  /// saves with `setNotify(true)` beside the time it stores.
  Future<void> setReminderTime(String time) => _update((s) {
    s
      ..dailyReminderTime = time
      ..notificationsEnabled = true;
  });

  /// Keeps [name] as what the learner is greeted by, or clears it.
  ///
  /// Blank collapses to none — the same answer the onboarding step gives a
  /// skipped field — so Profile falls back to its plain greeting rather than
  /// greeting an empty string.
  Future<void> setLearnerName(String name) =>
      _update((s) => s.learnerName = LearnerName.normalize(name));

  Future<void> _update(void Function(UserSettingsRecord) mutate) async {
    final repo = ref.read(settingsRepositoryProvider);
    final settings = await repo.getSettings();
    mutate(settings);
    await repo.saveSettings(settings);
    state = AsyncData(settings);
  }
}

/// The current app version string, formatted as `x.y.z+build`.
///
/// The build number is for the person reading a crash report, so it belongs on
/// About beside the rest of the fine print — not in the signature line that
/// closes Settings, which the design writes as a version alone.
@riverpod
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
}

/// The marketing version alone, as the design's closing line prints it —
/// `v0.1` (`prototype/screens.jsx:559`).
@riverpod
Future<String> appVersionShort(Ref ref) async =>
    'v${(await PackageInfo.fromPlatform()).version}';

/// Wipes the learner's progress and rebuilds the screens that showed it.
///
/// *What* a reset clears belongs to [AccountWipe] — it publishes the tombstone
/// the second device reads, and clears the stores this app still keeps
/// alongside it. Only the invalidations are here, because only the widget layer
/// knows what was on screen. Takes a [WidgetRef] (not a provider [Ref]) so the
/// caller's lifetime owns the reads and invalidations across this async work.
Future<void> resetProgress(WidgetRef ref) async {
  await ref.read(accountWipeProvider).resetProgress();

  ref.invalidate(totalPointsProvider);
  ref.invalidate(streakStatusProvider);
  ref.invalidate(completedLessonsProvider);
  ref.invalidate(collectedCardsProvider);
  ref.invalidate(cardsWithCollectionProvider);
  ref.invalidate(modulesWithProgressProvider);
  ref.invalidate(todayLessonProvider);
  ref.invalidate(settingsControllerProvider);
  // The shelf goes with the progress it recorded. Without this the header's
  // badge keeps the wiped keys alive: it watches the key set continuously, so
  // nothing else ever asks the store again.
  ref.invalidate(savedKeysProvider);
}
