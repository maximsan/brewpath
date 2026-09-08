import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// One collapsible group of the practice shelf — *Lessons* or *Games* — with
/// its count beside the name and its rows under it once opened.
///
/// **Closed on arrival.** The design opens neither group by default: the shelf
/// is a list of things the learner *could* do, and two long lists under the
/// day's one lesson would bury the ask. The count is what tells them the group
/// is worth opening.
///
/// The header is the whole tappable row, and the caret turns over the design's
/// `240ms` as the rows appear — or at once when the platform asks for reduced
/// motion.
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

  /// The design's `transition: transform 240ms` on the caret.
  static const Duration turnDuration = Duration(milliseconds: 240);

  @override
  State<PracticeGroup> createState() => _PracticeGroupState();
}

class _PracticeGroupState extends State<PracticeGroup> {
  /// The caret's drawn size — the design's `width="18"`.
  static const double _caretSize = 18;

  /// Half a turn: the caret points down closed and up open.
  static const double _openTurns = 0.5;

  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          label: '${widget.label}, ${widget.count}',
          excludeSemantics: true,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              // The design's `padding: 16px 0` at the page gutter; the shelf
              // sits a row's bleed inside it, which the sides make up.
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Text(
                    widget.label,
                    style: AppText.body(mood: mood, face: AppFace.control),
                  ),
                  SizedBox(width: OffTokens.practiceInlineGap.value),
                  Text(
                    '${widget.count}',
                    style: AppText.micro(
                      mood: mood,
                      tracking: AppTracking.hint,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _open ? _openTurns : 0,
                    duration: reduceMotion
                        ? Duration.zero
                        : PracticeGroup.turnDuration,
                    curve: Curves.easeInOut,
                    child: IconMark(
                      AppIcon.caret,
                      size: _caretSize,
                      color: mood.inkMute,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: EdgeInsets.only(bottom: OffTokens.practiceGroupFoot.value),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.children,
            ),
          ),
        if (!widget.isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Divider(height: 1, color: mood.rule),
          ),
      ],
    );
  }
}
