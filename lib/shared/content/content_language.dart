/// Which language the course is read in, and where that language's files are.
///
/// A language is a folder (ADR-0008): the extractor's English output is the
/// master, and every other language is a folder laid over it entry by entry.
library;

import 'package:flutter/foundation.dart' show immutable;

/// A language the course can be read in.
///
/// A value rather than an enum, because ADR-0008 makes adding a language a
/// matter of adding its folder — so the set of them is data, and nothing
/// branches on which one is in hand.
@immutable
class ContentLanguage {
  /// Creates a [ContentLanguage].
  const ContentLanguage({required this.code, required this.speechTag});

  /// The master. Its text is the extractor's own output, with no folder over
  /// it, and it is what every other language falls back to.
  static const ContentLanguage english = ContentLanguage(
    code: 'en',
    speechTag: 'en-US',
  );

  /// The folder name under `assets/content/l10n/`.
  final String code;

  /// The tag handed to the platform's synthesizer (ADR-0012).
  final String speechTag;

  /// Whether this is the master the banks are written in.
  bool get isMaster => code == english.code;
}

/// The language this build reads.
///
/// A constant rather than a setting: English ships alone, and how a reader
/// picks a language is still open on the localization map. Everything below
/// already works for a second folder, so that choice is the remaining step.
const ContentLanguage activeContentLanguage = ContentLanguage.english;

/// Where the extractor writes [bank] — the English master.
String masterBankPath(String bank) => 'assets/content/generated/$bank.json';

/// Where [language] keeps its copy of [bank], or null when it is the master.
///
/// A new folder needs its own `assets:` line in `pubspec.yaml`: a directory
/// entry bundles its own files only, not its subdirectories', so an unlisted
/// folder reads as a missing asset rather than a missing translation.
String? translatedBankPath(String bank, ContentLanguage language) =>
    language.isMaster
    ? null
    : 'assets/content/l10n/${language.code}/$bank.json';
