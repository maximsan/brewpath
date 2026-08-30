// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plus_pitch_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The pitch's quantities, read off the shipped banks.
///
/// The joining is here rather than in the sheet so the derivation stays a pure
/// function over three lists — testable against the real content without
/// pumping a widget, which is the only way a wrong count fails fast.

@ProviderFor(plusPitch)
final plusPitchProvider = PlusPitchProvider._();

/// The pitch's quantities, read off the shipped banks.
///
/// The joining is here rather than in the sheet so the derivation stays a pure
/// function over three lists — testable against the real content without
/// pumping a widget, which is the only way a wrong count fails fast.

final class PlusPitchProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlusPitch>,
          PlusPitch,
          FutureOr<PlusPitch>
        >
    with $FutureModifier<PlusPitch>, $FutureProvider<PlusPitch> {
  /// The pitch's quantities, read off the shipped banks.
  ///
  /// The joining is here rather than in the sheet so the derivation stays a pure
  /// function over three lists — testable against the real content without
  /// pumping a widget, which is the only way a wrong count fails fast.
  PlusPitchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plusPitchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plusPitchHash();

  @$internal
  @override
  $FutureProviderElement<PlusPitch> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PlusPitch> create(Ref ref) {
    return plusPitch(ref);
  }
}

String _$plusPitchHash() => r'249a246e9f9d657bd0a315b764b635dd1993a92c';
