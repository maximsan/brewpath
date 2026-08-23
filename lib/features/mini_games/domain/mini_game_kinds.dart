/// How the catalog is arranged: the kinds it groups by, and their order.
///
/// A learner comes to the shelf wanting a *mechanic* — something to match,
/// something to put in order — so the catalog leads with the kind and lists
/// that kind's games beneath it. The order is fixed by the design and does not
/// derive from the catalog, so adding a game never reshuffles the shelf.
library;

import 'package:brew_path/shared/models/content/mini_game_format.dart';

/// One kind of mini-game, and how the shelf names it.
class MiniGameKind {
  /// Creates a [MiniGameKind].
  const MiniGameKind({required this.kind, required this.label});

  /// The `kind` a catalog entry carries.
  final String kind;

  /// What the group heading reads.
  final String label;
}

/// Every kind the catalog groups by, in the order the shelf shows them.
const List<MiniGameKind> miniGameKinds = [
  MiniGameKind(kind: 'match', label: 'Match'),
  MiniGameKind(kind: 'quiz', label: 'True or false'),
  MiniGameKind(kind: 'flavor', label: 'Name the note'),
  MiniGameKind(kind: 'bagpick', label: 'Blind bag'),
  MiniGameKind(kind: 'tastefix', label: 'Taste fix'),
  MiniGameKind(kind: 'slider', label: 'Calibrate'),
  MiniGameKind(kind: 'sequence', label: 'Sequence'),
];

/// One group as the shelf renders it: a heading, and the games under it.
class MiniGameGroup {
  /// Creates a [MiniGameGroup].
  const MiniGameGroup({required this.label, required this.games});

  /// The group heading.
  final String label;

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
      groups.add(MiniGameGroup(label: kind.label, games: games));
    }
  }

  for (final format in formats) {
    if (known.contains(format.kind)) continue;
    final existing = groups.indexWhere((group) => group.label == format.kind);
    if (existing == -1) {
      groups.add(MiniGameGroup(label: format.kind, games: [format]));
    } else {
      groups[existing].games.add(format);
    }
  }

  return groups;
}
