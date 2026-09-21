import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:brew_path/features/profile/domain/learner_name.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
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

  /// Stores whether the learner wants a daily reminder.
  ///
  /// Switching it on with no time chosen takes the design's default slot, so
  /// the row never reads on-with-no-time — a state its value cannot show.
  /// Storing is all this does; `askForReminder` is what asks the OS and puts
  /// the occurrences in front of it.
  Future<void> setNotificationsEnabled({required bool enabled}) => _update((s) {
    s.notificationsEnabled = enabled;
    if (enabled) s.dailyReminderTime ??= DailyReminder.defaultTime;
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
/// `v0.1`.
@riverpod
Future<String> appVersionShort(Ref ref) async =>
    'v${(await PackageInfo.fromPlatform()).version}';

/// Wipes the learner's progress.
///
/// Every progress surface follows the write on its own, because it reads the
/// snapshot through a stream (ADR-0031). The settings row is a second table
/// that no snapshot stream covers, so it is still told by hand.
Future<void> resetProgress(WidgetRef ref) async {
  await ref.read(accountWipeProvider).resetProgress();

  ref.invalidate(settingsControllerProvider);
}
