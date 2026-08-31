import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The kicker and the name, which the design leads the screen with.
class DictionaryMasthead extends StatelessWidget {
  /// Creates a [DictionaryMasthead].
  const DictionaryMasthead({
    required this.terms,
    required this.category,
    required this.onClear,
    super.key,
  });

  /// How many terms the shelf holds, for the kicker.
  final int terms;

  /// The category being browsed, or null on the index.
  final DictionaryCategory? category;

  /// Leaves the category for the index.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmallcapsLabel(
            category == null
                ? DictionaryHomeScreen.kickerFor(terms)
                : DictionaryHomeScreen.title,
            color: mood.accentText,
          ),
          const SizedBox(height: AppSpacing.xxs),
          // Browsing a category, the category is the heading and the shelf's
          // name steps up into the kicker — one heading, always naming where
          // the learner actually is.
          Row(
            children: [
              Expanded(
                child: Text(
                  category?.label ?? DictionaryHomeScreen.title,
                  style: AppText.display(mood: mood),
                ),
              ),
              if (category != null)
                TextButton(
                  onPressed: onClear,
                  child: const Text('All categories'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
