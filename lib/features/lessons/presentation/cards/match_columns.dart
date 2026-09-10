import 'package:brew_path/features/lessons/presentation/cards/match_anchors.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_motion.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_standing.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_tile.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The design's two columns with the connectors drawn over them.
///
/// Traits on the left drag or tap; answers on the right accept either. The
/// [overlay] is painted above both, which is why they share one [Stack].
class MatchColumns extends StatelessWidget {
  /// Creates a [MatchColumns].
  const MatchColumns({
    required this.pairs,
    required this.targets,
    required this.anchors,
    required this.board,
    required this.callbacks,
    required this.overlay,
    super.key,
  });

  /// The traits, in display order.
  final List<MatchPair> pairs;

  /// The deduped answers, in display order.
  final List<String> targets;

  /// Where the connectors are measured between.
  final MatchAnchors anchors;

  /// How the board stands.
  final MatchBoardStanding board;

  /// What the columns report back.
  final MatchColumnCallbacks callbacks;

  /// The connectors, painted over both columns.
  final Widget overlay;

  @override
  Widget build(BuildContext context) {
    // `LayoutBuilder` so a width change remeasures: the anchors are read out
    // of the last layout, and nothing else would tell the lines to move.
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        key: anchors.board,
        children: [
          // `IntrinsicHeight` so the answer column is as tall as the traits
          // beside it. Without it the column shrinks to its own two tiles and
          // the design's `space-around` has no room to spread them into.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _TraitColumn(this, width: _columnWidth(constraints)),
                ),
                SizedBox(width: OffTokens.matchColumnGap.value),
                Expanded(child: _AnswerColumn(this)),
              ],
            ),
          ),
          // Below the tiles in the tree but painted over them, and never in
          // the way of a drop: the lines are a drawing, not a surface.
          Positioned.fill(child: IgnorePointer(child: overlay)),
        ],
      ),
    );
  }

  /// One column's width: the two halves either side of the design's gutter.
  /// Read here rather than measured lower down, because a `LayoutBuilder`
  /// inside the columns cannot be sized through by [IntrinsicHeight].
  double _columnWidth(BoxConstraints constraints) =>
      (constraints.maxWidth - OffTokens.matchColumnGap.value) / 2;
}

/// The traits, each a drag source that also answers a tap.
class _TraitColumn extends StatelessWidget {
  const _TraitColumn(this.columns, {required this.width});

  final MatchColumns columns;

  /// The column's own width, so a lifted clone keeps the tile's size.
  final double width;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final (index, pair) in columns.pairs.indexed) ...[
        if (index > 0) SizedBox(height: OffTokens.matchTileGap.value),
        _Trait(columns: columns, index: index, pair: pair, width: width),
      ],
    ],
  );
}

class _Trait extends StatelessWidget {
  const _Trait({
    required this.columns,
    required this.index,
    required this.pair,
    required this.width,
  });

  final MatchColumns columns;
  final int index;
  final MatchPair pair;
  final double width;

  @override
  Widget build(BuildContext context) {
    final board = columns.board;
    final state = board.traitState(index);
    final placed = board.placed.contains(index);
    final spoken = placed
        ? '${pair.left}, paired with ${pair.right}'
        : pair.left;

    final tile = MatchTile(
      key: columns.anchors.trait(index),
      text: pair.left,
      state: state,
      semanticsLabel: spoken,
      onTap: placed ? null : () => columns.callbacks.onSelectTrait(index),
      dragging: board.dragging == index,
    );

    final shaken = MatchShakeBox(
      generation: board.miss?.fact == index ? board.shakeTick : 0,
      child: tile,
    );

    if (placed || board.cleared) return shaken;

    return Draggable<int>(
      data: index,
      onDragStarted: () => columns.callbacks.onDragTrait(index),
      onDragEnd: (_) => columns.callbacks.onDragEnded(),
      onDraggableCanceled: (_, _) => columns.callbacks.onDragEnded(),
      feedback: MatchDragGhost(text: pair.left, width: width),
      childWhenDragging: MatchTile(
        text: pair.left,
        state: state,
        semanticsLabel: spoken,
        dragging: true,
      ),
      child: shaken,
    );
  }
}

/// The answers, each a drop target that also answers a tap.
class _AnswerColumn extends StatelessWidget {
  const _AnswerColumn(this.columns);

  final MatchColumns columns;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    // `justify-content: space-around` on the right column, so a short answer
    // list spreads against the traits it is joined to rather than stacking.
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      for (final (index, target) in columns.targets.indexed) ...[
        if (index > 0) SizedBox(height: OffTokens.matchTileGap.value),
        _Answer(columns: columns, target: target),
      ],
    ],
  );
}

class _Answer extends StatelessWidget {
  const _Answer({required this.columns, required this.target});

  final MatchColumns columns;
  final String target;

  @override
  Widget build(BuildContext context) {
    final board = columns.board;

    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => !board.cleared,
      onAcceptWithDetails: (details) =>
          columns.callbacks.onTarget(target, dragged: details.data),
      builder: (context, candidate, _) {
        final state = board.answerState(target, hot: candidate.isNotEmpty);
        return MatchSnapBox(
          generation: board.snapTarget == target ? board.snapTick : 0,
          child: MatchShakeBox(
            generation: board.miss?.target == target ? board.shakeTick : 0,
            child: Transform.scale(
              scale: state.restingScale,
              child: MatchTile(
                key: columns.anchors.answer(target),
                text: target,
                state: state,
                align: TextAlign.end,
                semanticsLabel: 'Place under $target',
                onTap: board.cleared
                    ? null
                    : () => columns.callbacks.onTarget(target),
              ),
            ),
          ),
        );
      },
    );
  }
}
