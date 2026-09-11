// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foundations_faq_tail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How the Foundations answer closes, in the arm's own words.
///
/// Resolved here rather than in Help so the FAQ is handed a sentence and never
/// learns which arm sold the purchase — the seam #176 exists to hold.

@ProviderFor(foundationsFaqTail)
final foundationsFaqTailProvider = FoundationsFaqTailProvider._();

/// How the Foundations answer closes, in the arm's own words.
///
/// Resolved here rather than in Help so the FAQ is handed a sentence and never
/// learns which arm sold the purchase — the seam #176 exists to hold.

final class FoundationsFaqTailProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// How the Foundations answer closes, in the arm's own words.
  ///
  /// Resolved here rather than in Help so the FAQ is handed a sentence and never
  /// learns which arm sold the purchase — the seam #176 exists to hold.
  FoundationsFaqTailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foundationsFaqTailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foundationsFaqTailHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return foundationsFaqTail(ref);
  }
}

String _$foundationsFaqTailHash() =>
    r'f6929d221be1f6e3eb327f2e112d7a9ede08f0d7';
