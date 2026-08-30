import 'package:brew_path/core/icons/app_icon.dart';

/// The mark a dictionary category is drawn with.
///
/// The bank names eight categories and the design's `dict` set draws one mark
/// per topic — *"the most recognisable OBJECT for its subject, never an
/// abstract symbol, and no two topics share a mark"* (`assets/icons/index.json`).
/// They are the same eight, by id.
///
/// The app drew every category with one generic cup until now: the marks did
/// not exist when this screen was built, and #378 ported them without a
/// consumer. This is the consumer.
///
/// Returns null for an id the icon family has no mark for, so a bank that
/// gains a ninth category loses its glyph rather than showing the wrong one.
AppIcon? categoryGlyph(String categoryId) => switch (categoryId) {
  'beans' => AppIcon.beans,
  'processing' => AppIcon.processing,
  'roasting' => AppIcon.roasting,
  'brewing' => AppIcon.brewing,
  'espresso' => AppIcon.espresso,
  'sensory' => AppIcon.sensory,
  'equipment' => AppIcon.equipment,
  'trade' => AppIcon.trade,
  _ => null,
};
