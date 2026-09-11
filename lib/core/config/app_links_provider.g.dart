// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_links_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The support mailbox, or null while none exists.
///
/// Behind a provider so a test can set one: the rows that read it only do
/// anything once it is filled in, and that half is the half worth proving.

@ProviderFor(supportMailbox)
final supportMailboxProvider = SupportMailboxProvider._();

/// The support mailbox, or null while none exists.
///
/// Behind a provider so a test can set one: the rows that read it only do
/// anything once it is filled in, and that half is the half worth proving.

final class SupportMailboxProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The support mailbox, or null while none exists.
  ///
  /// Behind a provider so a test can set one: the rows that read it only do
  /// anything once it is filled in, and that half is the half worth proving.
  SupportMailboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportMailboxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportMailboxHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return supportMailbox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$supportMailboxHash() => r'736a93e0458ae5457b7f72202ab93305359c9e90';

/// The hosted Terms of use, parsed once, or null while unhosted (#448).

@ProviderFor(termsPage)
final termsPageProvider = TermsPageProvider._();

/// The hosted Terms of use, parsed once, or null while unhosted (#448).

final class TermsPageProvider extends $FunctionalProvider<Uri?, Uri?, Uri?>
    with $Provider<Uri?> {
  /// The hosted Terms of use, parsed once, or null while unhosted (#448).
  TermsPageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'termsPageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$termsPageHash();

  @$internal
  @override
  $ProviderElement<Uri?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Uri? create(Ref ref) {
    return termsPage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uri? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uri?>(value),
    );
  }
}

String _$termsPageHash() => r'f783d96bd79a3661b80de15a2aea474d61dd944a';

/// The hosted Privacy policy, parsed once, or null while unhosted (#448).

@ProviderFor(privacyPage)
final privacyPageProvider = PrivacyPageProvider._();

/// The hosted Privacy policy, parsed once, or null while unhosted (#448).

final class PrivacyPageProvider extends $FunctionalProvider<Uri?, Uri?, Uri?>
    with $Provider<Uri?> {
  /// The hosted Privacy policy, parsed once, or null while unhosted (#448).
  PrivacyPageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'privacyPageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$privacyPageHash();

  @$internal
  @override
  $ProviderElement<Uri?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Uri? create(Ref ref) {
    return privacyPage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uri? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uri?>(value),
    );
  }
}

String _$privacyPageHash() => r'a31844839370a344477826d0b2806a0c5e86ff52';
