import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:coffee_quest/shared/repositories/repository_providers.dart';
import 'package:coffee_quest/shared/storage/settings_record.dart';

part 'settings_providers.g.dart';

/// Mutable settings state for the Profile screen. Class form because the
/// haptics/sound toggles mutate and persist state (per CLAUDE.md provider
/// conventions).
@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<UserSettingsRecord> build() =>
      ref.watch(settingsRepositoryProvider).getSettings();

  Future<void> toggleHaptics() =>
      _update((s) => s.hapticsEnabled = !s.hapticsEnabled);

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

@riverpod
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
}
