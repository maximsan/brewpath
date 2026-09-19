/// Which row the dictionary's swipe-to-save hint teaches on.
library;

/// Roughly how many rows fit above the fold on a phone — `ROWS_ABOVE_FOLD`.
const int dictionaryRowsAboveFold = 5;

/// The first id in [termIds] that is not saved and is on screen, or null.
///
/// Not row 0, which the browse list usually opens on already saved, so the
/// nudge demonstrated the state where the gesture does nothing; and not the
/// first unsaved anywhere, which put the demonstration below the fold while
/// its caption stayed in plain view. **Null means nothing nudges at all.**
String? firstUnsavedAboveFold(
  List<String> termIds, {
  required bool Function(String id) isSaved,
}) {
  for (final id in termIds.take(dictionaryRowsAboveFold)) {
    if (!isSaved(id)) return id;
  }
  return null;
}
