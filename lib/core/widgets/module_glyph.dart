import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A module's identity glyph, drawn **bare** — no fill, no rounded rect, no
/// icon well, unlike the `IconBadge` every non-progression badge draws.
///
/// It carries one state only: [MoodColors.inkMute] when the module is locked,
/// [MoodColors.accent] otherwise. The lock mark belongs in the row's trailing
/// slot, and completion is signalled by what the row drops, never by the glyph.
class ModuleGlyph extends StatelessWidget {
  /// Creates a [ModuleGlyph] for the module whose content declares [iconName].
  const ModuleGlyph({
    required this.iconName,
    required this.locked,
    super.key,
  });

  /// The content-defined icon name, resolved through [moduleMark].
  final String iconName;

  /// Whether the module is still locked, which is the only thing the glyph's
  /// colour says.
  final bool locked;

  /// Width of the column the glyph is centred in. The design draws every module
  /// glyph in a fixed 32-px box so the titles beside them line up regardless of
  /// how wide each glyph's own ink runs.
  static const double columnWidth = 32;

  /// Where a line under a module title starts: the glyph column plus the gap
  /// beside it, which is the title's own left edge.
  static const double titleInset = columnWidth + AppSpacing.sm;

  /// The design's module-glyph size.
  static const double _glyphSize = 26;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return SizedBox(
      width: columnWidth,
      child: Center(
        child: IconMark(
          moduleMark(iconName),
          size: _glyphSize,
          color: locked ? mood.inkMute : mood.accent,
        ),
      ),
    );
  }
}
