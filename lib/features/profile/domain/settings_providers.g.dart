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
    r'83b6361e6913851b47f7c85431bb74a6b00bcc41';

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
///
/// The build number is for the person reading a crash report, so it belongs on
/// About beside the rest of the fine print — not in the signature line that
/// closes Settings, which the design writes as a version alone.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// The current app version string, formatted as `x.y.z+build`.
///
/// The build number is for the person reading a crash report, so it belongs on
/// About beside the rest of the fine print — not in the signature line that
/// closes Settings, which the design writes as a version alone.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The current app version string, formatted as `x.y.z+build`.
  ///
  /// The build number is for the person reading a crash report, so it belongs on
  /// About beside the rest of the fine print — not in the signature line that
  /// closes Settings, which the design writes as a version alone.
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

/// The marketing version alone, as the design's closing line prints it —
/// `v0.1` (`prototype/screens.jsx:559`).

@ProviderFor(appVersionShort)
final appVersionShortProvider = AppVersionShortProvider._();

/// The marketing version alone, as the design's closing line prints it —
/// `v0.1` (`prototype/screens.jsx:559`).

final class AppVersionShortProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The marketing version alone, as the design's closing line prints it —
  /// `v0.1` (`prototype/screens.jsx:559`).
  AppVersionShortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionShortProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionShortHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersionShort(ref);
  }
}

String _$appVersionShortHash() => r'c8b0082d7131d96888692811933d9281cc0fb459';
