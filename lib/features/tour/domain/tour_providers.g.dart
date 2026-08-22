// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the learner has already answered the Tour's intro overlay.
///
/// The auto-run gate, and nothing else: `false` means the intro is still owed,
/// not that the Tour was abandoned mid-way. Abandonment deliberately does not
/// re-arm it — the flag is written when the overlay is *answered*, so someone
/// who started the Tour and backgrounded the app is not asked again.

@ProviderFor(tourSeen)
final tourSeenProvider = TourSeenProvider._();

/// Whether the learner has already answered the Tour's intro overlay.
///
/// The auto-run gate, and nothing else: `false` means the intro is still owed,
/// not that the Tour was abandoned mid-way. Abandonment deliberately does not
/// re-arm it — the flag is written when the overlay is *answered*, so someone
/// who started the Tour and backgrounded the app is not asked again.

final class TourSeenProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the learner has already answered the Tour's intro overlay.
  ///
  /// The auto-run gate, and nothing else: `false` means the intro is still owed,
  /// not that the Tour was abandoned mid-way. Abandonment deliberately does not
  /// re-arm it — the flag is written when the overlay is *answered*, so someone
  /// who started the Tour and backgrounded the app is not asked again.
  TourSeenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tourSeenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tourSeenHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return tourSeen(ref);
  }
}

String _$tourSeenHash() => r'6ca545e8fd5896192b0c7dbae81e5a4f38660f42';

/// Whether the Tour is currently on screen.
///
/// Exists for one reason: the Learn list mounts every child while it is true,
/// so the engine can scroll to a stop that would otherwise still be off-screen
/// and unmounted. See `LearnListView` for why that is the mitigation chosen.

@ProviderFor(TourRunning)
final tourRunningProvider = TourRunningProvider._();

/// Whether the Tour is currently on screen.
///
/// Exists for one reason: the Learn list mounts every child while it is true,
/// so the engine can scroll to a stop that would otherwise still be off-screen
/// and unmounted. See `LearnListView` for why that is the mitigation chosen.
final class TourRunningProvider extends $NotifierProvider<TourRunning, bool> {
  /// Whether the Tour is currently on screen.
  ///
  /// Exists for one reason: the Learn list mounts every child while it is true,
  /// so the engine can scroll to a stop that would otherwise still be off-screen
  /// and unmounted. See `LearnListView` for why that is the mitigation chosen.
  TourRunningProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tourRunningProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tourRunningHash();

  @$internal
  @override
  TourRunning create() => TourRunning();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tourRunningHash() => r'3f73bf1f60bf2a3dfebc4de7471dbecf94a13ae1';

/// Whether the Tour is currently on screen.
///
/// Exists for one reason: the Learn list mounts every child while it is true,
/// so the engine can scroll to a stop that would otherwise still be off-screen
/// and unmounted. See `LearnListView` for why that is the mitigation chosen.

abstract class _$TourRunning extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
