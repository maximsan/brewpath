import 'package:flutter/material.dart';

/// The user's appearance preference: one of the two moods, or defer to the OS.
///
/// `system` is **not** a third mood — it resolves to [AppThemeMode.light] or
/// [AppThemeMode.dark] from the platform and follows it live. There are only
/// ever two colour sets.
enum AppThemeMode {
  /// Follow the operating system's light/dark setting.
  system('system'),

  /// Always the Cupping (light) mood.
  light('light'),

  /// Always the Dark Roast mood — the app's default.
  dark('dark');

  const AppThemeMode(this.storageValue);

  /// The string persisted in the settings row. Stored rather than the enum
  /// index so reordering this enum cannot silently repoint a saved preference.
  final String storageValue;

  /// The value used when nothing is stored yet, and the fallback for a value
  /// this build does not recognise — an older row, or one written by a newer
  /// build that added a mode.
  static const AppThemeMode fallback = AppThemeMode.dark;

  /// Parses a persisted [storageValue]. Unknown or missing values resolve to
  /// [fallback] rather than throwing: a display preference is never worth
  /// failing a launch over.
  static AppThemeMode fromStorage(String? value) =>
      values.where((mode) => mode.storageValue == value).firstOrNull ??
      fallback;

  /// Flutter's equivalent, for `MaterialApp.themeMode`.
  ThemeMode get materialThemeMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  /// Label shown in the Settings appearance row.
  String get label => switch (this) {
    AppThemeMode.system => 'System',
    AppThemeMode.light => 'Light',
    AppThemeMode.dark => 'Dark',
  };
}
