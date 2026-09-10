// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roasty_studio_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The wardrobe's data: the four banks and the outfit Roasty has on.
///
/// Reads the snapshot rather than `companionOutfit`, deliberately: this is the
/// screen that *edits* the outfit, so it must see what is stored even while
/// the gate would hide it — the door that opens it is already Plus-locked.

@ProviderFor(roastyStudio)
final roastyStudioProvider = RoastyStudioProvider._();

/// The wardrobe's data: the four banks and the outfit Roasty has on.
///
/// Reads the snapshot rather than `companionOutfit`, deliberately: this is the
/// screen that *edits* the outfit, so it must see what is stored even while
/// the gate would hide it — the door that opens it is already Plus-locked.

final class RoastyStudioProvider
    extends
        $FunctionalProvider<
          AsyncValue<RoastyStudio>,
          RoastyStudio,
          FutureOr<RoastyStudio>
        >
    with $FutureModifier<RoastyStudio>, $FutureProvider<RoastyStudio> {
  /// The wardrobe's data: the four banks and the outfit Roasty has on.
  ///
  /// Reads the snapshot rather than `companionOutfit`, deliberately: this is the
  /// screen that *edits* the outfit, so it must see what is stored even while
  /// the gate would hide it — the door that opens it is already Plus-locked.
  RoastyStudioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roastyStudioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roastyStudioHash();

  @$internal
  @override
  $FutureProviderElement<RoastyStudio> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RoastyStudio> create(Ref ref) {
    return roastyStudio(ref);
  }
}

String _$roastyStudioHash() => r'9248a861eb1c8954d67ac7902845654897b5cef5';
