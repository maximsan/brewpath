import 'dart:async';

import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/chrome_marks.dart';
import 'package:brew_path/core/icons/disclosure_mark.dart';
import 'package:brew_path/core/widgets/disclosure.dart';
import 'package:brew_path/core/widgets/module_glyph.dart';
import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/path_challenge_node.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/features/path/domain/path_density.dart';
import 'package:brew_path/features/path/domain/path_module_view.dart';
import 'package:brew_path/features/path/presentation/path_lesson_row.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return LockMark(
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

/// The lesson list a module opens onto, with the challenges hung off it: a
/// finished lesson's own Coffee Challenge follows its row, and the module's
/// capstone closes the list.
///
/// Worked out here: which row is last, where the spine ends, and which rows
/// close up to 6 against a challenge row.
class _Lessons extends ConsumerWidget {
  const _Lessons({required this.module});

  final PathModule module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bank =
        ref.watch(challengeBankProvider).asData?.value ??
        const <BrewChallenge>[];
    final capstone = module.density.isLocked
        ? null
        : pathModuleCapstone(ref, module.id);
    final lessons = module.lessons;

    // A lesson's challenge is drawn only once the lesson is done — before that
    // it is not the learner's yet.
    BrewChallenge? challengeOf(PathLesson entry) =>
        entry.isCompleted ? challengeForLesson(bank, entry.lesson.id) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < lessons.length; i++) ...[
          PathLessonRow(
            entry: lessons[i],
            isFirst: i == 0,
            isLast:
                i == lessons.length - 1 &&
                challengeOf(lessons[i]) == null &&
                capstone == null,
            tightAbove: i > 0 && challengeOf(lessons[i - 1]) != null,
            tightBelow: challengeOf(lessons[i]) != null,
          ),
          if (challengeOf(lessons[i]) case final challenge?)
            PathChallengeRow(
              challenge: challenge,
              state: pathChallengeState(
                ref,
                id: challenge.id,
                offerable: true,
              ),
              isLast: i == lessons.length - 1 && capstone == null,
            ),
        ],
        if (capstone != null)
          PathChallengeRow(
            challenge: capstone.challenge,
            state: capstone.state,
            isLast: true,
          ),
      ],
    );
  }
}
