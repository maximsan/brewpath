// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the Tour has run once on this device.
///
/// The auto-run gate, and nothing else: `false` means the first run is still
/// owed. Written when a first run ends — by Skip, by Done, or by leaving the
/// tab — so the Tour runs once and never asks (#537). A replay neither reads
/// nor writes it.

@ProviderFor(tourSeen)
final tourSeenProvider = TourSeenProvider._();

/// Whether the Tour has run once on this device.
///
/// The auto-run gate, and nothing else: `false` means the first run is still
/// owed. Written when a first run ends — by Skip, by Done, or by leaving the
/// tab — so the Tour runs once and never asks (#537). A replay neither reads
/// nor writes it.

final class TourSeenProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the Tour has run once on this device.
  ///
  /// The auto-run gate, and nothing else: `false` means the first run is still
  /// owed. Written when a first run ends — by Skip, by Done, or by leaving the
  /// tab — so the Tour runs once and never asks (#537). A replay neither reads
  /// nor writes it.
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

/// The run on screen.
///
/// Read by more than the layer: the Learn list mounts every child while a run
/// is on, so the engine can scroll to a stop that would otherwise still be
/// off-screen and unmounted. See `LearnListView` for why that is the
/// mitigation chosen.

@ProviderFor(TourRunning)
final tourRunningProvider = TourRunningProvider._();

/// The run on screen.
///
/// Read by more than the layer: the Learn list mounts every child while a run
/// is on, so the engine can scroll to a stop that would otherwise still be
/// off-screen and unmounted. See `LearnListView` for why that is the
/// mitigation chosen.
final class TourRunningProvider
    extends $NotifierProvider<TourRunning, TourRun> {
  /// The run on screen.
  ///
  /// Read by more than the layer: the Learn list mounts every child while a run
  /// is on, so the engine can scroll to a stop that would otherwise still be
  /// off-screen and unmounted. See `LearnListView` for why that is the
  /// mitigation chosen.
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
  Override overrideWithValue(TourRun value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TourRun>(value),
    );
  }
}

String _$tourRunningHash() => r'40022253ac21a1b896fa15f294df694bb715c1da';

/// The run on screen.
///
/// Read by more than the layer: the Learn list mounts every child while a run
/// is on, so the engine can scroll to a stop that would otherwise still be
/// off-screen and unmounted. See `LearnListView` for why that is the
/// mitigation chosen.

abstract class _$TourRunning extends $Notifier<TourRun> {
  TourRun build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TourRun, TourRun>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TourRun, TourRun>,
              TourRun,
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
/// callback. Learn consumes it the moment it arrives.

@ProviderFor(TourReplayRequest)
final tourReplayRequestProvider = TourReplayRequestProvider._();

/// A pending request to replay the Tour, raised from outside the Learn tab.
///
/// Replay is asked for on Profile and happens on Learn, which are two branches
/// of the shell that cannot call each other — so the ask is state rather than a
/// callback. Learn consumes it the moment it arrives.
final class TourReplayRequestProvider
    extends $NotifierProvider<TourReplayRequest, bool> {
  /// A pending request to replay the Tour, raised from outside the Learn tab.
  ///
  /// Replay is asked for on Profile and happens on Learn, which are two branches
  /// of the shell that cannot call each other — so the ask is state rather than a
  /// callback. Learn consumes it the moment it arrives.
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
/// callback. Learn consumes it the moment it arrives.

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
