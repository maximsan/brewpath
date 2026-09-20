/// A set of ids in one text column, comma-separated; empty for none.
///
/// One column rather than one per id, because what the app names is the *set*.
/// An id it does not know is kept as read, so an older build never trims a
/// newer device's record. Shared by the micro-tips' seen list and the swipe
/// surfaces' used list, which are the same column twice.
abstract final class IdSet {
  static const String _separator = ',';

  /// The ids in [stored], with blanks dropped.
  static Set<String> decode(String stored) => stored
      .split(_separator)
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toSet();

  /// [ids] as one column value, in a stable order so an unchanged set writes
  /// an unchanged string.
  static String encode(Set<String> ids) =>
      (ids.toList()..sort()).join(_separator);

  /// [stored] with [id] added.
  static String plus(String stored, String id) =>
      encode(decode(stored)..add(id));
}
