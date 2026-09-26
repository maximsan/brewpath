import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// How many terms a search turned up, over the results — the mono count the
/// design draws whether or not there are any.
class DictionarySearchCount extends StatelessWidget {
  /// Creates a [DictionarySearchCount].
  const DictionarySearchCount({required this.count, super.key});

  /// How many terms survived the query.
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: OffTokens.searchCountTop.value,
        bottom: AppSpacing.xxs,
        left: AppSpacing.gutter,
        right: AppSpacing.gutter,
      ),
      child: Text(
        context.strings.searchResultCount(count),
        style: AppText.label(
          mood: context.mood,
          face: AppFace.mono,
          tracking: AppTracking.hint,
        ),
      ),
    );
  }
}

/// Shown when a search matches nothing, so the learner knows the word is
/// absent rather than the app broken.
class DictionaryNoMatches extends StatelessWidget {
  /// Creates a [DictionaryNoMatches].
  const DictionaryNoMatches({required this.query, super.key});

  /// What was typed, quoted back so the line is about this search.
  final String query;

  /// The line and its announcement, from one branch so the two cannot drift.
  ///
  /// An empty [query] is the category filter having emptied the list rather
  /// than a search: the design draws no state there, so that case keeps the
  /// words the app already had.
  ({String line, String label}) _copy(AppLocalizations strings) => query.isEmpty
      ? (
          line: strings.searchNoMatchesLine,
          label: strings.searchNoMatchesLabel,
        )
      : (
          line: strings.searchNoMatchesForLine(query),
          label: strings.searchNoMatchesForLabel(query),
        );

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final copy = _copy(context.strings);

    return Semantics(
      label: copy.label,
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.lg,
          left: AppSpacing.gutter,
          right: AppSpacing.gutter,
        ),
        child: Text(
          copy.line,
          style: AppText.support(
            mood: mood,
          ).copyWith(height: OffTokens.emptyStateLeading.value),
        ),
      ),
    );
  }
}
