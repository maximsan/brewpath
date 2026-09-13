// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_entitlement.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Emits the store's new answer whenever what the learner owns changes.
///
/// Watched rather than read, so a subscription that lapses or is refunded
/// locks the app without a restart (ADR-0024).

@ProviderFor(entitlementChanges)
final entitlementChangesProvider = EntitlementChangesProvider._();

/// Emits the store's new answer whenever what the learner owns changes.
///
/// Watched rather than read, so a subscription that lapses or is refunded
/// locks the app without a restart (ADR-0024).

final class EntitlementChangesProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Emits the store's new answer whenever what the learner owns changes.
  ///
  /// Watched rather than read, so a subscription that lapses or is refunded
  /// locks the app without a restart (ADR-0024).
  EntitlementChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entitlementChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entitlementChangesHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return entitlementChanges(ref);
  }
}

String _$entitlementChangesHash() =>
    r'17b432c6a85d1925a92b316a5d6ff0f0a6263b41';

/// Whether the learner currently holds the course entitlement.
///
/// **The one monetization concept feature code may read** (#176) — gates and
/// locked rows ask this and nothing else. Unresolved reads as locked: draw
/// a pending answer as `false`, or await it and show nothing until it lands.

@ProviderFor(courseEntitlement)
final courseEntitlementProvider = CourseEntitlementProvider._();

/// Whether the learner currently holds the course entitlement.
///
/// **The one monetization concept feature code may read** (#176) — gates and
/// locked rows ask this and nothing else. Unresolved reads as locked: draw
/// a pending answer as `false`, or await it and show nothing until it lands.

final class CourseEntitlementProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the learner currently holds the course entitlement.
  ///
  /// **The one monetization concept feature code may read** (#176) — gates and
  /// locked rows ask this and nothing else. Unresolved reads as locked: draw
  /// a pending answer as `false`, or await it and show nothing until it lands.
  CourseEntitlementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courseEntitlementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courseEntitlementHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return courseEntitlement(ref);
  }
}

String _$courseEntitlementHash() => r'0c5d94dd0adcd998e0366a233ffd51f13c6e5702';
