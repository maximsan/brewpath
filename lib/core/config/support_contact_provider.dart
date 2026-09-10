import 'package:brew_path/core/config/support_contact.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'support_contact_provider.g.dart';

/// The support mailbox, or null while none exists.
///
/// Behind a provider so a test can set one: the rows that read it only do
/// anything once it is filled in, and that half is the half worth proving.
@riverpod
String? supportMailbox(Ref ref) => supportEmail;

/// The hosted Terms of use, parsed once, or null while unhosted (#448).
@riverpod
Uri? termsPage(Ref ref) => _parsed(termsUrl);

/// The hosted Privacy policy, parsed once, or null while unhosted (#448).
@riverpod
Uri? privacyPage(Ref ref) => _parsed(privacyUrl);

Uri? _parsed(String? url) => url == null ? null : Uri.parse(url);
