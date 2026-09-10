import 'package:brew_path/features/lessons/presentation/cards/match_tile_state.dart';
import 'package:flutter/material.dart';

/// The pair a bad drop was made of, held while the design marks it.
typedef MatchMiss = ({int fact, String target});

/// How the board stands, as the columns need to read it.
///
/// One record rather than eight loose arguments: every field is read together
/// on every build, and a column that took them one by one would let the board
/// hand it a half-updated picture.
@immutable
class MatchBoardStanding {
  /// Records the standing.
  const MatchBoardStanding({
    required this.placed,
    required this.linked,
    required this.selected,
    required this.dragging,
    required this.miss,
    required this.cleared,
    required this.snapTarget,
    required this.snapTick,
    required this.shakeTick,
  });

  /// The traits already landed, by index.
  final Set<int> placed;

  /// The answers at least one landed trait points at. The right column is
  /// deduped, so several traits can share one.
  final Set<String> linked;

  /// The trait waiting to be placed, if the learner tapped one.
  final int? selected;

  /// The trait whose clone is currently under the pointer.
  final int? dragging;

  /// The bad pair still being marked.
  final MatchMiss? miss;

  /// Whether every trait has landed, which takes the board out of play.
  final bool cleared;

  /// The answer that most recently locked, and the tick that plays its snap.
  final String? snapTarget;

  /// Bumped on each lock, so two in a row each animate.
  final int snapTick;

  /// Bumped on each wrong drop, so two in a row each shake.
  final int shakeTick;

  /// How the trait at [index] is drawn.
  MatchTileState traitState(int index) {
    if (miss?.fact == index) return MatchTileState.wrong;
    if (placed.contains(index)) return MatchTileState.matched;
    return selected == index ? MatchTileState.held : MatchTileState.plain;
  }

  /// How the answer labelled [name] is drawn, given whether a trait is
  /// currently held over it.
  MatchTileState answerState(String name, {required bool hot}) {
    if (miss?.target == name) return MatchTileState.wrong;
    if (hot) return MatchTileState.hot;
    return linked.contains(name) ? MatchTileState.linked : MatchTileState.plain;
  }
}

/// What a column tells the board about.
@immutable
class MatchColumnCallbacks {
  /// Records the four things the columns report.
  const MatchColumnCallbacks({
    required this.onSelectTrait,
    required this.onDragTrait,
    required this.onDragEnded,
    required this.onTarget,
  });

  /// A trait was tapped.
  final ValueChanged<int> onSelectTrait;

  /// A trait's drag began.
  final ValueChanged<int> onDragTrait;

  /// A drag ended, however it ended.
  final VoidCallback onDragEnded;

  /// An answer was tapped, or dropped on — `dragged` names which trait when it
  /// arrived by drag, and is null when the learner tapped.
  final void Function(String target, {int? dragged}) onTarget;
}
