// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keep_sharp_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Derives the day's recommendation: eligibility (a registered surface with
/// material) feeds the pure rotation, and the CTA's concrete entry point is
/// the same day's [keepSharpDailyChoice] so it, too, is stable all day and
/// stores nothing. Null when no registered type has material.

@ProviderFor(keepSharpRecommendation)
final keepSharpRecommendationProvider = KeepSharpRecommendationProvider._();

/// Derives the day's recommendation: eligibility (a registered surface with
/// material) feeds the pure rotation, and the CTA's concrete entry point is
/// the same day's [keepSharpDailyChoice] so it, too, is stable all day and
/// stores nothing. Null when no registered type has material.

final class KeepSharpRecommendationProvider
    extends
        $FunctionalProvider<
          AsyncValue<KeepSharpRecommendation?>,
          KeepSharpRecommendation?,
          FutureOr<KeepSharpRecommendation?>
        >
    with
        $FutureModifier<KeepSharpRecommendation?>,
        $FutureProvider<KeepSharpRecommendation?> {
  /// Derives the day's recommendation: eligibility (a registered surface with
  /// material) feeds the pure rotation, and the CTA's concrete entry point is
  /// the same day's [keepSharpDailyChoice] so it, too, is stable all day and
  /// stores nothing. Null when no registered type has material.
  KeepSharpRecommendationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keepSharpRecommendationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keepSharpRecommendationHash();

  @$internal
  @override
  $FutureProviderElement<KeepSharpRecommendation?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<KeepSharpRecommendation?> create(Ref ref) {
    return keepSharpRecommendation(ref);
  }
}

String _$keepSharpRecommendationHash() =>
    r'b6dc3cefc480db33471ac6a74736798717784313';

/// Whether today's recommendation has met its own completion rule — derived
/// per-day from what the activity layer already records, stored nowhere.
///
/// Drill (mini-game) runs are recorded nowhere today, so that input is
/// honestly zero and a mini-games recommendation never acknowledges; the gap
/// is reported on #120 rather than patched with a new counter here.

@ProviderFor(keepSharpAcknowledgedToday)
final keepSharpAcknowledgedTodayProvider =
    KeepSharpAcknowledgedTodayProvider._();

/// Whether today's recommendation has met its own completion rule — derived
/// per-day from what the activity layer already records, stored nowhere.
///
/// Drill (mini-game) runs are recorded nowhere today, so that input is
/// honestly zero and a mini-games recommendation never acknowledges; the gap
/// is reported on #120 rather than patched with a new counter here.

final class KeepSharpAcknowledgedTodayProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether today's recommendation has met its own completion rule — derived
  /// per-day from what the activity layer already records, stored nowhere.
  ///
  /// Drill (mini-game) runs are recorded nowhere today, so that input is
  /// honestly zero and a mini-games recommendation never acknowledges; the gap
  /// is reported on #120 rather than patched with a new counter here.
  KeepSharpAcknowledgedTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keepSharpAcknowledgedTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keepSharpAcknowledgedTodayHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return keepSharpAcknowledgedToday(ref);
  }
}

String _$keepSharpAcknowledgedTodayHash() =>
    r'f2bb7014de16ee6dd99ea64b092b0990523a8939';
