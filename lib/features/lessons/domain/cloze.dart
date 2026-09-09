/// A predict question's blank, and the prose either side of it.
///
/// The design writes the blank as a run of underscores in the authored
/// question, so the split is a property of the content rather than of the
/// widget that draws it — and is checkable without pumping one.
library;

/// A blank: two or more underscores. One is punctuation.
final _blank = RegExp('_{2,}');

/// Whether [question] carries a blank at all. Thirteen of the authored predict
/// questions do not, and those render as ordinary prose.
bool hasCloze(String question) => _blank.hasMatch(question);

/// The prose either side of each blank in [question], in order.
///
/// One segment longer than the number of blanks, so a caller interleaves them:
/// segment, slot, segment. A question with no blank gives a single segment,
/// which is the whole of it.
List<String> clozeSegments(String question) => question.split(_blank);
