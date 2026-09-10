/// Opens an address outside the app — a web page, or a mail composer.
///
/// The one seam in front of `url_launcher`: rows hand it a [Uri], tests hand
/// it a recorder, and no widget touches the plugin.
// One member by design — the seam exists to be faked and swapped.
// ignore: one_member_abstracts
abstract interface class LinkOpener {
  /// Hands [target] to the platform, and reports whether it took it.
  ///
  /// A false is a real outcome, not an error: a device with no mail account
  /// refuses `mailto:`, and the caller says so rather than throwing.
  Future<bool> open(Uri target);
}

/// An opener that opens nothing, and says so — tests and inactive contexts.
class NoOpLinkOpener implements LinkOpener {
  /// Creates a [NoOpLinkOpener].
  const NoOpLinkOpener();

  @override
  Future<bool> open(Uri target) async => false;
}
