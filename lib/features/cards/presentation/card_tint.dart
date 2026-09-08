import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The hue a tile's surface is washed with.
///
/// The design gives every collectible kind a tinted card so the grid reads as a
/// collection rather than a spreadsheet — *"tint the card surface for variety —
/// never too far from the base"*. The wash is always 8–12% of one hue over
/// `surface`, which is why the strength travels beside the hue rather than
/// being fixed: the design varies it by a point or two per kind, and rounding
/// that to one value is a design change.
enum CardTintBase {
  /// Green — the plant, and anything growing.
  sage,

  /// The app's own accent.
  accent,

  /// Cherry red.
  berry,

  /// Ink, for the mechanical kinds.
  ink,

  /// Mid roast.
  roastMid,

  /// Dark roast.
  roastDark,

  /// A ripe cherry.
  ripe,

  /// Not a wash at all: the raised surface, taken whole.
  surfaceTwo;

  /// This hue in [mood].
  Color of(MoodColors mood) => switch (this) {
    CardTintBase.sage => mood.sage,
    CardTintBase.accent => mood.accent,
    CardTintBase.berry => mood.berry,
    CardTintBase.ink => mood.ink,
    CardTintBase.roastMid => ArtColors.roastMid,
    CardTintBase.roastDark => ArtColors.roastDark,
    CardTintBase.ripe => ArtColors.ripe,
    CardTintBase.surfaceTwo => mood.surface2,
  };
}

/// Each kind's wash, transcribed from `CARD_TINT` rather than invented — the
/// table is generated from the design source, so a kind the design tints green
/// cannot drift to red here.
///
/// `surfaceTwo` carries a strength of 1: the design hands that one kind
/// `var(--surface-2)` whole instead of mixing anything into `surface`.
const Map<String, (CardTintBase, double)> _tints = {
  'botanical': (CardTintBase.sage, 0.12),
  'layers': (CardTintBase.berry, 0.1),
  'map': (CardTintBase.accent, 0.08),
  'specimen': (CardTintBase.surfaceTwo, 1.0),
  'dryingbed': (CardTintBase.sage, 0.12),
  'ferment': (CardTintBase.sage, 0.11),
  'label': (CardTintBase.accent, 0.09),
  'roastscale': (CardTintBase.roastMid, 0.1),
  'crack': (CardTintBase.sage, 0.1),
  'calendar': (CardTintBase.accent, 0.08),
  'gauge': (CardTintBase.accent, 0.1),
  'droplet': (CardTintBase.accent, 0.1),
  'spectrum': (CardTintBase.ripe, 0.1),
  'scales': (CardTintBase.accent, 0.09),
  'hourglass': (CardTintBase.roastMid, 0.1),
  'burrs': (CardTintBase.ink, 0.08),
  'visualGuide': (CardTintBase.sage, 0.12),
  'particles': (CardTintBase.roastMid, 0.1),
  'burrblade': (CardTintBase.ink, 0.08),
  'grinddial': (CardTintBase.accent, 0.09),
  'altitude': (CardTintBase.sage, 0.1),
  'varieties': (CardTintBase.sage, 0.11),
  'drying': (CardTintBase.ripe, 0.1),
  'anaerobic': (CardTintBase.sage, 0.11),
  'decaf': (CardTintBase.roastMid, 0.1),
  'roastcurve': (CardTintBase.roastMid, 0.1),
  'lightdark': (CardTintBase.roastMid, 0.1),
  'caffeine': (CardTintBase.accent, 0.09),
  'grindbrewer': (CardTintBase.ink, 0.08),
  'extraction': (CardTintBase.accent, 0.1),
  'filter': (CardTintBase.accent, 0.1),
  'firstcup': (CardTintBase.roastMid, 0.1),
  'shot': (CardTintBase.roastDark, 0.1),
  'fieldGuideBeans': (CardTintBase.sage, 0.12),
  'fieldGuideProcess': (CardTintBase.accent, 0.12),
  'fieldGuideRoast': (CardTintBase.roastMid, 0.12),
  'fieldGuideGrind': (CardTintBase.ink, 0.1),
  'fieldGuideBrew': (CardTintBase.berry, 0.11),
};

/// The surface [kind] is drawn on.
///
/// A kind the table does not name takes the plain surface, which is what the
/// design falls back to (`CARD_TINT[card.kind] || 'var(--surface)'`) — a new
/// collectible shows up untinted rather than crashing or borrowing a hue that
/// means something else.
Color cardTint(MoodColors mood, String kind) {
  final tint = _tints[kind];
  if (tint == null) return mood.surface;

  final (base, strength) = tint;
  return Color.lerp(mood.surface, base.of(mood), strength)!;
}
