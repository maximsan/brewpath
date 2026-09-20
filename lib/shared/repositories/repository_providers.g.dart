// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [SettingsRepository].

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// Provides the [SettingsRepository].

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  /// Provides the [SettingsRepository].
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'c5a39438caec85b55a650dcd24bd66b30ea47e8f';

/// Provides the [AccountWipe] — Reset Progress and Delete Account.

@ProviderFor(accountWipe)
final accountWipeProvider = AccountWipeProvider._();

/// Provides the [AccountWipe] — Reset Progress and Delete Account.

final class AccountWipeProvider
    extends $FunctionalProvider<AccountWipe, AccountWipe, AccountWipe>
    with $Provider<AccountWipe> {
  /// Provides the [AccountWipe] — Reset Progress and Delete Account.
  AccountWipeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountWipeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountWipeHash();

  @$internal
  @override
  $ProviderElement<AccountWipe> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountWipe create(Ref ref) {
    return accountWipe(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountWipe value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountWipe>(value),
    );
  }
}

String _$accountWipeHash() => r'3a77396bcc8732faaebcbf002a5b63b711bd3cc4';

/// Provides the [SnapshotRepository].

@ProviderFor(snapshotRepository)
final snapshotRepositoryProvider = SnapshotRepositoryProvider._();

/// Provides the [SnapshotRepository].

final class SnapshotRepositoryProvider
    extends
        $FunctionalProvider<
          SnapshotRepository,
          SnapshotRepository,
          SnapshotRepository
        >
    with $Provider<SnapshotRepository> {
  /// Provides the [SnapshotRepository].
  SnapshotRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'snapshotRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$snapshotRepositoryHash();

  @$internal
  @override
  $ProviderElement<SnapshotRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SnapshotRepository create(Ref ref) {
    return snapshotRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SnapshotRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SnapshotRepository>(value),
    );
  }
}

String _$snapshotRepositoryHash() =>
    r'93a9fe008652c6c4bb29f85cd883ad2ca783f66b';

/// The stored progress, and every later version of it.
///
/// The one place the app listens for progress (ADR-0030). It opens on a
/// one-shot read, so a caller that only wants the value now is not left
/// waiting on an announcement, and outlives every screen, because a write
/// nobody is listening for is an announcement lost.

@ProviderFor(ProgressSnapshotState)
final progressSnapshotStateProvider = ProgressSnapshotStateProvider._();

/// The stored progress, and every later version of it.
///
/// The one place the app listens for progress (ADR-0030). It opens on a
/// one-shot read, so a caller that only wants the value now is not left
/// waiting on an announcement, and outlives every screen, because a write
/// nobody is listening for is an announcement lost.
final class ProgressSnapshotStateProvider
    extends $AsyncNotifierProvider<ProgressSnapshotState, ProgressSnapshot> {
  /// The stored progress, and every later version of it.
  ///
  /// The one place the app listens for progress (ADR-0030). It opens on a
  /// one-shot read, so a caller that only wants the value now is not left
  /// waiting on an announcement, and outlives every screen, because a write
  /// nobody is listening for is an announcement lost.
  ProgressSnapshotStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressSnapshotStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressSnapshotStateHash();

  @$internal
  @override
  ProgressSnapshotState create() => ProgressSnapshotState();
}

String _$progressSnapshotStateHash() =>
    r'a85219f004f71bab471990540f1f6672a1491929';

/// The stored progress, and every later version of it.
///
/// The one place the app listens for progress (ADR-0030). It opens on a
/// one-shot read, so a caller that only wants the value now is not left
/// waiting on an announcement, and outlives every screen, because a write
/// nobody is listening for is an announcement lost.

abstract class _$ProgressSnapshotState
    extends $AsyncNotifier<ProgressSnapshot> {
  FutureOr<ProgressSnapshot> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ProgressSnapshot>, ProgressSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ProgressSnapshot>, ProgressSnapshot>,
              AsyncValue<ProgressSnapshot>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provides the [InstallRepository].

@ProviderFor(installRepository)
final installRepositoryProvider = InstallRepositoryProvider._();

/// Provides the [InstallRepository].

final class InstallRepositoryProvider
    extends
        $FunctionalProvider<
          InstallRepository,
          InstallRepository,
          InstallRepository
        >
    with $Provider<InstallRepository> {
  /// Provides the [InstallRepository].
  InstallRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installRepositoryHash();

  @$internal
  @override
  $ProviderElement<InstallRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InstallRepository create(Ref ref) {
    return installRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstallRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstallRepository>(value),
    );
  }
}

String _$installRepositoryHash() => r'061f824af711ddf66e54b1fcc0456c346e544bb8';
