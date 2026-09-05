// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_entitlement.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the learner currently holds the course entitlement.
///
/// **The one monetization concept feature code may read.** Gates, locked rows
/// and lock marks ask this and nothing else; nothing outside this folder
/// imports the payments service. That is what makes swapping the model — a
/// subscription arm, a hybrid — a change to how a purchase maps to
/// entitlement, never a change to an access check.
///
/// Read through the payments abstraction and never from a store SDK, so
/// flipping to a real store touches no feature code. The active no-op reports
/// none, which is what ships today: the app is in the free state by
/// construction, and the entitled path is exercised by overriding this.
///
/// **Unresolved reads as locked.** A caller that draws while the answer is
/// pending resolves it to `false`, because showing a lock briefly to a paying
/// learner is recoverable and showing paid content briefly to a free one is
/// not. A caller that builds one value from it — the Path's modules, the
/// dictionary's shelf — awaits the answer instead, and shows nothing until it
/// lands: the same safe direction, without a first emission that a one-shot
/// reader would keep.

@ProviderFor(courseEntitlement)
final courseEntitlementProvider = CourseEntitlementProvider._();

/// Whether the learner currently holds the course entitlement.
///
/// **The one monetization concept feature code may read.** Gates, locked rows
/// and lock marks ask this and nothing else; nothing outside this folder
/// imports the payments service. That is what makes swapping the model — a
/// subscription arm, a hybrid — a change to how a purchase maps to
/// entitlement, never a change to an access check.
///
/// Read through the payments abstraction and never from a store SDK, so
/// flipping to a real store touches no feature code. The active no-op reports
/// none, which is what ships today: the app is in the free state by
/// construction, and the entitled path is exercised by overriding this.
///
/// **Unresolved reads as locked.** A caller that draws while the answer is
/// pending resolves it to `false`, because showing a lock briefly to a paying
/// learner is recoverable and showing paid content briefly to a free one is
/// not. A caller that builds one value from it — the Path's modules, the
/// dictionary's shelf — awaits the answer instead, and shows nothing until it
/// lands: the same safe direction, without a first emission that a one-shot
/// reader would keep.

final class CourseEntitlementProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the learner currently holds the course entitlement.
  ///
  /// **The one monetization concept feature code may read.** Gates, locked rows
  /// and lock marks ask this and nothing else; nothing outside this folder
  /// imports the payments service. That is what makes swapping the model — a
  /// subscription arm, a hybrid — a change to how a purchase maps to
  /// entitlement, never a change to an access check.
  ///
  /// Read through the payments abstraction and never from a store SDK, so
  /// flipping to a real store touches no feature code. The active no-op reports
  /// none, which is what ships today: the app is in the free state by
  /// construction, and the entitled path is exercised by overriding this.
  ///
  /// **Unresolved reads as locked.** A caller that draws while the answer is
  /// pending resolves it to `false`, because showing a lock briefly to a paying
  /// learner is recoverable and showing paid content briefly to a free one is
  /// not. A caller that builds one value from it — the Path's modules, the
  /// dictionary's shelf — awaits the answer instead, and shows nothing until it
  /// lands: the same safe direction, without a first emission that a one-shot
  /// reader would keep.
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
