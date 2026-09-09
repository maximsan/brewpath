// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plus_offering_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The arm this learner is on, read through the payments seam.
///
/// Kept alive so the arm is asked for once and cannot change under a learner
/// mid-session; only the paywall may read it (#176).

@ProviderFor(plusOffering)
final plusOfferingProvider = PlusOfferingProvider._();

/// The arm this learner is on, read through the payments seam.
///
/// Kept alive so the arm is asked for once and cannot change under a learner
/// mid-session; only the paywall may read it (#176).

final class PlusOfferingProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlusOffering>,
          PlusOffering,
          FutureOr<PlusOffering>
        >
    with $FutureModifier<PlusOffering>, $FutureProvider<PlusOffering> {
  /// The arm this learner is on, read through the payments seam.
  ///
  /// Kept alive so the arm is asked for once and cannot change under a learner
  /// mid-session; only the paywall may read it (#176).
  PlusOfferingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plusOfferingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plusOfferingHash();

  @$internal
  @override
  $FutureProviderElement<PlusOffering> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlusOffering> create(Ref ref) {
    return plusOffering(ref);
  }
}

String _$plusOfferingHash() => r'aa478f724709500b4b0580eee14ff48d36006ddc';
