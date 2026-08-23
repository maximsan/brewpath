// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_entitlement.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the learner currently holds the course entitlement.
///
/// Read through the payments abstraction and never from a store SDK, so
/// flipping to a real store touches no feature code. The active no-op reports
/// none, which is what ships today: the app is in the free state by
/// construction, and the entitled path is exercised by overriding this.

@ProviderFor(courseEntitlement)
final courseEntitlementProvider = CourseEntitlementProvider._();

/// Whether the learner currently holds the course entitlement.
///
/// Read through the payments abstraction and never from a store SDK, so
/// flipping to a real store touches no feature code. The active no-op reports
/// none, which is what ships today: the app is in the free state by
/// construction, and the entitled path is exercised by overriding this.

final class CourseEntitlementProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the learner currently holds the course entitlement.
  ///
  /// Read through the payments abstraction and never from a store SDK, so
  /// flipping to a real store touches no feature code. The active no-op reports
  /// none, which is what ships today: the app is in the free state by
  /// construction, and the entitled path is exercised by overriding this.
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

String _$courseEntitlementHash() => r'3e361938504837b8a93287aaa4535be97cb553fc';
