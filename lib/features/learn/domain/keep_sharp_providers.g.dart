// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keep_sharp_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Derives the day's recommendation: the learner's material feeds the pure
/// rotation, which returns the type and the one screen its CTA opens. Null
/// when no registered type has material.
///
/// The reads are the material the rule is asked of: which formats are playable,
/// which the learner already played today, and which lessons they have
/// finished. Every decision made from them lives in [keepSharpResolutionFor].

@ProviderFor(keepSharpRecommendation)
final keepSharpRecommendationProvider = KeepSharpRecommendationProvider._();

/// Derives the day's recommendation: the learner's material feeds the pure
/// rotation, which returns the type and the one screen its CTA opens. Null
/// when no registered type has material.
///
/// The reads are the material the rule is asked of: which formats are playable,
/// which the learner already played today, and which lessons they have
/// finished. Every decision made from them lives in [keepSharpResolutionFor].

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
  /// Derives the day's recommendation: the learner's material feeds the pure
  /// rotation, which returns the type and the one screen its CTA opens. Null
  /// when no registered type has material.
  ///
  /// The reads are the material the rule is asked of: which formats are playable,
  /// which the learner already played today, and which lessons they have
  /// finished. Every decision made from them lives in [keepSharpResolutionFor].
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
    r'c3044bd36b9cbbb8ff9a9cec1314f80e5a3144d7';

/// Whether today's recommendation has met its own completion rule — derived
/// per-day from what the activity layer already records, stored nowhere.
///
/// Mini-game runs record themselves on the day's activity (#126), so the
/// two-different-games rule reads the distinct game ids among today's entries
/// — the same record the streak's qualifying day derives from.

@ProviderFor(keepSharpAcknowledgedToday)
final keepSharpAcknowledgedTodayProvider =
    KeepSharpAcknowledgedTodayProvider._();

/// Whether today's recommendation has met its own completion rule — derived
/// per-day from what the activity layer already records, stored nowhere.
///
/// Mini-game runs record themselves on the day's activity (#126), so the
/// two-different-games rule reads the distinct game ids among today's entries
/// — the same record the streak's qualifying day derives from.

final class KeepSharpAcknowledgedTodayProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether today's recommendation has met its own completion rule — derived
  /// per-day from what the activity layer already records, stored nowhere.
  ///
  /// Mini-game runs record themselves on the day's activity (#126), so the
  /// two-different-games rule reads the distinct game ids among today's entries
  /// — the same record the streak's qualifying day derives from.
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
    r'2854e33184dcabc0df1a97416b66cc5653c6fe7d';
