// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the dictionary and the learner's completed lessons together.

@ProviderFor(dictionaryView)
final dictionaryViewProvider = DictionaryViewProvider._();

/// Loads the dictionary and the learner's completed lessons together.

final class DictionaryViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<DictionaryView>,
          DictionaryView,
          FutureOr<DictionaryView>
        >
    with $FutureModifier<DictionaryView>, $FutureProvider<DictionaryView> {
  /// Loads the dictionary and the learner's completed lessons together.
  DictionaryViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dictionaryViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dictionaryViewHash();

  @$internal
  @override
  $FutureProviderElement<DictionaryView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DictionaryView> create(Ref ref) {
    return dictionaryView(ref);
  }
}

String _$dictionaryViewHash() => r'325ec489594e01ac4bdcd896411b91bc9a333cfa';
