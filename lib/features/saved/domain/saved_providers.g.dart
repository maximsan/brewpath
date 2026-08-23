// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every key on the Saved shelf, exactly as stored.
///
/// Raw rather than resolved: what a key *points at* needs the content bank,
/// and the two questions have different answers when a saved id no longer
/// exists. The shelf resolves; a bookmark only needs to know whether its own
/// key is in here.

@ProviderFor(savedKeys)
final savedKeysProvider = SavedKeysProvider._();

/// Every key on the Saved shelf, exactly as stored.
///
/// Raw rather than resolved: what a key *points at* needs the content bank,
/// and the two questions have different answers when a saved id no longer
/// exists. The shelf resolves; a bookmark only needs to know whether its own
/// key is in here.

final class SavedKeysProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// Every key on the Saved shelf, exactly as stored.
  ///
  /// Raw rather than resolved: what a key *points at* needs the content bank,
  /// and the two questions have different answers when a saved id no longer
  /// exists. The shelf resolves; a bookmark only needs to know whether its own
  /// key is in here.
  SavedKeysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedKeysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedKeysHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return savedKeys(ref);
  }
}

String _$savedKeysHash() => r'27c7677ffb165fcf9fb9d2e97a834d7628db9197';

/// Whether [key] is on the shelf.

@ProviderFor(isKeySaved)
final isKeySavedProvider = IsKeySavedFamily._();

/// Whether [key] is on the shelf.

final class IsKeySavedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether [key] is on the shelf.
  IsKeySavedProvider._({
    required IsKeySavedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isKeySavedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isKeySavedHash();

  @override
  String toString() {
    return r'isKeySavedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isKeySaved(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsKeySavedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isKeySavedHash() => r'b69dacce9a1363a5dceba3ab58dd734136ecacd5';

/// Whether [key] is on the shelf.

final class IsKeySavedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  IsKeySavedFamily._()
    : super(
        retry: null,
        name: r'isKeySavedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [key] is on the shelf.

  IsKeySavedProvider call(String key) =>
      IsKeySavedProvider._(argument: key, from: this);

  @override
  String toString() => r'isKeySavedProvider';
}

/// The shelf: every saved key resolved against the content, grouped.
///
/// Three banks, one derivation. Guides come from the **earned** shelf rather
/// than the whole bank, so a guide the course has not unlocked cannot be
/// reached from here — the Reference section's rule, honoured once rather than
/// re-invented.

@ProviderFor(savedShelf)
final savedShelfProvider = SavedShelfProvider._();

/// The shelf: every saved key resolved against the content, grouped.
///
/// Three banks, one derivation. Guides come from the **earned** shelf rather
/// than the whole bank, so a guide the course has not unlocked cannot be
/// reached from here — the Reference section's rule, honoured once rather than
/// re-invented.

final class SavedShelfProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavedGroup>>,
          List<SavedGroup>,
          FutureOr<List<SavedGroup>>
        >
    with $FutureModifier<List<SavedGroup>>, $FutureProvider<List<SavedGroup>> {
  /// The shelf: every saved key resolved against the content, grouped.
  ///
  /// Three banks, one derivation. Guides come from the **earned** shelf rather
  /// than the whole bank, so a guide the course has not unlocked cannot be
  /// reached from here — the Reference section's rule, honoured once rather than
  /// re-invented.
  SavedShelfProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedShelfProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedShelfHash();

  @$internal
  @override
  $FutureProviderElement<List<SavedGroup>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SavedGroup>> create(Ref ref) {
    return savedShelf(ref);
  }
}

String _$savedShelfHash() => r'b1b938ee1deaa562d40661b882db4f5b9bd7acf7';

/// How many rows the shelf holds — what the header badge shows.
///
/// Derived from the shelf rather than from the stored keys, so the badge can
/// never promise a row the shelf would skip.

@ProviderFor(savedCount)
final savedCountProvider = SavedCountProvider._();

/// How many rows the shelf holds — what the header badge shows.
///
/// Derived from the shelf rather than from the stored keys, so the badge can
/// never promise a row the shelf would skip.

final class SavedCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// How many rows the shelf holds — what the header badge shows.
  ///
  /// Derived from the shelf rather than from the stored keys, so the badge can
  /// never promise a row the shelf would skip.
  SavedCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return savedCount(ref);
  }
}

String _$savedCountHash() => r'5e0fd6a0ac2733830d4bd46bdeb7c4b735855c01';
