/// The addresses the rows that leave the app open — Help's two contact rows,
/// and About's *Say hello* and *Rate BrewPath*.
library;

/// The subject a report carries when the version could not be read.
const String _unknownVersion = 'unknown build';

/// The App Store listing for [appStoreId], opened on its review sheet.
///
/// `action=write-review` is what takes the learner straight to writing one
/// rather than to the listing they would then have to scroll.
Uri reviewPage(String appStoreId) => Uri.https(
  'apps.apple.com',
  '/app/id$appStoreId',
  const {'action': 'write-review'},
);

/// A composer addressed to [email], with nothing filled in.
///
/// Built through [Uri] rather than by joining strings, so an address needing
/// escaping cannot produce a link the mail app refuses.
Uri supportMailto(String email) => Uri(scheme: 'mailto', path: email);

/// A composer addressed to [email], its subject naming [version].
///
/// The build is in the subject so a report can be matched to what shipped —
/// the one thing a learner cannot be asked to look up.
Uri problemReportMailto(String email, String? version) => Uri(
  scheme: 'mailto',
  path: email,
  queryParameters: {
    'subject': 'BrewPath problem report (${version ?? _unknownVersion})',
  },
);
