import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/theme/app_theme_mode.dart';
import 'package:brew_path/shared/theme/theme_mode_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppThemeMode', () {
    test('round-trips through its storage value', () {
      for (final mode in AppThemeMode.values) {
        expect(AppThemeMode.fromStorage(mode.storageValue), mode);
      }
    });

    test('storage values are stable strings, not enum indices', () {
      // Reordering the enum must not repoint a stored preference, so these
      // are asserted literally.
      expect(AppThemeMode.system.storageValue, 'system');
      expect(AppThemeMode.light.storageValue, 'light');
      expect(AppThemeMode.dark.storageValue, 'dark');
    });

    test('unknown and missing values fall back to dark', () {
      expect(AppThemeMode.fromStorage(null), AppThemeMode.dark);
      expect(AppThemeMode.fromStorage(''), AppThemeMode.dark);
      // A value a newer build might write.
      expect(AppThemeMode.fromStorage('sepia'), AppThemeMode.dark);
    });

    test('maps to Flutter ThemeMode', () {
      expect(AppThemeMode.system.materialThemeMode, ThemeMode.system);
      expect(AppThemeMode.light.materialThemeMode, ThemeMode.light);
      expect(AppThemeMode.dark.materialThemeMode, ThemeMode.dark);
    });
  });

  group('persistence', () {
    late AppDatabase db;
    late SettingsRepository repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      AppDatabaseService.instance = db;
      repository = SettingsRepository();
    });

    tearDown(() => db.close());

    test('defaults to dark before anything is written', () async {
      expect((await repository.getSettings()).themeMode, AppThemeMode.dark);
    });

    test('survives a save/read round trip', () async {
      final settings = await repository.getSettings();
      settings.themeMode = AppThemeMode.light;
      await repository.saveSettings(settings);

      expect((await repository.getSettings()).themeMode, AppThemeMode.light);
    });

    test('is preserved by Reset Progress', () async {
      final settings = await repository.getSettings();
      settings
        ..themeMode = AppThemeMode.system
        ..streakDays = 12;
      await repository.saveSettings(settings);

      await repository.resetProgress();

      final after = await repository.getSettings();
      expect(after.streakDays, 0, reason: 'progress should be wiped');
      expect(
        after.themeMode,
        AppThemeMode.system,
        reason: 'appearance is device-local, not progress',
      );
    });
  });

  group('ThemeModeController', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      AppDatabaseService.instance = db;
    });

    tearDown(() => db.close());

    test('starts from the value seeded at startup', () {
      final container = ProviderContainer(
        overrides: [
          initialThemeModeProvider.overrideWithValue(AppThemeMode.light),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeControllerProvider), AppThemeMode.light);
    });

    test('select persists the choice and updates state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(themeModeControllerProvider.notifier)
          .select(AppThemeMode.light);

      expect(container.read(themeModeControllerProvider), AppThemeMode.light);
      expect(
        (await SettingsRepository().getSettings()).themeMode,
        AppThemeMode.light,
        reason: 'the choice must outlive the provider container',
      );
    });

    test('selecting the current mode does not rewrite the row', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Nothing is persisted yet, so a no-op select must leave it that way.
      await container
          .read(themeModeControllerProvider.notifier)
          .select(AppThemeMode.dark);

      final rows = await db.select(db.userSettings).get();
      expect(rows, isEmpty);
    });
  });
}
