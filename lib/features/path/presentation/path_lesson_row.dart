import 'dart:async';

import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/bean_gauge.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/features/path/domain/lesson_node_gauge.dart';
import 'package:brew_path/features/path/domain/path_module_view.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A lesson on the path: a bean on the spine, its title, and what the row has
/// to say about it.
///
/// **The row is not a card.** The design draws `.lesson-row` as a flat row on a
/// hairline, threaded by a 1px spine that the bean discs punch stops out of —
/// that continuous line is what makes a list of lessons read as a *path*.
/// Cards would break it into separate objects, which is what this looked like
/// until [#435](https://github.com/maximsan/brewpath/issues/435).
///
/// It carries the title and one meta word, and deliberately not the lesson's
/// minutes or points: those belonged to the module screen, where a lesson was
/// being chosen. Here the course is the subject and the row is a step in it.
class PathLessonRow extends StatelessWidget {
  /// Creates a [PathLessonRow].
  const PathLessonRow({
    required this.entry,
    required this.isLast,
    super.key,
  });

  /// The lesson and the learner's progress through it.
  final PathLesson entry;

  /// Whether this is the module's last row, which drops its hairline so the
  /// list does not end on a rule with nothing under it.
  final bool isLast;

  /// The design's `.lesson-row` padding — `18px 0`, generous because the row
  /// has no card to give it room.
  static const double _rowPadding = 18;

  /// Where the spine runs: `.lesson-row::before`'s `left: 15.5px`, which is the
  /// centre of the 32-px node column.
  static const double _spineLeft = 15.5;
  static const double _spineWidth = 1;

  /// The wash behind the current row, and behind its node — the design's
  /// `color-mix(in oklab, var(--accent) 7%, …)`.
  static const double _currentWash = 0.07;

  /// The design's `gap: 14px` between the node column and the title.
  static const double _columnGap = 14;

  /// The design's `.lesson-row.locked { opacity: 0.4 }`. The whole row fades,
  /// mark included, so the lock reads as something about the row.
  static const double _lockedOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final lesson = entry.lesson;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: entry.readsAsCurrent
            ? mood.accent.withValues(alpha: _currentWash)
            : null,
        // The current row drops its rule too: the wash already separates it,
        // and a line under a highlighted row reads as a second edge.
        border: Border(
          bottom: BorderSide(
            color: isLast || entry.readsAsCurrent
                ? Colors.transparent
                : mood.rule,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Behind everything, and masked into stops by each node's own disc.
          Positioned(
            left: _spineLeft,
            top: 0,
            bottom: 0,
            width: _spineWidth,
            child: ColoredBox(color: mood.rule),
          ),
          _row(context, lesson.title),
        ],
      ),
    );
  }

  /// The tappable row itself.
  ///
  /// A purchase-locked row stays tappable on purpose. It is where someone
  /// meets the wall, and a dead row would say no without saying what it costs.
  Widget _row(BuildContext context, String title) {
    final locked = entry.isPurchaseLocked;

    final row = InkWell(
      onTap: locked
          ? () => unawaited(showPlusGate(context, LockedLesson(title: title)))
          : () => unawaited(context.goToActivity(lessonRun(entry.lesson.id))),
      child: Opacity(
        opacity: locked ? _lockedOpacity : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: _rowPadding),
          child: Row(
            children: [
              _LessonNode(entry: entry),
              const SizedBox(width: _columnGap),
              Expanded(child: _Title(entry: entry)),
              const SizedBox(width: _columnGap),
              _Meta(entry: entry),
            ],
          ),
        ),
      ),
    );

    if (!locked) return row;

    // One sentence, not three separate nodes. A locked row never shows the
    // CURRENT label, so `excludeSemantics` loses nothing.
    return Semantics(
      button: true,
      label: LockedRowCopy.purchaseLockedSemantics(title),
      excludeSemantics: true,
      child: row,
    );
  }
}

/// The lesson's title, and the eyebrow that names the one the learner is on.
class _Title extends StatelessWidget {
  const _Title({required this.entry});

  final PathLesson entry;

  static const double _eyebrowGap = 2;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          entry.lesson.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.body(mood: mood, face: AppFace.control),
        ),
        // The design hangs this under the title absolutely, so it cannot change
        // the row's height. Laid out in flow here instead: an eyebrow that
        // overlaps its neighbours at a large text size is worse than a row
        // that grows by one line.
        if (entry.readsAsCurrent) ...[
          const SizedBox(height: _eyebrowGap),
          Text(
            AppLabels.currentLesson.toUpperCase(),
            style: AppText.micro(mood: mood, color: mood.accent),
          ),
        ],
      ],
    );
  }
}

/// The right-hand slot: the lock on a row the free tier does not carry, a
/// chevron on the current lesson, the mastery word on one that needs practice,
/// and nothing at all otherwise.
///
/// Nothing is the common case, and it is deliberate — a finished lesson that
/// went well says so by the fill of its bean, not by a second label.
///
/// One lock per row, and this is where it goes. The spine beside it carries
/// no lock of its own, so there is nothing here to double up.
class _Meta extends StatelessWidget {
  const _Meta({required this.entry});

  final PathLesson entry;

  static const double _chevronWidth = 6;
  static const double _chevronHeight = 10;

  /// The design's `<LockMark size={13}/>`.
  static const double _lockSize = 13;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    // Before every other arm: locked is locked, whatever the learner scored
    // before or wherever the course is pointing.
    if (entry.isPurchaseLocked) {
      return Semantics(
        label: LockedRowCopy.partOfFoundations,
        child: IconMark(
          AppIcon.lock,
          size: _lockSize,
          color: mood.accent,
        ),
      );
    }

    if (entry.isCurrent) {
      return SizedBox(
        width: _chevronWidth,
        height: _chevronHeight,
        child: IconMark(AppIcon.chevron, color: mood.accent),
      );
    }

    final band = entry.mastery.band;
    if (entry.isCompleted && band == MasteryBand.needsPractice) {
      return Text(
        band!.short.toUpperCase(),
        style: AppText.label(
          mood: mood,
          color: mood.accent,
          face: AppFace.mono,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// The lesson node: a coffee bean on the page canvas, filled to the lesson's
/// best-score ratio.
///
/// The bean *is* the gauge, so mastery reads as "how full" instead of a word in
/// the margin. Which tone and how full is decided by [lessonNodeGauge]; this
/// widget only turns that decision into mood colours.
///
/// Its disc is painted in the page colour on purpose: that is what masks the
/// spine behind it into a stop.
class _LessonNode extends StatelessWidget {
  const _LessonNode({required this.entry});

  final PathLesson entry;

  /// The design's `.path-node`: a 32-px well in the page canvas colour. The
  /// bean inside keeps [BeanGauge]'s own default, which is the design's 20 px.
  static const double _nodeSize = 32;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final gauge = lessonNodeGauge(
      isComplete: entry.isCompleted,
      isCurrent: entry.isCurrent,
      mastery: entry.mastery,
    );
    final color = switch (gauge.tone) {
      LessonNodeTone.muted => mood.inkMute,
      LessonNodeTone.accent => mood.accent,
      LessonNodeTone.sage => mood.sage,
    };

    return Container(
      width: _nodeSize,
      height: _nodeSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // Opaque either way — a translucent disc would let the spine show
        // through the stop it exists to punch.
        color: entry.readsAsCurrent
            ? Color.alphaBlend(
                mood.accent.withValues(alpha: PathLessonRow._currentWash),
                mood.bg,
              )
            : mood.bg,
        shape: BoxShape.circle,
      ),
      child: BeanGauge(
        fill: gauge.fill,
        color: color,
        muted: mood.inkMute,
        ink: mood.ink,
      ),
    );
  }
}
