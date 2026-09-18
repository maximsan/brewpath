/// The four surfaces that teach their swipe on first run.
///
/// [id] is what is written to disk, so it is spelled here rather than derived
/// from the enum value: a rename must not re-arm a hint on every device that
/// has already learned the gesture.
enum SwipeSurface {
  /// A dictionary row, swiped right to save.
  dictionary(id: 'dictionary'),

  /// The flashcard deck.
  flashcards(id: 'flashcards'),

  /// A module's reward carousel.
  rewards(id: 'rewards'),

  /// The Coffee Challenge card, slid aside to park.
  challenge(id: 'challenge');

  const SwipeSurface({required this.id});

  /// What the settings row stores for this surface.
  final String id;
}

/// The surfaces whose gesture this learner has used, as one column value.
///
/// Same shape as the micro-tips' seen list, and device-local for the same
/// reason: having learned a gesture is not progress.
abstract final class SwipesUsed {
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

  /// [stored] with [surface] added.
  static String withSurface(String stored, SwipeSurface surface) =>
      encode(decode(stored)..add(surface.id));
}
