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
  const DictionaryMasthead({required this.category, super.key});

  /// The category being browsed, or null on the index.
  final DictionaryCategory? category;

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
      // naming where the learner actually is. The bar's chevron is the way
      // back, so nothing beside the heading offers a second one.
      child: PageLargeTitle(category?.label ?? DictionaryHomeScreen.title),
    );
  }
}
