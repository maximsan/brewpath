import 'package:brew_path/core/widgets/disclosure.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// One collapsible group of the practice shelf — *Lessons* or *Games* — with
/// its count beside the name and its rows under it once opened.
///
/// **Closed on arrival.** The design opens neither group by default: two long
/// lists under the day's one lesson would bury the ask, and the count is what
/// tells a learner the group is worth opening.
class PracticeGroup extends StatefulWidget {
  /// Creates a [PracticeGroup].
  const PracticeGroup({
    required this.label,
    required this.count,
    required this.children,
    this.isLast = false,
    super.key,
  });

  /// The group's name, as the design sets it: sentence case, not smallcaps.
  final String label;

  /// How many rows the group holds — shown closed, so the shelf says what it
  /// has without being opened.
  final int count;

  /// The rows, shown only while open.
  final List<Widget> children;

  /// Whether this is the shelf's last group, which drops the rule under it.
  final bool isLast;

  @override
  State<PracticeGroup> createState() => _PracticeGroupState();
}

class _PracticeGroupState extends State<PracticeGroup> {
  /// The design's `padding: 16px 0` at the page gutter; the shelf sits a row's
  /// bleed inside it, which the sides make up.
  static const EdgeInsets _headerPadding = EdgeInsets.symmetric(
    vertical: AppSpacing.md,
    horizontal: AppSpacing.xs,
  );

  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Disclosure(
      isOpen: _open,
      onToggle: _toggle,
      semanticsLabel: '${widget.label}, ${widget.count}',
      divider: !widget.isLast,
      headerPadding: _headerPadding,
      panelPadding: EdgeInsets.only(bottom: OffTokens.practiceGroupFoot.value),
      header: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: AppText.body(mood: mood, face: AppFace.control),
          ),
          SizedBox(width: OffTokens.practiceInlineGap.value),
          Text(
            '${widget.count}',
            style: AppText.micro(mood: mood, tracking: AppTracking.hint),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.children,
      ),
    );
  }
}
