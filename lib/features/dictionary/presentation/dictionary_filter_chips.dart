import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The three filter chips, each showing how many terms sit behind it.
///
/// The counts come from [DictionaryCounts], where to-learn already excludes
/// reference terms — the number a learner reads has to be a promise the course
/// can keep.
class DictionaryFilterChips extends StatelessWidget {
  /// Creates a [DictionaryFilterChips].
  const DictionaryFilterChips({
    required this.selected,
    required this.counts,
    required this.onSelected,
    super.key,
  });

  /// The filter currently applied.
  final DictionaryFilter selected;

  /// How many terms each filter admits.
  final DictionaryCounts counts;

  /// Called with the filter the learner picked.
  final ValueChanged<DictionaryFilter> onSelected;

  int _countFor(DictionaryFilter filter) => switch (filter) {
    DictionaryFilter.all => counts.all,
    DictionaryFilter.learned => counts.learned,
    DictionaryFilter.toLearn => counts.toLearn,
  };

  static String _labelFor(DictionaryFilter filter) => switch (filter) {
    DictionaryFilter.all => 'All',
    DictionaryFilter.learned => 'Learned',
    DictionaryFilter.toLearn => 'To learn',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Wrap(
        spacing: AppSpacing.xs,
        children: [
          for (final filter in DictionaryFilter.values)
            ChoiceChip(
              label: Text('${_labelFor(filter)} ${_countFor(filter)}'),
              selected: filter == selected,
              onSelected: (_) => onSelected(filter),
            ),
        ],
      ),
    );
  }
}
