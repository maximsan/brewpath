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
