import 'package:brew_path/features/lessons/presentation/cards/card_tints.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/painting.dart';

/// The design's `8%` behind a wrong tile, lighter than the 12% a right one
/// takes so a miss reads as a note rather than as an answer.
const double matchWrongWash = 0.08;

/// How a tile on a match board stands — the design's own class list on
/// `.match-item`, as one closed set so no caller can invent a sixth look.
///
/// A trait and an answer take different states from the same list, which is
/// why the list is shared: `held` and `matched` are only ever a trait's,
/// `hot` and `linked` only ever an answer's, and `wrong` belongs to both.
enum MatchTileState {
  /// In play, unmarked.
  plain,

  /// `.selected` — the trait waiting to be placed.
  held,

  /// `.drop-hot` — the answer under a trait being dragged.
  hot,

  /// `.matched` — the trait that landed.
  matched,

  /// `.linked` — the answer at least one trait landed on.
  linked,

  /// `.wrong` — either tile of a bad drop.
  wrong;

  /// Whether the design doubles the outline here. `.selected` and `.drop-hot`
  /// each set a border colour *and* an inset second line; drawing one line at
  /// twice the width is how that reads without painting two.
  bool get isDoubled => this == held || this == hot;

  /// Whether the tile grows — only the answer under a held trait does.
  bool get swells => this == hot;

  /// The outline the design gives this state.
  Color border(MoodColors mood) => switch (this) {
    plain => mood.rule,
    held || hot => mood.accent,
    matched || linked => mood.sage,
    wrong => mood.berry,
  };

  /// What the design washes behind it, or null where it leaves the surface.
  ///
  /// `.linked` is the one marked state with no wash: an answer several traits
  /// fan into would otherwise darken as the board fills.
  Color? fill(MoodColors mood) => switch (this) {
    plain || held || hot || linked => null,
    matched => mood.sage.withValues(alpha: CardTints.wash),
    wrong => mood.berry.withValues(alpha: matchWrongWash),
  };

  /// How far the tile is scaled at rest, before any animation.
  double get restingScale => swells ? OffTokens.matchDropHotScale.value : 1;
}
