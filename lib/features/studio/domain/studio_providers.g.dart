// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'studio_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The chooser's data: both banks and the planted grove.

@ProviderFor(studioGrove)
final studioGroveProvider = StudioGroveProvider._();

/// The chooser's data: both banks and the planted grove.

final class StudioGroveProvider
    extends
        $FunctionalProvider<
          AsyncValue<StudioGrove>,
          StudioGrove,
          FutureOr<StudioGrove>
        >
    with $FutureModifier<StudioGrove>, $FutureProvider<StudioGrove> {
  /// The chooser's data: both banks and the planted grove.
  StudioGroveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studioGroveProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studioGroveHash();

  @$internal
  @override
  $FutureProviderElement<StudioGrove> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StudioGrove> create(Ref ref) {
    return studioGrove(ref);
  }
}

String _$studioGroveHash() => r'17e38b4f56f8213269ccaa1496ac82dcdeafcccf';
