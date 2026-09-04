// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_milestone_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the streak screen should open on the milestone beat now.
///
/// All watches happen before any await — the ack invalidation rebuilds this
/// mid-flight, and a watch on the far side of an async gap would find the old
/// build's ref already disposed.

@ProviderFor(streakMilestoneDue)
final streakMilestoneDueProvider = StreakMilestoneDueProvider._();

/// Whether the streak screen should open on the milestone beat now.
///
/// All watches happen before any await — the ack invalidation rebuilds this
/// mid-flight, and a watch on the far side of an async gap would find the old
/// build's ref already disposed.

final class StreakMilestoneDueProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the streak screen should open on the milestone beat now.
  ///
  /// All watches happen before any await — the ack invalidation rebuilds this
  /// mid-flight, and a watch on the far side of an async gap would find the old
  /// build's ref already disposed.
  StreakMilestoneDueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakMilestoneDueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakMilestoneDueHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return streakMilestoneDue(ref);
  }
}

String _$streakMilestoneDueHash() =>
    r'831716383521cd9565b577945288c5161b7a2efc';
