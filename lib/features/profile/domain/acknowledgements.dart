import 'package:brew_path/shared/models/content/dictionary_term.dart';

/// Every distinct work the dictionary's terms cite, in one alphabetical list.
///
/// Derived from the same bank the term pages read, so a source added to a term
/// appears here with nothing else to author. A work is its address where it
/// has one, so two terms citing one page credit it once even where they label
/// it differently; a work with no address is its label.
List<DictionarySource> acknowledgedSources(List<DictionaryTerm> terms) {
  final byWork = <String, DictionarySource>{};

  for (final term in terms) {
    for (final source in term.sources) {
      final key = source.url ?? source.label;
      final held = byWork[key];
      // The shorter label is the work's name: where two differ on one
      // address, the longer carries a gloss about why that term cites it.
      if (held == null || source.label.length < held.label.length) {
        byWork[key] = source;
      }
    }
  }

  // Alphabetical, not bank order: a credits list is read by looking for a
  // name, and bank order would reshuffle it whenever a term moved.
  return byWork.values.toList()..sort(
    (first, second) =>
        first.label.toLowerCase().compareTo(second.label.toLowerCase()),
  );
}
