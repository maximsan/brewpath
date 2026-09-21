import 'package:brew_path/shared/models/content/dictionary_term.dart';

/// Every distinct work the dictionary's terms cite, in one alphabetical list.
///
/// Derived from the same bank the term pages read, so a source added to a term
/// appears here with nothing else to author. Two terms citing one work name it
/// once; a label carrying a second address stays two entries, because a work
/// and where to read it are what a citation is.
List<DictionarySource> acknowledgedSources(List<DictionaryTerm> terms) {
  final seen = <(String, String?)>{};
  final sources = <DictionarySource>[];

  for (final term in terms) {
    for (final source in term.sources) {
      if (seen.add((source.label, source.url))) sources.add(source);
    }
  }

  // Alphabetical, not bank order: a credits list is read by looking for a
  // name, and bank order would reshuffle it whenever a term moved.
  sources.sort(
    (first, second) =>
        first.label.toLowerCase().compareTo(second.label.toLowerCase()),
  );
  return sources;
}
