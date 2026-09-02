import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A category's name and the mark the design draws beside it.
///
/// One type, because the two travel together everywhere a card names its
/// category — a label that lost its mark would not fail, it would quietly stop
/// matching the dictionary's own rows.
@immutable
class DictionaryCategoryMark {
  /// Creates a [DictionaryCategoryMark].
  const DictionaryCategoryMark({required this.label, required this.mark});

  /// Nothing resolved yet: the deck arrives before the categories do, and a
  /// card is worth more than the kicker over it.
  static const DictionaryCategoryMark unresolved = DictionaryCategoryMark(
    label: '',
    mark: null,
  );

  /// The category's name, as the shelf writes it.
  final String label;

  /// Its glyph.
  final AppIcon? mark;
}

/// The category as a kicker: mark, then name, in the accent.
class CategoryKicker extends StatelessWidget {
  /// Creates a [CategoryKicker].
  const CategoryKicker({
    required this.category,
    required this.size,
    this.color,
    super.key,
  });

  /// What to name.
  final DictionaryCategoryMark category;

  /// The mark's drawn size — the design's `CatGlyph size={15}` on a card face.
  final double size;

  /// Mark and label colour. Defaults to the accent, which is what a card face
  /// uses; Term of the Day's screen names its category in muted ink, under a
  /// kicker that is already carrying the accent.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.mood.accent;
    final mark = category.mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mark != null) ...[
          IconMark(mark, size: size, color: tint),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(child: SmallcapsLabel(category.label, color: tint)),
      ],
    );
  }
}
