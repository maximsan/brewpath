import 'package:brew_path/core/config/app_links.dart';
import 'package:brew_path/features/profile/domain/support_links.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_links_provider.g.dart';

/// The support mailbox, or null while none exists.
///
/// Behind a provider so a test can set one: the rows that read it only do
/// anything once it is filled in, and that half is the half worth proving.
@riverpod
String? supportMailbox(Ref ref) => SupportLinks.email;

/// The hosted Terms of use, parsed once, or null while unhosted (#448).
@riverpod
Uri? termsPage(Ref ref) => _parsed(SupportLinks.terms);

/// The hosted Privacy policy, parsed once, or null while unhosted (#448).
@riverpod
Uri? privacyPage(Ref ref) => _parsed(SupportLinks.privacy);

/// Where *Rate BrewPath* goes, or null while there is no listing (#532).
@riverpod
Uri? appStoreReview(Ref ref) {
  const id = SupportLinks.appStoreId;
  return id == null ? null : reviewPage(id);
}

Uri? _parsed(String? url) => url == null ? null : Uri.parse(url);
