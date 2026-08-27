import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A module's identity glyph, drawn **bare** — no fill, no rounded rect, no
/// icon well.
///
/// The design draws a module row as a glyph on nothing and carries its state in
/// two places only (`prototype/screens.jsx`, `CompactModuleRow` and the Path
/// tab's expandable rows):
///
/// * **lock** is colour — [MoodColors.inkMute] when locked, [MoodColors.accent]
///   otherwise. The glyph itself stays the module's own either way; the lock
///   mark belongs in the row's trailing slot, not here.
/// * **completion is not signalled at all.** A finished module drops its
///   trailing chevron and its lesson-count line instead of lighting up, so the
///   row goes quiet as the user finishes it.
///
/// Contrast `IconBadge`, the filled well every *non*-progression badge draws.
/// The two are deliberately different shapes: a fill here would read as a state
/// the design does not have.
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
  static const double _columnWidth = 32;

  /// The design's module-glyph size.
  static const double _glyphSize = 26;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return SizedBox(
      width: _columnWidth,
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
