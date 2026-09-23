/// Every word a dictionary search says, in one place.
library;

/// The search's copy, verbatim from the design.
abstract final class DictionarySearchCopy {
  /// The mono count over a search that found something — `1 RESULT`,
  /// `12 RESULTS`; one that found nothing shows the no-matches line alone.
  static String count(int found) =>
      '$found ${found == 1 ? 'RESULT' : 'RESULTS'}';

  /// The line under a search that found nothing, and how it is announced.
  ///
  /// One branch for both, so the announcement cannot drift from the line. An
  /// empty [query] is the category filter having emptied the list rather than
  /// a search: the design draws no state there, so that case keeps the words
  /// the app already had.
  static ({String line, String label}) noMatches(String query) => query.isEmpty
      ? (
          line: 'No terms match that search.',
          label: 'No terms match that search',
        )
      : (
          line:
              'No terms match “$query”. Try a broader word — or '
              'browse by category.',
          label: 'No terms match that search: $query',
        );
}
