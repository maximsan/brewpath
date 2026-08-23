/// The key grammar for the Saved shelf.
///
/// Three prefixes and nothing else: `l:` a lesson, `t:` a dictionary term,
/// `g:` a visual guide. Spelling one at a call site is exactly what this
/// exists to prevent — the prefixes live here once, so a bookmark on a new
/// surface cannot invent a fourth.
///
/// **There is no `c:`.** Card favourites are not a design feature and never
/// were a key, so nothing here excludes them: there is nothing to exclude.
library;

/// What a saved key points at.
enum SavedKind {
  /// A lesson, keyed by lesson id.
  lesson('l'),

  /// A dictionary term, keyed by term id.
  term('t'),

  /// A visual guide, keyed by its **subject** — `g:roast`, not `g:g-roast`.
  /// A guide carries both, so the wrong one resolves to nothing silently.
  guide('g');

  const SavedKind(this.prefix);

  /// The single character this kind is stored under.
  final String prefix;
}

/// A saved key taken apart: what kind of thing, and which one.
typedef SavedKey = ({SavedKind kind, String id});

/// The separator between a key's prefix and its id.
const _separator = ':';

/// [raw] parsed, or **null when it is not a saved key at all**.
///
/// Null rather than a throw, because the stored set arrives from a snapshot a
/// newer build may have written: an unrecognised key is a thing to skip, not
/// an error to crash the shelf with.
SavedKey? parseSavedKey(String raw) {
  final separator = raw.indexOf(_separator);
  if (separator <= 0) return null;

  final prefix = raw.substring(0, separator);
  // Only the *first* colon delimits, so an id may contain one.
  final id = raw.substring(separator + 1);
  if (id.isEmpty) return null;

  for (final kind in SavedKind.values) {
    if (kind.prefix == prefix) return (kind: kind, id: id);
  }
  return null;
}

/// The stored key for [id] of [kind].
String formatSavedKey(SavedKind kind, String id) =>
    '${kind.prefix}$_separator$id';

/// Whether [raw] is one of the three saveable kinds.
bool isSavedKey(String raw) => parseSavedKey(raw) != null;

/// The ids in [keys] belonging to [kind], with anything unparseable dropped.
Set<String> savedKeysOfKind(Set<String> keys, SavedKind kind) => {
  for (final raw in keys)
    if (parseSavedKey(raw) case (
      kind: final parsed,
      :final id,
    ) when parsed == kind)
      id,
};

/// [keys] with [key] added when absent and removed when present.
///
/// Returns a new set rather than mutating: the caller holds a value read out
/// of the snapshot, and a store that hands back something other than what it
/// was given is the bug this shape rules out.
Set<String> toggleSavedKey(Set<String> keys, String key) {
  final next = {...keys};
  if (!next.remove(key)) next.add(key);
  return next;
}
