import 'package:brew_path/core/widgets/page_large_title.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The name the design leads the screen with, and nothing above it.
///
/// Title first, then at most one muted support line, and only where it says
/// something the page does not already show. Neither state here has one: the
/// term total is the sum of the category counts listed below it, and in a
/// category the back chevron already says where the learner came from.
class DictionaryMasthead extends StatelessWidget {
  /// Creates a [DictionaryMasthead].
  const DictionaryMasthead({
    required this.category,
    required this.onClear,
    super.key,
  });

  /// The category being browsed, or null on the index.
  final DictionaryCategory? category;

  /// Leaves the category for the index.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.sm,
      ),
      // Browsing a category, the category is the heading — one heading, always
      // naming where the learner actually is.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: PageLargeTitle(
              category?.label ?? DictionaryHomeScreen.title,
            ),
          ),
          if (category != null)
            TextButton(onPressed: onClear, child: const Text('All categories')),
        ],
      ),
    );
  }
}
