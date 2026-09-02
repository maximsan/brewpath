/// The app's **public** web addresses — what a shared link says.
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
  /// Singular, and **not** a route the app registers: a card is read as a
  /// sheet over the collection, so the redirect forwards this to `/cards/<id>`
  /// rather than giving a card a second home. The AASA file claims `/card/*`,
  /// and `*` matches across slashes, so anything under this prefix opens the
  /// app and has to land somewhere sane.
  static const cardPrefix = '/card';
}
