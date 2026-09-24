import 'package:brew_path/core/widgets/disclosure.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// One collapsible group of the practice list — *Lessons* or *Games* — with
/// its count beside the name and its rows under it once opened.
///
/// Whether it is open is the caller's to say, not the group's own: Keep
/// Sharp's Start opens a group from the card above it, so the answer lives
/// where both the header's tap and that card can reach it.
class PracticeGroup extends StatelessWidget {
  /// Creates a [PracticeGroup].
  const PracticeGroup({
    required this.label,
    required this.count,
    required this.isOpen,
    required this.onToggle,
    required this.children,
    this.isLast = false,
    super.key,
  });

  /// The group's name, as the design sets it: sentence case, not smallcaps.
  final String label;

  /// How many rows the group holds — shown closed, so the list says what it
  /// has without being opened.
  final int count;

  /// Whether the rows are showing.
  final bool isOpen;

  /// What a tap on the header does.
  final VoidCallback onToggle;

  /// The rows, shown only while open.
  final List<Widget> children;

  /// Whether this is the list's last group, which drops the rule under it.
  final bool isLast;

  /// The design's `padding: 16px 0` at the page gutter; the list sits a row's
  /// bleed inside it, which the sides make up.
  static const EdgeInsets _headerPadding = EdgeInsets.symmetric(
    vertical: AppSpacing.md,
    horizontal: AppSpacing.xs,
  );

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Disclosure(
      isOpen: isOpen,
      onToggle: onToggle,
      semanticsLabel: '$label, $count',
      divider: !isLast,
      headerPadding: _headerPadding,
      panelPadding: EdgeInsets.only(bottom: OffTokens.practiceGroupFoot.value),
      header: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppText.body(mood: mood, face: AppFace.control),
          ),
          SizedBox(width: OffTokens.practiceInlineGap.value),
          Text(
            '$count',
            style: AppText.micro(mood: mood, tracking: AppTracking.hint),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
