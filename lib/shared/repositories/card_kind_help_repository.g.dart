// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_kind_help_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app-wide [CardKindHelpRepository].

@ProviderFor(cardKindHelpRepository)
final cardKindHelpRepositoryProvider = CardKindHelpRepositoryProvider._();

/// The app-wide [CardKindHelpRepository].

final class CardKindHelpRepositoryProvider
    extends
        $FunctionalProvider<
          CardKindHelpRepository,
          CardKindHelpRepository,
          CardKindHelpRepository
        >
    with $Provider<CardKindHelpRepository> {
  /// The app-wide [CardKindHelpRepository].
  CardKindHelpRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardKindHelpRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardKindHelpRepositoryHash();

  @$internal
  @override
  $ProviderElement<CardKindHelpRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CardKindHelpRepository create(Ref ref) {
    return cardKindHelpRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardKindHelpRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardKindHelpRepository>(value),
    );
  }
}

String _$cardKindHelpRepositoryHash() =>
    r'c4bce102003cfb8155ade2300d1f4ce0b4e2969c';
