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

/// The name the learner typed, until [complete] writes it.
///
/// The whole draft since ADR-0010 cut the goal and brewer questions to v2:
/// the name is the only answer v1 still asks for, and it is optional.
///
/// `keepAlive: true` so the notifier cannot be disposed between the screen
/// reading it and the write finishing — an auto-disposed notifier throws on
/// the `state =` inside [complete].

@ProviderFor(OnboardingDraft)
final onboardingDraftProvider = OnboardingDraftProvider._();

/// The name the learner typed, until [complete] writes it.
///
/// The whole draft since ADR-0010 cut the goal and brewer questions to v2:
/// the name is the only answer v1 still asks for, and it is optional.
///
/// `keepAlive: true` so the notifier cannot be disposed between the screen
/// reading it and the write finishing — an auto-disposed notifier throws on
/// the `state =` inside [complete].
final class OnboardingDraftProvider
    extends $NotifierProvider<OnboardingDraft, String?> {
  /// The name the learner typed, until [complete] writes it.
  ///
  /// The whole draft since ADR-0010 cut the goal and brewer questions to v2:
  /// the name is the only answer v1 still asks for, and it is optional.
  ///
  /// `keepAlive: true` so the notifier cannot be disposed between the screen
  /// reading it and the write finishing — an auto-disposed notifier throws on
  /// the `state =` inside [complete].
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
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$onboardingDraftHash() => r'9429fc68e5cf140f6d1a6ff3c06080bcb2aeb79f';

/// The name the learner typed, until [complete] writes it.
///
/// The whole draft since ADR-0010 cut the goal and brewer questions to v2:
/// the name is the only answer v1 still asks for, and it is optional.
///
/// `keepAlive: true` so the notifier cannot be disposed between the screen
/// reading it and the write finishing — an auto-disposed notifier throws on
/// the `state =` inside [complete].

abstract class _$OnboardingDraft extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
