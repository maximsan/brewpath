// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocab_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every term the learner has answered, with the stamps that decide whether
/// it is still owed a review.
///
/// A provider of its own rather than a read inside [vocabPools], for the
/// reason [savedKeysProvider] is one: it is the seam a drill invalidates after
/// logging an answer, and reading the snapshot inline would leave a second
/// future in flight that nothing awaits when an earlier one fails.

@ProviderFor(vocabAnswers)
final vocabAnswersProvider = VocabAnswersProvider._();

/// Every term the learner has answered, with the stamps that decide whether
/// it is still owed a review.
///
/// A provider of its own rather than a read inside [vocabPools], for the
/// reason [savedKeysProvider] is one: it is the seam a drill invalidates after
/// logging an answer, and reading the snapshot inline would leave a second
/// future in flight that nothing awaits when an earlier one fails.

final class VocabAnswersProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, TermMiss>>,
          Map<String, TermMiss>,
          FutureOr<Map<String, TermMiss>>
        >
    with
        $FutureModifier<Map<String, TermMiss>>,
        $FutureProvider<Map<String, TermMiss>> {
  /// Every term the learner has answered, with the stamps that decide whether
  /// it is still owed a review.
  ///
  /// A provider of its own rather than a read inside [vocabPools], for the
  /// reason [savedKeysProvider] is one: it is the seam a drill invalidates after
  /// logging an answer, and reading the snapshot inline would leave a second
  /// future in flight that nothing awaits when an earlier one fails.
  VocabAnswersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vocabAnswersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vocabAnswersHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, TermMiss>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, TermMiss>> create(Ref ref) {
    return vocabAnswers(ref);
  }
}

String _$vocabAnswersHash() => r'66c326d3dc5928c2dbe0530c7b03000618ef3f47';

/// The learner's drill pools, tier-scoped.
///
/// **Unresolved entitlement reads as free**, the direction every other gate in
/// the app resolves it: showing a free learner the whole glossary for a frame
/// is the leak, and showing a paying learner a small pool for a frame is a
/// rebuild away from being right.

@ProviderFor(vocabPools)
final vocabPoolsProvider = VocabPoolsProvider._();

/// The learner's drill pools, tier-scoped.
///
/// **Unresolved entitlement reads as free**, the direction every other gate in
/// the app resolves it: showing a free learner the whole glossary for a frame
/// is the leak, and showing a paying learner a small pool for a frame is a
/// rebuild away from being right.

final class VocabPoolsProvider
    extends
        $FunctionalProvider<
          AsyncValue<VocabPools>,
          VocabPools,
          FutureOr<VocabPools>
        >
    with $FutureModifier<VocabPools>, $FutureProvider<VocabPools> {
  /// The learner's drill pools, tier-scoped.
  ///
  /// **Unresolved entitlement reads as free**, the direction every other gate in
  /// the app resolves it: showing a free learner the whole glossary for a frame
  /// is the leak, and showing a paying learner a small pool for a frame is a
  /// rebuild away from being right.
  VocabPoolsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vocabPoolsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vocabPoolsHash();

  @$internal
  @override
  $FutureProviderElement<VocabPools> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<VocabPools> create(Ref ref) {
    return vocabPools(ref);
  }
}

String _$vocabPoolsHash() => r'89835a6d4847463a5c3fe614f96b60e3d5b33799';
