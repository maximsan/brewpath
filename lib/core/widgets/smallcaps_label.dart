import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The design's one smallcaps rule: IBM Plex Sans 500 at the ladder's label
/// step, 0.14em, uppercase.
///
/// Set in Plex Sans, not mono: the design has both `.smallcaps` (Plex Sans 500)
/// and `.smallcaps-mono`, and the kickers use the former. Mono is for figures
/// and answer-feedback labels.
///
/// The case is applied here rather than in the strings, because uppercase is
/// the type rule and not part of what the thing is called — the same choice the
/// tab bar makes. That means the rendered text is not what the label *says*, so
/// the original casing is what assistive technology is given: announced as
/// written, a short label like `TDS` invites being spelled out letter by
/// letter.
class SmallcapsLabel extends StatelessWidget {
  /// Creates a [SmallcapsLabel].
  const SmallcapsLabel(
    this.text, {
    this.color,
    this.isHeader = false,
    super.key,
  });

  /// The label text (rendered uppercase, announced as written).
  final String text;

  /// Optional text color; defaults to the mood's muted ink.
  final Color? color;

  /// Whether this label heads a section, so assistive technology can offer it
  /// as a navigation stop rather than as loose text.
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      header: isHeader,
      excludeSemantics: true,
      child: Text(
        text.toUpperCase(),
        style: AppText.label(mood: context.mood, color: color),
      ),
    );
  }
}
