// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The name the learner asked to be greeted by, or null where they skipped.
///
/// Its own provider rather than a read through the settings controller so the
/// header re-reads only this, and a haptics toggle does not rebuild it.

@ProviderFor(learnerName)
final learnerNameProvider = LearnerNameProvider._();

/// The name the learner asked to be greeted by, or null where they skipped.
///
/// Its own provider rather than a read through the settings controller so the
/// header re-reads only this, and a haptics toggle does not rebuild it.

final class LearnerNameProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The name the learner asked to be greeted by, or null where they skipped.
  ///
  /// Its own provider rather than a read through the settings controller so the
  /// header re-reads only this, and a haptics toggle does not rebuild it.
  LearnerNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'learnerNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$learnerNameHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return learnerName(ref);
  }
}

String _$learnerNameHash() => r'8e26fa66b6a2e74c64775a577092cc6c6081b404';

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
  WhenComplete runBuild() {
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
    return element.handleCreate(ref, build);
  }
}

/// The current app version string, formatted as `x.y.z+build`.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// The current app version string, formatted as `x.y.z+build`.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The current app version string, formatted as `x.y.z+build`.
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
