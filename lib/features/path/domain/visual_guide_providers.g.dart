// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_guide_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Reference section's contents for this learner.
///
/// It watches completed lessons, so finishing the lesson that teaches a guide
/// fills the section in while the learner is still holding the phone — the
/// reward lands without a restart, and a reset locks it again for free.

@ProviderFor(visualGuideShelfFor)
final visualGuideShelfForProvider = VisualGuideShelfForProvider._();

/// The Reference section's contents for this learner.
///
/// It watches completed lessons, so finishing the lesson that teaches a guide
/// fills the section in while the learner is still holding the phone — the
/// reward lands without a restart, and a reset locks it again for free.

final class VisualGuideShelfForProvider
    extends
        $FunctionalProvider<
          AsyncValue<VisualGuideShelf>,
          VisualGuideShelf,
          FutureOr<VisualGuideShelf>
        >
    with $FutureModifier<VisualGuideShelf>, $FutureProvider<VisualGuideShelf> {
  /// The Reference section's contents for this learner.
  ///
  /// It watches completed lessons, so finishing the lesson that teaches a guide
  /// fills the section in while the learner is still holding the phone — the
  /// reward lands without a restart, and a reset locks it again for free.
  VisualGuideShelfForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visualGuideShelfForProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visualGuideShelfForHash();

  @$internal
  @override
  $FutureProviderElement<VisualGuideShelf> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VisualGuideShelf> create(Ref ref) {
    return visualGuideShelfFor(ref);
  }
}

String _$visualGuideShelfForHash() =>
    r'2dee6d1e6042e6099b48be5cefff18d269bbea2d';

/// The lesson the Reference heading names as opening the next guide.
///
/// Its own provider, not a field on the shelf: only this heading needs the
/// whole course in order, and the shelf is also read by lesson cards and the
/// bookmark button, which should not load the banks to ask about one guide.
///
/// Every `watch` runs before the first `await`. Reading a `Ref` after an async
/// gap throws if the provider was disposed in the meantime.

@ProviderFor(nextGuideUnlock)
final nextGuideUnlockProvider = NextGuideUnlockProvider._();

/// The lesson the Reference heading names as opening the next guide.
///
/// Its own provider, not a field on the shelf: only this heading needs the
/// whole course in order, and the shelf is also read by lesson cards and the
/// bookmark button, which should not load the banks to ask about one guide.
///
/// Every `watch` runs before the first `await`. Reading a `Ref` after an async
/// gap throws if the provider was disposed in the meantime.

final class NextGuideUnlockProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The lesson the Reference heading names as opening the next guide.
  ///
  /// Its own provider, not a field on the shelf: only this heading needs the
  /// whole course in order, and the shelf is also read by lesson cards and the
  /// bookmark button, which should not load the banks to ask about one guide.
  ///
  /// Every `watch` runs before the first `await`. Reading a `Ref` after an async
  /// gap throws if the provider was disposed in the meantime.
  NextGuideUnlockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextGuideUnlockProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextGuideUnlockHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return nextGuideUnlock(ref);
  }
}

String _$nextGuideUnlockHash() => r'e04b1cbddbf9cce92bc9ed5b818dc9682d4b44cf';

/// Whether the Reference shelf is locked by the purchase rather than by
/// progress. The two need different words; `LockedRowCopy` has them.

@ProviderFor(referenceLockedByPurchase)
final referenceLockedByPurchaseProvider = ReferenceLockedByPurchaseProvider._();

/// Whether the Reference shelf is locked by the purchase rather than by
/// progress. The two need different words; `LockedRowCopy` has them.

final class ReferenceLockedByPurchaseProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the Reference shelf is locked by the purchase rather than by
  /// progress. The two need different words; `LockedRowCopy` has them.
  ReferenceLockedByPurchaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'referenceLockedByPurchaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$referenceLockedByPurchaseHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return referenceLockedByPurchase(ref);
  }
}

String _$referenceLockedByPurchaseHash() =>
    r'0135e42df79a28b9cde7c723090502400179da54';

/// The earned guide covering [subject], or null when none is earned.
///
/// Lives here rather than at the call site so nothing outside this feature has
/// to know that a guide is found by subject, or that only earned ones count.

@ProviderFor(earnedGuideFor)
final earnedGuideForProvider = EarnedGuideForFamily._();

/// The earned guide covering [subject], or null when none is earned.
///
/// Lives here rather than at the call site so nothing outside this feature has
/// to know that a guide is found by subject, or that only earned ones count.

final class EarnedGuideForProvider
    extends
        $FunctionalProvider<
          AsyncValue<VisualGuide?>,
          VisualGuide?,
          FutureOr<VisualGuide?>
        >
    with $FutureModifier<VisualGuide?>, $FutureProvider<VisualGuide?> {
  /// The earned guide covering [subject], or null when none is earned.
  ///
  /// Lives here rather than at the call site so nothing outside this feature has
  /// to know that a guide is found by subject, or that only earned ones count.
  EarnedGuideForProvider._({
    required EarnedGuideForFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'earnedGuideForProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$earnedGuideForHash();

  @override
  String toString() {
    return r'earnedGuideForProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<VisualGuide?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VisualGuide?> create(Ref ref) {
    final argument = this.argument as String;
    return earnedGuideFor(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EarnedGuideForProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$earnedGuideForHash() => r'0edca9429cc1ede906a7003233954525ee5ffaf1';

/// The earned guide covering [subject], or null when none is earned.
///
/// Lives here rather than at the call site so nothing outside this feature has
/// to know that a guide is found by subject, or that only earned ones count.

final class EarnedGuideForFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VisualGuide?>, String> {
  EarnedGuideForFamily._()
    : super(
        retry: null,
        name: r'earnedGuideForProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The earned guide covering [subject], or null when none is earned.
  ///
  /// Lives here rather than at the call site so nothing outside this feature has
  /// to know that a guide is found by subject, or that only earned ones count.

  EarnedGuideForProvider call(String subject) =>
      EarnedGuideForProvider._(argument: subject, from: this);

  @override
  String toString() => r'earnedGuideForProvider';
}
