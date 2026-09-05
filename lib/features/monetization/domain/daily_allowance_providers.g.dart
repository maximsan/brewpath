// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_allowance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether a full learning/practice activity may start right now.
///
/// **Derived, never stored.** The count is the cardinality of today's entries
/// in the activity record — a stored quota would be neither monotonic nor an
/// outcome, and #65 refused that shape three times before this landed.
///
/// Day-dependent, so it is on `invalidateDaySurfaces`: the record it counts is
/// written by the same completions that mark the day, and a stale answer here
/// either sells to a learner who has room or lets a spent day start a third.

@ProviderFor(canStartActivity)
final canStartActivityProvider = CanStartActivityProvider._();

/// Whether a full learning/practice activity may start right now.
///
/// **Derived, never stored.** The count is the cardinality of today's entries
/// in the activity record — a stored quota would be neither monotonic nor an
/// outcome, and #65 refused that shape three times before this landed.
///
/// Day-dependent, so it is on `invalidateDaySurfaces`: the record it counts is
/// written by the same completions that mark the day, and a stale answer here
/// either sells to a learner who has room or lets a spent day start a third.

final class CanStartActivityProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether a full learning/practice activity may start right now.
  ///
  /// **Derived, never stored.** The count is the cardinality of today's entries
  /// in the activity record — a stored quota would be neither monotonic nor an
  /// outcome, and #65 refused that shape three times before this landed.
  ///
  /// Day-dependent, so it is on `invalidateDaySurfaces`: the record it counts is
  /// written by the same completions that mark the day, and a stale answer here
  /// either sells to a learner who has room or lets a spent day start a third.
  CanStartActivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canStartActivityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canStartActivityHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return canStartActivity(ref);
  }
}

String _$canStartActivityHash() => r'887a2e11752eb309841908e2c4bd35e805515f96';
