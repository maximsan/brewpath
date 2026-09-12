import 'dart:async';

import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/disclosure_mark.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/disclosure.dart';
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

/// One module on Path, drawn at the density its state earns.
///
/// The heading is the same three parts at every density; only what hangs
/// below it changes. One widget rather than three, because the densities are
/// the *same row* saying less.
class PathModuleSection extends StatelessWidget {
  /// Creates a [PathModuleSection].
  const PathModuleSection({
    required this.module,
    required this.isExpanded,
    required this.onToggle,
    this.previousTitle,
    super.key,
  });

  /// The design's gap between one module and the next.
  static const double _sectionGap = 20;

  /// The lock's `size={13}`, which the design sets apart from the caret.
  static const double _lockSize = 13;

  /// The module and its lessons.
  final PathModule module;

  /// Whether the module is open right now. A locked one never is: it has no
  /// lessons to show and no caret to ask with.
  final bool isExpanded;

  /// Opens or shuts the module.
  final VoidCallback onToggle;

  /// The module before this one, named by a locked row as what opens it.
  final String? previousTitle;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final locked = module.density == PathModuleDensity.locked;
    final canCollapse = module.density.canCollapse;

    return Padding(
      padding: const EdgeInsets.only(bottom: _sectionGap),
      child: Disclosure(
        isOpen: isExpanded && canCollapse,
        collapsible: canCollapse,
        onToggle: _headerTap(context),
        semanticsLabel: _semanticsLabel(),
        glyphSize: DisclosureMark.sectionCaretSize,
        headerPadding: EdgeInsets.zero,
        panelPadding: const EdgeInsets.only(top: AppSpacing.xs),
        header: Row(
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
          ],
        ),
        trailing: locked ? _LockMark(module: module, size: _lockSize) : null,
        below: _SubLine(module: module, previousTitle: previousTitle),
        child: _Lessons(module: module),
      ),
    );
  }

  /// What a tap on the heading does, or null where it does nothing.
  ///
  /// The one locked row that answers a tap is the purchase: it is where
  /// someone who has not bought the course meets the wall, so it offers the
  /// way past instead of the lessons.
  VoidCallback? _headerTap(BuildContext context) {
    if (module.isPurchaseLocked) {
      return () =>
          unawaited(showPlusGate(context, LockedModule(title: module.title)));
    }
    return module.density.canCollapse ? onToggle : null;
  }

  /// What a screen reader hears in place of the heading's own parts, or null
  /// where they read well enough on their own.
  ///
  /// Completion is the one thing a finished module does not say out loud: the
  /// design signals it by *removing* the lesson-count line.
  String? _semanticsLabel() {
    if (module.isPurchaseLocked) {
      return LockedRowCopy.purchaseLockedSemantics(module.title);
    }
    return module.density == PathModuleDensity.complete
        ? AppLabels.moduleCompleteSemantics(module.title)
        : null;
  }
}

/// The lock on a module that is out of reach, in the ink its reason earns.
class _LockMark extends StatelessWidget {
  const _LockMark({required this.module, required this.size});

  final PathModule module;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    // Accent for the purchase, ink-mute for progression. Accent means there is
    // something to do, and buying is the one they can do now.
    return IconMark(
      AppIcon.lock,
      size: size,
      color: module.isPurchaseLocked ? mood.accent : mood.inkMute,
      semanticLabel: module.isPurchaseLocked
          ? LockedRowCopy.partOfFoundations
          : null,
    );
  }
}

/// The mono line under a module's title. Only a locked module has one: an
/// active module lists its lessons instead, and a finished one says nothing.
class _SubLine extends StatelessWidget {
  const _SubLine({required this.module, required this.previousTitle});

  final PathModule module;
  final String? previousTitle;

  @override
  Widget build(BuildContext context) {
    final line = _text();
    if (line == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xs,
        left: ModuleGlyph.titleInset,
      ),
      // Uppercase is the type rule, not part of what the line says, so the
      // reader is given it as written — the same split `SmallcapsLabel` makes.
      child: Semantics(
        label: line,
        excludeSemantics: true,
        child: Text(
          line.toUpperCase(),
          style: AppText.micro(mood: context.mood),
        ),
      ),
    );
  }

  /// When a module is locked both ways the purchase wins: someone who has not
  /// bought the course will never finish the module before it, so naming that
  /// module is advice they cannot take. ADR-0016.
  String? _text() {
    if (!module.density.isLocked) return null;
    if (module.isPurchaseLocked) {
      return LockedRowCopy.purchasedModule(module.totalCount);
    }
    return previousTitle == null
        ? LockedRowCopy.moduleSize(module.totalCount)
        : LockedRowCopy.finishToUnlock(previousTitle!);
  }
}

/// The lesson list a module opens onto.
class _Lessons extends StatelessWidget {
  const _Lessons({required this.module});

  final PathModule module;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < module.lessons.length; i++)
          PathLessonRow(
            entry: module.lessons[i],
            isLast: i == module.lessons.length - 1,
          ),
        // The module's Coffee Challenge — Path is the only place a challenge
        // appears outside Today. Inside the panel, as the design nests it: a
        // finished module that is shut is not still offering its brew.
        if (!module.density.isLocked) PathChallengeNode(moduleId: module.id),
      ],
    );
  }
}
