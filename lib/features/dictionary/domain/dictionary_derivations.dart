import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';

/// Everything the dictionary decides, as pure functions over content plus the
/// learner's completed lessons.
///
/// The screens read these and render; they do not restate the rules. Keeping
/// them here means search, filtering, counting and status are testable without
/// pumping a widget or opening a database.

/// What the course promises about a term, for this learner, right now.
///
/// Three values, and the third is the one that matters: *dashed means "not
/// yet"; the dash means "not on the path at all"*. Showing [toLearn] for a
/// term no lesson teaches is a promise the course cannot keep.
enum DictionaryStatus {
  /// The lesson that teaches it is complete.
  learned,

  /// A lesson teaches it, and the learner has not finished that lesson.
  toLearn,

  /// No lesson teaches it. It is here for a bag or a menu.
  reference,
}

/// Which terms the home screen is showing.
enum DictionaryFilter {
  /// Every term, reference included.
  all,

  /// Only terms whose teaching lesson is complete.
  learned,

  /// Only terms still ahead on the path — never reference terms.
  toLearn,
}

/// Resolves [term]'s status against the lessons this learner has completed.
///
/// The whole rule: no lesson pointer means [DictionaryStatus.reference]; a
/// pointer into [completedLessonIds] means [DictionaryStatus.learned];
/// anything else is still ahead. Derived on every read rather than stored, so
/// there is one source of truth about what a learner knows.
DictionaryStatus dictionaryStatusOf(
  DictionaryTerm term,
  Set<String> completedLessonIds,
) {
  final lessonId = term.lessonId;
  if (lessonId == null) return DictionaryStatus.reference;
  return completedLessonIds.contains(lessonId)
      ? DictionaryStatus.learned
      : DictionaryStatus.toLearn;
}

/// The terms matching [query] by name, alias, or the label of the category
/// they sit in.
///
/// Matching is case- and diacritic-insensitive in both directions, so "geisha"
/// finds *Gesha* and "crème" finds *Creme*. A blank query is not a filter — it
/// returns [terms] untouched. Pass [categories] to let a category label match
/// its terms; without it, only names and aliases are searched.
List<DictionaryTerm> searchDictionary(
  List<DictionaryTerm> terms,
  String query, {
  List<DictionaryCategory> categories = const [],
}) {
  final needle = _fold(query);
  if (needle.isEmpty) return terms;

  final labelById = {
    for (final category in categories) category.id: category.label,
  };
  return terms
      .where((term) => _matches(term, needle, labelById[term.categoryId]))
      .toList();
}

/// Whether any of [term]'s searchable text contains [needle], already folded.
bool _matches(DictionaryTerm term, String needle, String? categoryLabel) {
  final haystack = [term.term, ...term.aliases, ?categoryLabel];
  return haystack.any((text) => _fold(text).contains(needle));
}

/// The terms [filter] admits, in the order [terms] gives them.
///
/// [DictionaryFilter.toLearn] excludes reference terms: they are not "not
/// yet", because no lesson will ever teach them.
List<DictionaryTerm> filterDictionary(
  List<DictionaryTerm> terms,
  DictionaryFilter filter,
  Set<String> completedLessonIds,
) {
  if (filter == DictionaryFilter.all) return terms;
  final wanted = filter == DictionaryFilter.learned
      ? DictionaryStatus.learned
      : DictionaryStatus.toLearn;
  return terms
      .where((term) => dictionaryStatusOf(term, completedLessonIds) == wanted)
      .toList();
}

/// How many terms sit behind each filter chip.
///
/// [toLearn] excludes reference terms for the same reason the list does — the
/// number in front of the learner has to be a promise the course can keep.
class DictionaryCounts {
  /// Creates a [DictionaryCounts].
  const DictionaryCounts({
    required this.all,
    required this.learned,
    required this.toLearn,
  });

  /// Every term, reference included.
  final int all;

  /// Terms whose teaching lesson is complete.
  final int learned;

  /// Terms still ahead on the path, reference terms excluded.
  final int toLearn;
}

/// Counts [terms] under each filter, in one pass.
DictionaryCounts dictionaryCounts(
  List<DictionaryTerm> terms,
  Set<String> completedLessonIds,
) {
  var learned = 0;
  var toLearn = 0;
  for (final term in terms) {
    switch (dictionaryStatusOf(term, completedLessonIds)) {
      case DictionaryStatus.learned:
        learned++;
      case DictionaryStatus.toLearn:
        toLearn++;
      case DictionaryStatus.reference:
        break;
    }
  }
  return DictionaryCounts(
    all: terms.length,
    learned: learned,
    toLearn: toLearn,
  );
}

/// Groups [terms] under [categories], in bank order.
///
/// A category holding no terms is absent from the result rather than mapped to
/// an empty list, so the home grid can render the keys directly. Every term
/// lands under exactly one category — the extractor refuses a bank whose
/// category pointer does not resolve.
Map<DictionaryCategory, List<DictionaryTerm>> groupByCategory(
  List<DictionaryTerm> terms,
  List<DictionaryCategory> categories,
) {
  final grouped = <DictionaryCategory, List<DictionaryTerm>>{};
  for (final category in categories) {
    final members = terms
        .where((term) => term.categoryId == category.id)
        .toList();
    if (members.isNotEmpty) grouped[category] = members;
  }
  return grouped;
}

// Folding is a lowercase plus a Latin-1 accent strip. The content is Latin
// script throughout, so a full Unicode normalisation would be a dependency
// bought for characters no term contains.
const _accented = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
const _plain = 'aaaaaaceeeeiiiinooooouuuuyy';

/// [text] lowercased with Latin-1 accents stripped, for comparison.
String _fold(String text) {
  final buffer = StringBuffer();
  for (final char in text.trim().toLowerCase().split('')) {
    final accent = _accented.indexOf(char);
    buffer.write(accent == -1 ? char : _plain[accent]);
  }
  return buffer.toString();
}
