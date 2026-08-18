// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mini_game_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The mini-game catalog, in the order the extracted bank lists it.

@ProviderFor(miniGameFormats)
final miniGameFormatsProvider = MiniGameFormatsProvider._();

/// The mini-game catalog, in the order the extracted bank lists it.

final class MiniGameFormatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MiniGameFormat>>,
          List<MiniGameFormat>,
          FutureOr<List<MiniGameFormat>>
        >
    with
        $FutureModifier<List<MiniGameFormat>>,
        $FutureProvider<List<MiniGameFormat>> {
  /// The mini-game catalog, in the order the extracted bank lists it.
  MiniGameFormatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'miniGameFormatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$miniGameFormatsHash();

  @$internal
  @override
  $FutureProviderElement<List<MiniGameFormat>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MiniGameFormat>> create(Ref ref) {
    return miniGameFormats(ref);
  }
}

String _$miniGameFormatsHash() => r'48d2d9e1ee29a45772d6a98f420ccca1b1941630';

/// One format by id, or null when the catalog has no such entry.

@ProviderFor(miniGameFormat)
final miniGameFormatProvider = MiniGameFormatFamily._();

/// One format by id, or null when the catalog has no such entry.

final class MiniGameFormatProvider
    extends
        $FunctionalProvider<
          AsyncValue<MiniGameFormat?>,
          MiniGameFormat?,
          FutureOr<MiniGameFormat?>
        >
    with $FutureModifier<MiniGameFormat?>, $FutureProvider<MiniGameFormat?> {
  /// One format by id, or null when the catalog has no such entry.
  MiniGameFormatProvider._({
    required MiniGameFormatFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'miniGameFormatProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$miniGameFormatHash();

  @override
  String toString() {
    return r'miniGameFormatProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MiniGameFormat?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MiniGameFormat?> create(Ref ref) {
    final argument = this.argument as String;
    return miniGameFormat(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MiniGameFormatProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$miniGameFormatHash() => r'b68b1829e05281624ec09c8c69ccacb7ba53e7cd';

/// One format by id, or null when the catalog has no such entry.

final class MiniGameFormatFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MiniGameFormat?>, String> {
  MiniGameFormatFamily._()
    : super(
        retry: null,
        name: r'miniGameFormatProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One format by id, or null when the catalog has no such entry.

  MiniGameFormatProvider call(String formatId) =>
      MiniGameFormatProvider._(argument: formatId, from: this);

  @override
  String toString() => r'miniGameFormatProvider';
}

/// The rounds authored for one format.

@ProviderFor(miniGameRounds)
final miniGameRoundsProvider = MiniGameRoundsFamily._();

/// The rounds authored for one format.

final class MiniGameRoundsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ContentCard>>,
          List<ContentCard>,
          FutureOr<List<ContentCard>>
        >
    with
        $FutureModifier<List<ContentCard>>,
        $FutureProvider<List<ContentCard>> {
  /// The rounds authored for one format.
  MiniGameRoundsProvider._({
    required MiniGameRoundsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'miniGameRoundsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$miniGameRoundsHash();

  @override
  String toString() {
    return r'miniGameRoundsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ContentCard>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ContentCard>> create(Ref ref) {
    final argument = this.argument as String;
    return miniGameRounds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MiniGameRoundsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$miniGameRoundsHash() => r'31c822686d2ce926f47a4167c2ed3dc1da8f65d9';

/// The rounds authored for one format.

final class MiniGameRoundsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ContentCard>>, String> {
  MiniGameRoundsFamily._()
    : super(
        retry: null,
        name: r'miniGameRoundsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The rounds authored for one format.

  MiniGameRoundsProvider call(String formatId) =>
      MiniGameRoundsProvider._(argument: formatId, from: this);

  @override
  String toString() => r'miniGameRoundsProvider';
}
