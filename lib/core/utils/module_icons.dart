import 'package:brew_path/core/icons/app_icon.dart';

/// Maps a topic's glyph name to the design's own mark for it, so each module —
/// and each collectible card derived from one — reads with its own identity
/// across the Learn, Path and Cards screens.
///
/// Accepts both the bare form (`beans`) and the prefixed one (`ic_beans`).
///
/// **Why this is not a Material lookup any more.** The stock icons it used to
/// return broke three of the design's own concept rules by name: Roasting drew
/// `local_fire_department` where the design "leaves the flame to the streak",
/// Processing drew `water_drop` where "water is not the category", and every
/// topic the course had not named fell back to `Icons.menu_book` — so four
/// knowledge marks were the same book, against "no two topics share a mark".
///
/// The design draws nine topics and the course names eight of them, so the
/// fallback below is reached only by a glyph name the design has never had.
/// [AppIcon.beans] is the family's most general mark and the least wrong thing
/// to draw; a name arriving here at all is content naming a topic the design
/// has not drawn, which is a design question rather than a lookup failure.
AppIcon moduleMark(String iconName) {
  final key = iconName.startsWith('ic_') ? iconName.substring(3) : iconName;
  return switch (key) {
    'beans' => AppIcon.beans,
    'processing' => AppIcon.processing,
    'roasting' => AppIcon.roasting,
    'grind' => AppIcon.grind,
    'brewing' => AppIcon.brewing,
    'espresso' => AppIcon.espresso,
    'sensory' => AppIcon.sensory,
    'equipment' => AppIcon.equipment,
    'trade' => AppIcon.trade,
    _ => AppIcon.beans,
  };
}
