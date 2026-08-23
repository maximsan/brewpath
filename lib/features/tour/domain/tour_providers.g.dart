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

/// A pending request to replay the Tour, raised from outside the Learn tab.
///
/// Replay is asked for on Profile and happens on Learn, which are two branches
/// of the shell that cannot call each other — so the ask is state rather than a
/// callback. Learn consumes it the moment it arrives and runs the stops with no
/// intro overlay and no write, because the learner asking for the Tour again is
/// not a learner being offered it.

@ProviderFor(TourReplayRequest)
final tourReplayRequestProvider = TourReplayRequestProvider._();

/// A pending request to replay the Tour, raised from outside the Learn tab.
///
/// Replay is asked for on Profile and happens on Learn, which are two branches
/// of the shell that cannot call each other — so the ask is state rather than a
/// callback. Learn consumes it the moment it arrives and runs the stops with no
/// intro overlay and no write, because the learner asking for the Tour again is
/// not a learner being offered it.
final class TourReplayRequestProvider
    extends $NotifierProvider<TourReplayRequest, bool> {
  /// A pending request to replay the Tour, raised from outside the Learn tab.
  ///
  /// Replay is asked for on Profile and happens on Learn, which are two branches
  /// of the shell that cannot call each other — so the ask is state rather than a
  /// callback. Learn consumes it the moment it arrives and runs the stops with no
  /// intro overlay and no write, because the learner asking for the Tour again is
  /// not a learner being offered it.
  TourReplayRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tourReplayRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tourReplayRequestHash();

  @$internal
  @override
  TourReplayRequest create() => TourReplayRequest();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tourReplayRequestHash() => r'd8e5cec4a675b0086c44238cb25a04c8389db70c';

/// A pending request to replay the Tour, raised from outside the Learn tab.
///
/// Replay is asked for on Profile and happens on Learn, which are two branches
/// of the shell that cannot call each other — so the ask is state rather than a
/// callback. Learn consumes it the moment it arrives and runs the stops with no
/// intro overlay and no write, because the learner asking for the Tour again is
/// not a learner being offered it.

abstract class _$TourReplayRequest extends $Notifier<bool> {
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
