// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the active [SharePresenter] — the platform share sheet.

@ProviderFor(sharePresenter)
final sharePresenterProvider = SharePresenterProvider._();

/// Provides the active [SharePresenter] — the platform share sheet.

final class SharePresenterProvider
    extends $FunctionalProvider<SharePresenter, SharePresenter, SharePresenter>
    with $Provider<SharePresenter> {
  /// Provides the active [SharePresenter] — the platform share sheet.
  SharePresenterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharePresenterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharePresenterHash();

  @$internal
  @override
  $ProviderElement<SharePresenter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SharePresenter create(Ref ref) {
    return sharePresenter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharePresenter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharePresenter>(value),
    );
  }
}

String _$sharePresenterHash() => r'bb4e43a50cb3b9421e889429308c8115e43fbfd7';
