import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The glyph's drawn size in the index.
const double _glyphSize = 22;

/// Vertical room in a row, which the design sets outside the spacing scale's
/// rungs at 15 — between [AppSpacing.base] and [AppSpacing.md], and close
/// enough to either that snapping is invisible.
const double _rowPadding = AppSpacing.md;

/// The way into a category: its mark, its name, what it covers, and how many
/// terms sit behind it.
///
/// The index is how the design opens the dictionary — a learner arrives
/// wanting a subject, not a scroll of every term. Tapping a row filters to it.
///
/// The count is the row's point as much as the name: it says whether a subject
/// is worth opening before the learner opens it.
class CategoryIndex extends StatelessWidget {
  /// Creates a [CategoryIndex].
  const CategoryIndex({
    required this.categories,
    required this.terms,
    required this.onOpen,
    super.key,
  });

  /// The categories, in bank order.
  final List<DictionaryCategory> categories;

  /// Every term this learner can see, for the per-category counts.
  final List<DictionaryTerm> terms;

  /// Called with the category the learner picked.
  final ValueChanged<DictionaryCategory> onOpen;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    // Grouped by the same rule the list uses, so a category with nothing
    // behind it for this tier is absent rather than a row that opens onto an
    // empty shelf.
    final grouped = groupByCategory(terms, categories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in grouped.entries)
          _CategoryRow(
            category: entry.key,
            count: entry.value.length,
            onOpen: () => onOpen(entry.key),
            mood: mood,
          ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.count,
    required this.onOpen,
    required this.mood,
  });

  final DictionaryCategory category;
  final int count;
  final VoidCallback onOpen;
  final MoodColors mood;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${category.label}, $count terms. ${category.summary}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: _rowPadding),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: mood.rule)),
          ),
          child: Row(
            children: [
              IconMark(
                moduleMark(category.id),
                size: _glyphSize,
                color: mood.inkMute,
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.label,
                      style: AppText.body(mood: mood, face: AppFace.control),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      category.summary,
                      style: AppText.support(mood: mood, color: mood.inkMute),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$count',
                style: AppText.label(
                  mood: mood,
                  face: AppFace.mono,
                  color: mood.inkMute,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
