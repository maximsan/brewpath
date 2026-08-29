import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/module_glyph.dart';
import 'package:brew_path/features/challenges/presentation/path_challenge_node.dart';
import 'package:brew_path/features/path/domain/path_density.dart';
import 'package:brew_path/features/path/domain/path_module_view.dart';
import 'package:brew_path/features/path/presentation/path_lesson_row.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One module on Path, drawn at the density its state earns
/// (`prototype/screens.jsx:1408-1440`).
///
/// The heading is the same three parts at every density — glyph, title,
/// trailing mark — and only what hangs below it changes: the active module's
/// lessons, a completed module's lessons once opened, and a locked module's
/// one-line reason. That is why this is one widget rather than three: the
/// densities are the *same row* saying less.
class PathModuleSection extends StatelessWidget {
  /// Creates a [PathModuleSection].
  const PathModuleSection({
    required this.module,
    required this.isExpanded,
    required this.onToggle,
    this.previousTitle,
    super.key,
  });

  /// The module and its lessons.
  final PathModule module;

  /// Whether a collapsible module is currently open. Ignored at the densities
  /// that cannot collapse.
  final bool isExpanded;

  /// Opens or shuts a collapsible module.
  final VoidCallback onToggle;

  /// The module before this one, named by a locked row as what opens it.
  final String? previousTitle;

  /// The design's gap between one module and the next.
  static const double _sectionGap = 20;

  /// The chevron's turn, in whole rotations, when a module is open.
  static const double _openTurns = 0.5;

  static const Duration _expandDuration = Duration(milliseconds: 320);

  /// Whether the lessons are showing right now.
  bool get _isOpen =>
      module.density.showsLessonsWhenCollapsed ||
      (module.density.canCollapse && isExpanded);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Heading(
            module: module,
            isOpen: _isOpen,
            onToggle: onToggle,
            previousTitle: previousTitle,
          ),
          _Lessons(module: module, isOpen: _isOpen, duration: _expandDuration),
          // The module's Coffee Challenge — Path is the only place a challenge
          // appears outside Today. A locked module has none to offer.
          if (module.density != PathModuleDensity.locked)
            PathChallengeNode(moduleId: module.id),
        ],
      ),
    );
  }
}

/// Glyph, title and trailing mark — the line every module has at every density.
class _Heading extends StatelessWidget {
  const _Heading({
    required this.module,
    required this.isOpen,
    required this.onToggle,
    required this.previousTitle,
  });

  final PathModule module;
  final bool isOpen;
  final VoidCallback onToggle;
  final String? previousTitle;

  /// The design indents the sub-line to the title's left edge: the 32-px glyph
  /// column plus the gap beside it.
  static const double _titleInset = 44;
  static const double _glyphGap = 12;
  static const double _subLineGap = 8;
  static const double _markSize = 13;
  static const Duration _turnDuration = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final locked = module.density == PathModuleDensity.locked;

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ModuleGlyph(iconName: module.item.module.iconName, locked: locked),
            const SizedBox(width: _glyphGap),
            Expanded(
              child: Text(
                module.item.module.title,
                style: AppText.title(
                  mood: mood,
                  color: locked ? mood.inkMute : mood.ink,
                ),
              ),
            ),
            _TrailingMark(
              module: module,
              isOpen: isOpen,
              markSize: _markSize,
              turnDuration: _turnDuration,
            ),
          ],
        ),
        if (_subLine(module, previousTitle) case final line?) ...[
          const SizedBox(height: _subLineGap),
          Padding(
            padding: const EdgeInsets.only(left: _titleInset),
            child: Text(line, style: AppText.micro(mood: mood)),
          ),
        ],
      ],
    );

    if (!module.density.canCollapse) {
      // Nothing to toggle: the row is a label, and wrapping it in a disabled
      // button would announce an action that does not exist.
      return heading;
    }

    return Semantics(
      button: true,
      expanded: isOpen,
      label: module.item.module.title,
      excludeSemantics: true,
      child: InkWell(onTap: onToggle, child: heading),
    );
  }

  /// The mono line under a module's title, or null where the design prints
  /// none. A finished module says nothing — it goes quiet rather than
  /// announcing itself.
  static String? _subLine(PathModule module, String? previousTitle) =>
      switch (module.density) {
        PathModuleDensity.complete => null,
        PathModuleDensity.locked when previousTitle != null =>
          'Finish $previousTitle to unlock',
        _ => '${module.item.totalCount} lessons',
      };
}

/// The lock, or the chevron that turns as a finished module opens.
class _TrailingMark extends StatelessWidget {
  const _TrailingMark({
    required this.module,
    required this.isOpen,
    required this.markSize,
    required this.turnDuration,
  });

  final PathModule module;
  final bool isOpen;
  final double markSize;
  final Duration turnDuration;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    if (module.density == PathModuleDensity.locked) {
      return IconMark(AppIcon.lock, size: markSize, color: mood.inkMute);
    }
    if (!module.density.canCollapse) return const SizedBox.shrink();

    final chevron = IconMark(
      AppIcon.chevron,
      size: markSize,
      color: mood.inkMute,
    );

    return MediaQuery.disableAnimationsOf(context)
        ? RotatedBox(quarterTurns: isOpen ? 2 : 0, child: chevron)
        : AnimatedRotation(
            turns: isOpen ? PathModuleSection._openTurns : 0,
            duration: turnDuration,
            child: chevron,
          );
  }
}

/// The lesson list, and the way it grows and shrinks.
class _Lessons extends StatelessWidget {
  const _Lessons({
    required this.module,
    required this.isOpen,
    required this.duration,
  });

  final PathModule module;
  final bool isOpen;
  final Duration duration;

  static const double _listTop = 8;
  static const double _rowGap = 8;

  @override
  Widget build(BuildContext context) {
    final lessons = isOpen
        ? Padding(
            padding: const EdgeInsets.only(top: _listTop),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < module.lessons.length; i++) ...[
                  if (i > 0) const SizedBox(height: _rowGap),
                  PathLessonRow(entry: module.lessons[i]),
                ],
              ],
            ),
          )
        : const SizedBox.shrink();

    // ⚠️ Reduced motion drops the animator rather than giving it a zero
    // duration: `AnimatedSize` re-dirties itself inside its own
    // `performLayout` when asked to finish instantly, which the framework
    // asserts on. Same reasoning as `AppHeader`'s collapse.
    return MediaQuery.disableAnimationsOf(context)
        ? lessons
        : AnimatedSize(
            duration: duration,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: lessons,
          );
  }
}
