import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_theme_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_controller.g.dart';

/// The preference as it stood when the app started.
///
/// Overridden in `main()` with the value `AppBootstrap.initialize` read from
/// the database — a phase `main()` already awaits before `runApp`. That is what
/// makes the appearance **synchronous at the first frame**: the root widget
/// reads a plain value, not an `AsyncValue`, so there is no loading state to
/// render and therefore no flash to mitigate.
///
/// The default here is only what tests and any un-overridden scope see.
@Riverpod(keepAlive: true)
AppThemeMode initialThemeMode(Ref ref) => AppThemeMode.fallback;

/// The live appearance preference. Reads start from [initialThemeMode]; writes
/// persist to the settings row and update the theme in the same frame.
///
/// This controller is the **only** read path for the appearance. The settings
/// row also carries the value, but purely as storage — nothing reads
/// `UserSettingsRecord.themeMode` for display, so a cached copy of that row
/// going stale after a change here cannot surface anywhere.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  AppThemeMode build() => ref.watch(initialThemeModeProvider);

  /// Persists [mode] and applies it. State is set after the write so a failed
  /// save cannot leave the UI showing a preference that was never stored.
  Future<void> select(AppThemeMode mode) async {
    if (mode == state) return;
    final repository = ref.read(settingsRepositoryProvider);
    final settings = await repository.getSettings();
    settings.themeMode = mode;
    await repository.saveSettings(settings);
    state = mode;
  }
}
