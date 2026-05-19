// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mutable settings state for the Profile screen. Class form because the
/// haptics/sound toggles mutate and persist state (per CLAUDE.md provider
/// conventions).

@ProviderFor(SettingsController)
final settingsControllerProvider = SettingsControllerProvider._();

/// Mutable settings state for the Profile screen. Class form because the
/// haptics/sound toggles mutate and persist state (per CLAUDE.md provider
/// conventions).
final class SettingsControllerProvider
    extends $AsyncNotifierProvider<SettingsController, UserSettingsRecord> {
  /// Mutable settings state for the Profile screen. Class form because the
  /// haptics/sound toggles mutate and persist state (per CLAUDE.md provider
  /// conventions).
  SettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();
}

String _$settingsControllerHash() =>
    r'e999eb8ac20d0515480ec25250339cd17903977c';

/// Mutable settings state for the Profile screen. Class form because the
/// haptics/sound toggles mutate and persist state (per CLAUDE.md provider
/// conventions).

abstract class _$SettingsController extends $AsyncNotifier<UserSettingsRecord> {
  FutureOr<UserSettingsRecord> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<UserSettingsRecord>, UserSettingsRecord>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserSettingsRecord>, UserSettingsRecord>,
              AsyncValue<UserSettingsRecord>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'9634514c60acb1f79941bdacd697f695d6621e0c';
