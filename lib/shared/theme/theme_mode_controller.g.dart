// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The preference as it stood when the app started.
///
/// Overridden in `main()` with the value `AppBootstrap.initialize` read from
/// the database — a phase `main()` already awaits before `runApp`. That is what
/// makes the appearance **synchronous at the first frame**: the root widget
/// reads a plain value, not an `AsyncValue`, so there is no loading state to
/// render and therefore no flash to mitigate.
///
/// The default here is only what tests and any un-overridden scope see.

@ProviderFor(initialThemeMode)
final initialThemeModeProvider = InitialThemeModeProvider._();

/// The preference as it stood when the app started.
///
/// Overridden in `main()` with the value `AppBootstrap.initialize` read from
/// the database — a phase `main()` already awaits before `runApp`. That is what
/// makes the appearance **synchronous at the first frame**: the root widget
/// reads a plain value, not an `AsyncValue`, so there is no loading state to
/// render and therefore no flash to mitigate.
///
/// The default here is only what tests and any un-overridden scope see.

final class InitialThemeModeProvider
    extends $FunctionalProvider<AppThemeMode, AppThemeMode, AppThemeMode>
    with $Provider<AppThemeMode> {
  /// The preference as it stood when the app started.
  ///
  /// Overridden in `main()` with the value `AppBootstrap.initialize` read from
  /// the database — a phase `main()` already awaits before `runApp`. That is what
  /// makes the appearance **synchronous at the first frame**: the root widget
  /// reads a plain value, not an `AsyncValue`, so there is no loading state to
  /// render and therefore no flash to mitigate.
  ///
  /// The default here is only what tests and any un-overridden scope see.
  InitialThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialThemeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialThemeModeHash();

  @$internal
  @override
  $ProviderElement<AppThemeMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppThemeMode create(Ref ref) {
    return initialThemeMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeMode>(value),
    );
  }
}

String _$initialThemeModeHash() => r'215ff66c4bb025f65813fb2f53546de0d9fe43fc';

/// The live appearance preference. Reads start from [initialThemeMode]; writes
/// persist to the settings row and update the theme in the same frame.
///
/// This controller is the **only** read path for the appearance. The settings
/// row also carries the value, but purely as storage — nothing reads
/// `UserSettingsRecord.themeMode` for display, so a cached copy of that row
/// going stale after a change here cannot surface anywhere.

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// The live appearance preference. Reads start from [initialThemeMode]; writes
/// persist to the settings row and update the theme in the same frame.
///
/// This controller is the **only** read path for the appearance. The settings
/// row also carries the value, but purely as storage — nothing reads
/// `UserSettingsRecord.themeMode` for display, so a cached copy of that row
/// going stale after a change here cannot surface anywhere.
final class ThemeModeControllerProvider
    extends $NotifierProvider<ThemeModeController, AppThemeMode> {
  /// The live appearance preference. Reads start from [initialThemeMode]; writes
  /// persist to the settings row and update the theme in the same frame.
  ///
  /// This controller is the **only** read path for the appearance. The settings
  /// row also carries the value, but purely as storage — nothing reads
  /// `UserSettingsRecord.themeMode` for display, so a cached copy of that row
  /// going stale after a change here cannot surface anywhere.
  ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeMode>(value),
    );
  }
}

String _$themeModeControllerHash() =>
    r'114a200440be32502940379603f278d5aab6f4a6';

/// The live appearance preference. Reads start from [initialThemeMode]; writes
/// persist to the settings row and update the theme in the same frame.
///
/// This controller is the **only** read path for the appearance. The settings
/// row also carries the value, but purely as storage — nothing reads
/// `UserSettingsRecord.themeMode` for display, so a cached copy of that row
/// going stale after a change here cannot surface anywhere.

abstract class _$ThemeModeController extends $Notifier<AppThemeMode> {
  AppThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppThemeMode, AppThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppThemeMode, AppThemeMode>,
              AppThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
