/// The addresses Help's two contact rows open.
library;

/// The subject a report carries when the version could not be read.
const String _unknownVersion = 'unknown build';

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
