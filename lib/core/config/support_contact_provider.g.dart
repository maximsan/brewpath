// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_contact_provider.dart';

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

String _$supportMailboxHash() => r'01c8e0444cdb960d2b693012baa6436bbc50252b';

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

String _$termsPageHash() => r'6dac3eb067aa80962abc31f65d690d197a8551a4';

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

String _$privacyPageHash() => r'2035982590def34d76ad0140ec1422083bb053d1';
