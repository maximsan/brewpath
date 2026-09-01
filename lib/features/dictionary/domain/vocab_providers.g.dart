// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocab_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

String _$vocabPoolsHash() => r'8bbc8880f61c757ed37209f61db689633e04ab5d';
