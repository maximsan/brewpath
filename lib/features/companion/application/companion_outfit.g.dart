// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companion_outfit.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What every Roasty in the app draws itself in.
///
/// **Hidden, not wiped.** A free learner reads the plain bean while the
/// snapshot keeps whatever they once picked, so a lapsed entitlement hides the
/// wardrobe and a returning one brings it back. Awaited rather than read as an
/// `AsyncValue`, so this emits once (#89's rule for value providers).

@ProviderFor(companionOutfit)
final companionOutfitProvider = CompanionOutfitProvider._();

/// What every Roasty in the app draws itself in.
///
/// **Hidden, not wiped.** A free learner reads the plain bean while the
/// snapshot keeps whatever they once picked, so a lapsed entitlement hides the
/// wardrobe and a returning one brings it back. Awaited rather than read as an
/// `AsyncValue`, so this emits once (#89's rule for value providers).

final class CompanionOutfitProvider
    extends
        $FunctionalProvider<
          AsyncValue<CompanionConfig>,
          CompanionConfig,
          FutureOr<CompanionConfig>
        >
    with $FutureModifier<CompanionConfig>, $FutureProvider<CompanionConfig> {
  /// What every Roasty in the app draws itself in.
  ///
  /// **Hidden, not wiped.** A free learner reads the plain bean while the
  /// snapshot keeps whatever they once picked, so a lapsed entitlement hides the
  /// wardrobe and a returning one brings it back. Awaited rather than read as an
  /// `AsyncValue`, so this emits once (#89's rule for value providers).
  CompanionOutfitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'companionOutfitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$companionOutfitHash();

  @$internal
  @override
  $FutureProviderElement<CompanionConfig> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CompanionConfig> create(Ref ref) {
    return companionOutfit(ref);
  }
}

String _$companionOutfitHash() => r'c3cc8fcea52c0e5b5c037a3732e98e677506aaea';
