/// How the catalog is arranged: the kinds it groups by, and their order.
///
/// A learner comes to the shelf wanting a *mechanic* — something to match,
/// something to put in order — so the catalog leads with the kind and lists
/// that kind's games beneath it. The order is fixed by the design and does not
/// derive from the catalog, so adding a game never reshuffles the shelf.
library;

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';

/// One kind of mini-game, how the shelf names it, and the mark it heads with.
class MiniGameKind {
  /// Creates a [MiniGameKind].
  const MiniGameKind({
    required this.kind,
    required this.label,
    required this.mark,
  });

  /// The `kind` a catalog entry carries.
  final String kind;

  /// What the group heading reads.
  final String label;

  /// The design's glyph for this kind. Required rather than optional: a
  /// heading with a mark beside three without one reads as a rendering fault,
  /// so a kind that has no mark cannot be added at all
  /// ([#436](https://github.com/maximsan/brewpath/issues/436)).
  final AppIcon mark;
}

/// Every kind the catalog groups by, in the order the shelf shows them.
const List<MiniGameKind> miniGameKinds = [
  MiniGameKind(kind: 'match', label: 'Match', mark: AppIcon.match),
  MiniGameKind(kind: 'quiz', label: 'True or false', mark: AppIcon.quiz),
  MiniGameKind(kind: 'flavor', label: 'Name the note', mark: AppIcon.flavour),
  MiniGameKind(kind: 'bagpick', label: 'Blind bag', mark: AppIcon.bagpick),
  MiniGameKind(kind: 'tastefix', label: 'Taste fix', mark: AppIcon.tastefix),
  MiniGameKind(kind: 'slider', label: 'Calibrate', mark: AppIcon.slider),
  MiniGameKind(kind: 'sequence', label: 'Sequence', mark: AppIcon.sequence),
];

/// One group as the shelf renders it: a heading, and the games under it.
class MiniGameGroup {
  /// Creates a [MiniGameGroup].
  const MiniGameGroup({
    required this.label,
    required this.games,
    required this.mark,
  });

  /// The group heading.
  final String label;

  /// The glyph beside the heading, or null for the fallback group a game of
  /// an unlisted kind lands in — that group is named by its own raw kind and
  /// has no mark to draw.
  final AppIcon? mark;

  /// The games in this group, in catalog order.
  final List<MiniGameFormat> games;
}

/// [formats] arranged into kind groups, in [miniGameKinds] order.
///
/// Empty groups are dropped, so a kind with no games leaves no heading behind.
/// A game whose kind is not in [miniGameKinds] is **not** discarded — it lands
/// in a trailing group named by its own kind, because a catalog that silently
/// loses a game is worse than one with an ugly heading. The unit test asserts
/// no shipped game needs that fallback.
List<MiniGameGroup> groupCatalogByKind(List<MiniGameFormat> formats) {
  final known = {for (final kind in miniGameKinds) kind.kind};
  final groups = <MiniGameGroup>[];

  for (final kind in miniGameKinds) {
    final games = [
      for (final format in formats)
        if (format.kind == kind.kind) format,
    ];
    if (games.isNotEmpty) {
      groups.add(
        MiniGameGroup(label: kind.label, games: games, mark: kind.mark),
      );
    }
  }

  for (final format in formats) {
    if (known.contains(format.kind)) continue;
    final existing = groups.indexWhere((group) => group.label == format.kind);
    if (existing == -1) {
      groups.add(
        MiniGameGroup(label: format.kind, games: [format], mark: null),
      );
    } else {
      groups[existing].games.add(format);
    }
  }

  return groups;
}
