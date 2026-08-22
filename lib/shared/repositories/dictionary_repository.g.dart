// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app-wide [DictionaryRepository].

@ProviderFor(dictionaryRepository)
final dictionaryRepositoryProvider = DictionaryRepositoryProvider._();

/// The app-wide [DictionaryRepository].

final class DictionaryRepositoryProvider
    extends
        $FunctionalProvider<
          DictionaryRepository,
          DictionaryRepository,
          DictionaryRepository
        >
    with $Provider<DictionaryRepository> {
  /// The app-wide [DictionaryRepository].
  DictionaryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dictionaryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dictionaryRepositoryHash();

  @$internal
  @override
  $ProviderElement<DictionaryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DictionaryRepository create(Ref ref) {
    return dictionaryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DictionaryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DictionaryRepository>(value),
    );
  }
}

String _$dictionaryRepositoryHash() =>
    r'643bf4ec36a76d6117e574db2c39b36b14f86ce4';
