import 'dart:async';

import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/module_glyph.dart';
import 'package:brew_path/features/challenges/presentation/path_challenge_node.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/features/path/domain/path_density.dart';
import 'package:brew_path/features/path/domain/path_module_view.dart';
import 'package:brew_path/features/path/presentation/path_lesson_row.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
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

  /// The design's `320ms cubic-bezier(.4,0,.2,1)` — one duration, because the
  /// chevron turns *as* the list grows and two constants could drift apart.
  static const Duration expandDuration = Duration(milliseconds: 320);

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
          _Lessons(module: module, isOpen: _isOpen),
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
  static const double _markSize = 13;

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
            ModuleGlyph(iconName: module.iconName, locked: locked),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                module.title,
                style: AppText.title(
                  mood: mood,
                  color: locked ? mood.inkMute : mood.ink,
                ),
              ),
            ),
            _TrailingMark(module: module, isOpen: isOpen, size: _markSize),
          ],
        ),
        if (_subLine(module, previousTitle) case final line?) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(left: _titleInset),
            // Uppercase is the type rule, not part of what the line says, so
            // the reader is given it as written — the same split
            // `SmallcapsLabel` makes at the label step.
            child: Semantics(
              label: line,
              excludeSemantics: true,
              child: Text(
                line.toUpperCase(),
                style: AppText.micro(mood: mood),
              ),
            ),
          ),
        ],
      ],
    );

    // A purchase-locked module is the one locked row that *does* something:
    // the design makes it `interactive` and raises the purchase sheet
    // (`screens.jsx:1318`), because it is where a free learner meets the wall.
    if (module.isPurchaseLocked) {
      return Semantics(
        button: true,
        label: LockedRowCopy.purchaseLockedSemantics(module.title),
        excludeSemantics: true,
        child: InkWell(
          onTap: () => unawaited(
            showPlusGate(context, LockedModule(title: module.title)),
          ),
          child: heading,
        ),
      );
    }

    if (!module.density.canCollapse) {
      // Nothing to toggle: the row is a label, and wrapping it in a disabled
      // button would announce an action that does not exist.
      return heading;
    }

    // Only a finished module gets here, and completion is the one thing this
    // row does not say out loud: the design signals it by *removing* the
    // lesson-count line, which leaves a screen reader nothing to read.
    return Semantics(
      button: true,
      expanded: isOpen,
      label: AppLabels.moduleCompleteSemantics(module.title),
      excludeSemantics: true,
      child: InkWell(onTap: onToggle, child: heading),
    );
  }

  /// The mono line under a module's title — **only a locked module has one**.
  ///
  /// The design prints it in `CompactModuleRow` alone; the expanded branch
  /// guards its sub-line on `mod.locked && prereq`, which an expanded module
  /// never is (`screens.jsx:1463`). So an active module states its lesson
  /// count by listing the lessons, and a finished one goes quiet.
  ///
  /// **The purchase wins over the prerequisite** (`screens.jsx:1345`). Both
  /// can be true of one module, and only one of them is the learner's next
  /// move: someone who cannot buy the course will never finish the module
  /// before it either, so naming that module would be advice they cannot take.
  static String? _subLine(PathModule module, String? previousTitle) {
    if (!module.density.isLocked) return null;
    if (module.isPurchaseLocked) {
      return LockedRowCopy.purchasedModule(module.totalCount);
    }
    return previousTitle == null
        ? LockedRowCopy.moduleSize(module.totalCount)
        : LockedRowCopy.finishToUnlock(previousTitle);
  }
}

/// The lock, or the chevron that turns as a finished module opens.
class _TrailingMark extends StatelessWidget {
  const _TrailingMark({
    required this.module,
    required this.isOpen,
    required this.size,
  });

  /// Half a turn: the chevron points down shut and up open.
  static const double _openTurns = 0.5;

  final PathModule module;
  final bool isOpen;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    if (module.density.isLocked) {
      // Accent for the purchase lock, ink-mute for progression
      // (`screens.jsx:1336` against `:1338`). Accent means there is something
      // to do, and buying is the one of the two a learner can act on now.
      return Semantics(
        label: module.isPurchaseLocked ? LockedRowCopy.partOfFoundations : null,
        child: IconMark(
          AppIcon.lock,
          size: size,
          color: module.isPurchaseLocked ? mood.accent : mood.inkMute,
        ),
      );
    }
    if (!module.density.canCollapse) return const SizedBox.shrink();

    final chevron = IconMark(AppIcon.chevron, size: size, color: mood.inkMute);

    return MediaQuery.disableAnimationsOf(context)
        ? RotatedBox(quarterTurns: isOpen ? 2 : 0, child: chevron)
        : AnimatedRotation(
            turns: isOpen ? _openTurns : 0,
            duration: PathModuleSection.expandDuration,
            child: chevron,
          );
  }
}

/// The lesson list, and the way it grows and shrinks.
class _Lessons extends StatelessWidget {
  const _Lessons({required this.module, required this.isOpen});

  final PathModule module;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final lessons = isOpen
        ? Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < module.lessons.length; i++)
                  PathLessonRow(
                    entry: module.lessons[i],
                    isLast: i == module.lessons.length - 1,
                  ),
                // The module's Coffee Challenge — Path is the only place a
                // challenge appears outside Today. Inside the collapsible
                // region, as the design nests it: a finished module that is
                // shut is not still offering its brew. A locked module never
                // opens, so it never shows one.
                if (!module.density.isLocked)
                  PathChallengeNode(moduleId: module.id),
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
            duration: PathModuleSection.expandDuration,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: lessons,
          );
  }
}
