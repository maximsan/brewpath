import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/disclosure_mark.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/disclosure.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The second level of the practice list: a module's finished lessons, or a
/// kind's games, behind a header carrying the mark and name the rows no
/// longer repeat.
///
/// A locked sub-group — every game in it behind the purchase — keeps its
/// rows: each one is an offer, and the lock on the header only says so early.
class PracticeSubGroup extends StatefulWidget {
  /// Creates a [PracticeSubGroup].
  const PracticeSubGroup({
    required this.label,
    required this.count,
    required this.children,
    this.mark,
    this.locked = false,
    this.openAtFirst = false,
    super.key,
  });

  /// The header's name, lettered as smallcaps and announced as written.
  final String label;

  /// How many rows the sub-group holds, which only a screen reader is told.
  final int count;

  /// The mark in the header's first column — the module's glyph, the kind's.
  final Widget? mark;

  /// Whether nothing under the header opens without the course.
  final bool locked;

  /// Whether the rows show on arrival. The design shuts every sub-group but
  /// a lone module's.
  final bool openAtFirst;

  /// The rows, shown only while open.
  final List<Widget> children;

  /// The design's `width: 20` column the mark is centred in.
  static const double markColumn = 20;

  /// The design draws the mark at `size={18}` inside that column.
  static const double markSize = 18;

  /// The design's `minHeight: 44` on the header — a tap target.
  static const double _headerMinHeight = 44;

  /// The design's `paddingLeft: 34` under the header, which puts a row's
  /// text past the mark column and the gap beside it.
  static const double _panelIndent = 34;

  /// The design's `paddingBottom: 4` under the last row.
  static const double _panelFoot = 4;

  /// The design's `opacity: 0.55` on a locked header's label.
  static const double _lockedLabelOpacity = 0.55;

  /// The design's `<IconLock/>`, `width="18"`.
  static const double _lockSize = 18;

  /// The design's `padding: '12px 0'` at the page gutter; the list sits a
  /// row's bleed inside it, which the sides make up.
  static const EdgeInsets _headerPadding = EdgeInsets.symmetric(
    vertical: AppSpacing.sm,
    horizontal: AppSpacing.xs,
  );

  @override
  State<PracticeSubGroup> createState() => _PracticeSubGroupState();
}

class _PracticeSubGroupState extends State<PracticeSubGroup> {
  late bool _open = widget.openAtFirst;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Disclosure(
      isOpen: _open,
      onToggle: _toggle,
      semanticsLabel: _announcement,
      glyphSize: DisclosureMark.sectionCaretSize,
      headerPadding: PracticeSubGroup._headerPadding,
      headerMinHeight: PracticeSubGroup._headerMinHeight,
      trailingGap: AppSpacing.base,
      panelPadding: const EdgeInsets.only(
        left: PracticeSubGroup._panelIndent,
        bottom: PracticeSubGroup._panelFoot,
      ),
      header: Row(
        children: [
          SizedBox(
            width: PracticeSubGroup.markColumn,
            child: Center(child: widget.mark),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Opacity(
              opacity: widget.locked ? PracticeSubGroup._lockedLabelOpacity : 1,
              child: SmallcapsLabel(widget.label),
            ),
          ),
        ],
      ),
      trailing: widget.locked
          ? IconMark(
              AppIcon.lock,
              size: PracticeSubGroup._lockSize,
              color: mood.inkMute,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.children,
      ),
    );
  }

  /// The design's `aria-label`: the name, the count, and — for a locked
  /// sub-group — the locked-row register's words (ADR-0016).
  String get _announcement {
    final count = widget.count;
    final items = count == 1 ? 'item' : 'items';
    final lockedWords = widget.locked
        ? ' ${LockedRowCopy.partOfFoundations}.'
        : '';
    return '${widget.label}. $count $items.$lockedWords';
  }
}
