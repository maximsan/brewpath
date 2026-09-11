/// Every web address and mailbox the app points at, in two groups.
///
/// [AppLinks] is what the app **owns** — always set, and claimed on the web,
/// so changing one is a server change too. [SupportLinks] is what someone
/// must **create first** — null until it exists, and a row pointing at one is
/// absent while it is null, never drawn live and inert.
library;

/// The app's own public addresses, which always exist.
///
/// A dedicated subdomain, never the root of `maximsan.dev`: a universal-link
/// claim on the root would open this app for every link to the owner's own
/// site. Ruled by #34's amendment; the file that vouches for these lives at
/// `docs/19-universal-links-setup.md`.
abstract final class AppLinks {
  /// The marketing entry, and what a shared streak card points at.
  static const site = 'https://brewpath.maximsan.dev';

  /// What a shared collectible's address starts with, after the host.
  ///
  /// Singular, and **not** a route the app registers: the redirect forwards
  /// this to `/cards/<id>`. The AASA file claims `/card/*`, and `*` matches
  /// across slashes, so anything under this prefix opens the app and has to
  /// land somewhere sane.
  static const cardPrefix = '/card';
}

/// Where a learner is sent to reach a human or read the fine print.
///
/// **Fill these in and they go live everywhere at once** — the paywall, the
/// gate sheet, Help and About all read them through one provider each. They
/// are compile-time, so setting one ships in the next build; that is what
/// makes the null state unrepresentable at runtime.
abstract final class SupportLinks {
  /// The mailbox a learner writes to, or null while none exists (#531).
  ///
  /// Read by Help's *Email support* and *Report a problem*, and by About's
  /// *Say hello* once #532 builds that row.
  static const String? email = null;

  /// The hosted Terms of use, or null while the page does not exist (#448).
  static const String? terms = null;

  /// The hosted Privacy policy, or null while the page does not exist (#448).
  static const String? privacy = null;
}
