import 'package:flutter/material.dart';

/// Where a connector starts and ends, in the board's own coordinates.
typedef MatchLineEnds = ({Offset from, Offset to});

/// Keeps the keys a match board measures its connectors between.
///
/// The design reads the two tiles' boxes after layout and draws between them;
/// this is that reading, kept off the widget so the board's build stays about
/// what is on screen rather than about where it is.
class MatchAnchors {
  /// The box every anchor is measured relative to — the two columns together.
  final GlobalKey board = GlobalKey();

  final Map<int, GlobalKey> _traits = {};
  final Map<String, GlobalKey> _answers = {};

  /// The key for the trait at [index], minted once and kept.
  GlobalKey trait(int index) => _traits.putIfAbsent(index, GlobalKey.new);

  /// The key for the answer labelled [name].
  GlobalKey answer(String name) => _answers.putIfAbsent(name, GlobalKey.new);

  /// The line from [trait]'s right edge to [answer]'s left edge, both at
  /// mid-height — or null while either one is unbuilt or unlaid.
  MatchLineEnds? between(int trait, String answer) {
    final start = _boxOf(this.trait(trait));
    final end = _boxOf(this.answer(answer));
    if (start == null || end == null) return null;
    return (
      from: Offset(start.right, start.center.dy),
      to: Offset(end.left, end.center.dy),
    );
  }

  /// [key]'s box in the board's coordinates, or null if it cannot be read.
  ///
  /// Every one of these guards fires in practice: a tile is keyed before it is
  /// built, and the board is measured on the frame a placement rebuilds it.
  Rect? _boxOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final root = board.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || root == null) return null;
    if (!box.attached || !root.attached || !box.hasSize || !root.hasSize) {
      return null;
    }
    return root.globalToLocal(box.localToGlobal(Offset.zero)) & box.size;
  }
}
