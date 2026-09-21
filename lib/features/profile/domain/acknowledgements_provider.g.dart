// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acknowledgements_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The works the Acknowledgements page lists.
///
/// Read off the whole bank rather than `dictionaryView`, which narrows terms
/// to the learner's tier: credit is owed for every entry that ships, and a
/// free learner seeing a shorter list would be crediting fewer works.

@ProviderFor(acknowledgements)
final acknowledgementsProvider = AcknowledgementsProvider._();

/// The works the Acknowledgements page lists.
///
/// Read off the whole bank rather than `dictionaryView`, which narrows terms
/// to the learner's tier: credit is owed for every entry that ships, and a
/// free learner seeing a shorter list would be crediting fewer works.

final class AcknowledgementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DictionarySource>>,
          List<DictionarySource>,
          FutureOr<List<DictionarySource>>
        >
    with
        $FutureModifier<List<DictionarySource>>,
        $FutureProvider<List<DictionarySource>> {
  /// The works the Acknowledgements page lists.
  ///
  /// Read off the whole bank rather than `dictionaryView`, which narrows terms
  /// to the learner's tier: credit is owed for every entry that ships, and a
  /// free learner seeing a shorter list would be crediting fewer works.
  AcknowledgementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'acknowledgementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$acknowledgementsHash();

  @$internal
  @override
  $FutureProviderElement<List<DictionarySource>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DictionarySource>> create(Ref ref) {
    return acknowledgements(ref);
  }
}

String _$acknowledgementsHash() => r'fec27ebcc6adf1161c49fe946ff7c823dee27532';
