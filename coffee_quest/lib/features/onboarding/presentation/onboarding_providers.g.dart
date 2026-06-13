// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [OnboardingRepository].

@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider = OnboardingRepositoryProvider._();

/// Provides the [OnboardingRepository].

final class OnboardingRepositoryProvider
    extends
        $FunctionalProvider<
          OnboardingRepository,
          OnboardingRepository,
          OnboardingRepository
        >
    with $Provider<OnboardingRepository> {
  /// Provides the [OnboardingRepository].
  OnboardingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingRepositoryHash();

  @$internal
  @override
  $ProviderElement<OnboardingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingRepository create(Ref ref) {
    return onboardingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingRepository>(value),
    );
  }
}

String _$onboardingRepositoryHash() =>
    r'dac5646261fd42e7f3453328094804608ad4e170';

/// Async gate: true once the user has finished the onboarding flow.
/// Watched by the router redirect; invalidated by `OnboardingDraft.complete`.

@ProviderFor(onboardingCompleted)
final onboardingCompletedProvider = OnboardingCompletedProvider._();

/// Async gate: true once the user has finished the onboarding flow.
/// Watched by the router redirect; invalidated by `OnboardingDraft.complete`.

final class OnboardingCompletedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Async gate: true once the user has finished the onboarding flow.
  /// Watched by the router redirect; invalidated by `OnboardingDraft.complete`.
  OnboardingCompletedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingCompletedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingCompletedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return onboardingCompleted(ref);
  }
}

String _$onboardingCompletedHash() =>
    r'e1fecfc8c93e0325de999a927791f2c0d9060b27';

/// In-memory selection draft carried across the goal + brewer screens.
/// Reset and persisted to Drift by [complete]. `keepAlive: true` because
/// the goal is picked on one screen and read on the next — without keepAlive,
/// Riverpod auto-disposes the notifier between routes and the goal is lost.

@ProviderFor(OnboardingDraft)
final onboardingDraftProvider = OnboardingDraftProvider._();

/// In-memory selection draft carried across the goal + brewer screens.
/// Reset and persisted to Drift by [complete]. `keepAlive: true` because
/// the goal is picked on one screen and read on the next — without keepAlive,
/// Riverpod auto-disposes the notifier between routes and the goal is lost.
final class OnboardingDraftProvider
    extends
        $NotifierProvider<OnboardingDraft, ({String? brewer, String? goal})> {
  /// In-memory selection draft carried across the goal + brewer screens.
  /// Reset and persisted to Drift by [complete]. `keepAlive: true` because
  /// the goal is picked on one screen and read on the next — without keepAlive,
  /// Riverpod auto-disposes the notifier between routes and the goal is lost.
  OnboardingDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingDraftProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingDraftHash();

  @$internal
  @override
  OnboardingDraft create() => OnboardingDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({String? brewer, String? goal}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({String? brewer, String? goal})>(
        value,
      ),
    );
  }
}

String _$onboardingDraftHash() => r'db6542e3a85c49fc7d2863a1a889f0e7f79ffa73';

/// In-memory selection draft carried across the goal + brewer screens.
/// Reset and persisted to Drift by [complete]. `keepAlive: true` because
/// the goal is picked on one screen and read on the next — without keepAlive,
/// Riverpod auto-disposes the notifier between routes and the goal is lost.

abstract class _$OnboardingDraft
    extends $Notifier<({String? brewer, String? goal})> {
  ({String? brewer, String? goal}) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({String? brewer, String? goal}),
              ({String? brewer, String? goal})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({String? brewer, String? goal}),
                ({String? brewer, String? goal})
              >,
              ({String? brewer, String? goal}),
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
