// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_link.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the app-lifetime [PendingLink].
///
/// Function-style despite holding mutable state, because the mutation is the
/// object's own and must not rebuild the router — see [PendingLink].

@ProviderFor(pendingLink)
final pendingLinkProvider = PendingLinkProvider._();

/// Provides the app-lifetime [PendingLink].
///
/// Function-style despite holding mutable state, because the mutation is the
/// object's own and must not rebuild the router — see [PendingLink].

final class PendingLinkProvider
    extends $FunctionalProvider<PendingLink, PendingLink, PendingLink>
    with $Provider<PendingLink> {
  /// Provides the app-lifetime [PendingLink].
  ///
  /// Function-style despite holding mutable state, because the mutation is the
  /// object's own and must not rebuild the router — see [PendingLink].
  PendingLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingLinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingLinkHash();

  @$internal
  @override
  $ProviderElement<PendingLink> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PendingLink create(Ref ref) {
    return pendingLink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingLink value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingLink>(value),
    );
  }
}

String _$pendingLinkHash() => r'f3329156add24cdfecae0247dcdc3806fc4daa4a';
