// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteConfigService)
final remoteConfigServiceProvider = RemoteConfigServiceProvider._();

final class RemoteConfigServiceProvider
    extends
        $FunctionalProvider<
          RemoteConfigService,
          RemoteConfigService,
          RemoteConfigService
        >
    with $Provider<RemoteConfigService> {
  RemoteConfigServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteConfigServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteConfigServiceHash();

  @$internal
  @override
  $ProviderElement<RemoteConfigService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteConfigService create(Ref ref) {
    return remoteConfigService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteConfigService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteConfigService>(value),
    );
  }
}

String _$remoteConfigServiceHash() =>
    r'7dd10f3f257ec9796ef40040394fa8e0ab6eb93d';
