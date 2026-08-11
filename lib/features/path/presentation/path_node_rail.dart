import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The left rail of a path node: connector segments above and below a
/// state-colored node circle. Connectors are hidden at the path's ends and
/// "light up" through modules the user has already reached.
class PathNodeRail extends StatelessWidget {
  /// Creates a [PathNodeRail].
  const PathNodeRail({
    required this.item,
    required this.isFirst,
    required this.isLast,
    super.key,
  });

  /// The module paired with its progress.
  final ModuleWithProgress item;

  /// Whether this is the first node (trims the top connector).
  final bool isFirst;

  /// Whether this is the last node (trims the bottom connector).
  final bool isLast;

  static const double _railWidth = 32;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final lit = mood.accent;
    final dim = mood.surface2;
    final reached = !item.isLocked;

    return SizedBox(
      width: _railWidth,
      child: Column(
        children: [
          Expanded(
            child: _Connector(
              color: isFirst ? Colors.transparent : (reached ? lit : dim),
            ),
          ),
          _NodeCircle(item: item),
          Expanded(
            child: _Connector(
              color: isLast
                  ? Colors.transparent
                  : (item.isComplete ? lit : dim),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single vertical trail segment.
class _Connector extends StatelessWidget {
  const _Connector({required this.color});

  final Color color;

  static const double _width = 3;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(width: _width, color: color),
    );
  }
}

/// The node marker: filled when complete, outlined when current/available,
/// muted with a lock when locked.
class _NodeCircle extends StatelessWidget {
  const _NodeCircle({required this.item});

  final ModuleWithProgress item;

  static const double _size = 36;
  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    final (
      Color background,
      Color foreground,
      IconData icon,
      Border? border,
    ) = switch (item) {
      _ when item.isLocked => (
        mood.surface2,
        mood.inkMute,
        Icons.lock_outline,
        null,
      ),
      _ when item.isComplete => (
        mood.accent,
        mood.accentInk,
        Icons.check,
        null,
      ),
      // The current node is an outline, not a fill: the design draws it on
      // the page canvas (`.lesson-row.current .path-node`). It used to ask
      // for `primaryContainer`, which resolved to `primary` and painted the
      // arrow in its own background colour — invisible.
      _ => (
        mood.bg,
        mood.accent,
        Icons.play_arrow,
        Border.all(color: mood.accent, width: 2),
      ),
    };

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Icon(icon, size: _iconSize, color: foreground),
    );
  }
}
