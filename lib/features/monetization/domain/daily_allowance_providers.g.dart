// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_allowance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether a full learning/practice activity may start right now.
///
/// Derived, never stored: the count is the cardinality of today's entries in
/// the activity record, and a stored quota would be neither monotonic nor an
/// outcome (#65). Read it through [activityAllowanceNow], not from the cache.

@ProviderFor(canStartActivity)
final canStartActivityProvider = CanStartActivityProvider._();

/// Whether a full learning/practice activity may start right now.
///
/// Derived, never stored: the count is the cardinality of today's entries in
/// the activity record, and a stored quota would be neither monotonic nor an
/// outcome (#65). Read it through [activityAllowanceNow], not from the cache.

final class CanStartActivityProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether a full learning/practice activity may start right now.
  ///
  /// Derived, never stored: the count is the cardinality of today's entries in
  /// the activity record, and a stored quota would be neither monotonic nor an
  /// outcome (#65). Read it through [activityAllowanceNow], not from the cache.
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

String _$canStartActivityHash() => r'2fe4464f91c1d99797947f2493f998bb5787e02c';
