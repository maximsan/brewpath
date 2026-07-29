// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companion_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The companion's ambient baseline mood, derived reactively from the streak.
/// Stays [CompanionMood.idle] until the streak loads, then turns
/// [CompanionMood.happy] while a streak is active. This is the slow-moving
/// baseline; discrete celebrations are `CompanionReaction`s fired per-instance.

@ProviderFor(companionMood)
final companionMoodProvider = CompanionMoodProvider._();

/// The companion's ambient baseline mood, derived reactively from the streak.
/// Stays [CompanionMood.idle] until the streak loads, then turns
/// [CompanionMood.happy] while a streak is active. This is the slow-moving
/// baseline; discrete celebrations are `CompanionReaction`s fired per-instance.

final class CompanionMoodProvider
    extends $FunctionalProvider<CompanionMood, CompanionMood, CompanionMood>
    with $Provider<CompanionMood> {
  /// The companion's ambient baseline mood, derived reactively from the streak.
  /// Stays [CompanionMood.idle] until the streak loads, then turns
  /// [CompanionMood.happy] while a streak is active. This is the slow-moving
  /// baseline; discrete celebrations are `CompanionReaction`s fired per-instance.
  CompanionMoodProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'companionMoodProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$companionMoodHash();

  @$internal
  @override
  $ProviderElement<CompanionMood> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CompanionMood create(Ref ref) {
    return companionMood(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompanionMood value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompanionMood>(value),
    );
  }
}

String _$companionMoodHash() => r'6e2656d8d6402e9f5f9f2ffb2c5a8fa0df9b77b7';

/// Singleton repository for the companion's speech lines.

@ProviderFor(companionLinesRepository)
final companionLinesRepositoryProvider = CompanionLinesRepositoryProvider._();

/// Singleton repository for the companion's speech lines.

final class CompanionLinesRepositoryProvider
    extends
        $FunctionalProvider<
          CompanionLinesRepository,
          CompanionLinesRepository,
          CompanionLinesRepository
        >
    with $Provider<CompanionLinesRepository> {
  /// Singleton repository for the companion's speech lines.
  CompanionLinesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'companionLinesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$companionLinesRepositoryHash();

  @$internal
  @override
  $ProviderElement<CompanionLinesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CompanionLinesRepository create(Ref ref) {
    return companionLinesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompanionLinesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompanionLinesRepository>(value),
    );
  }
}

String _$companionLinesRepositoryHash() =>
    r'276ffa070ede1928f0e8981a04932c97b1ae025c';

/// The loaded companion speech lines.

@ProviderFor(companionLines)
final companionLinesProvider = CompanionLinesProvider._();

/// The loaded companion speech lines.

final class CompanionLinesProvider
    extends
        $FunctionalProvider<
          AsyncValue<CompanionLines>,
          CompanionLines,
          FutureOr<CompanionLines>
        >
    with $FutureModifier<CompanionLines>, $FutureProvider<CompanionLines> {
  /// The loaded companion speech lines.
  CompanionLinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'companionLinesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$companionLinesHash();

  @$internal
  @override
  $FutureProviderElement<CompanionLines> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CompanionLines> create(Ref ref) {
    return companionLines(ref);
  }
}

String _$companionLinesHash() => r'c251fc4b02ca3e96e99a4b2c62b591f9c45e7da5';
