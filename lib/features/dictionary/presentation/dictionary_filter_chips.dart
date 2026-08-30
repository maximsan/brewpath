import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The dictionary's filter: **one segmented control**, not three loose chips.
///
/// `DictFilter` (`dictionary.jsx:199`) draws a single pill divided in three —
/// which says the three are one choice. Three separate chips say they are
/// three independent toggles, and a learner has to try one to find out.
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
      child: SegmentedButton<DictionaryFilter>(
        // No tick beside the label: the segment is already the selected one
        // by its fill, and the mark costs the count its room on a phone.
        showSelectedIcon: false,
        segments: [
          for (final filter in DictionaryFilter.values)
            ButtonSegment<DictionaryFilter>(
              value: filter,
              label: Text('${_labelFor(filter)} ${_countFor(filter)}'),
            ),
        ],
        selected: {selected},
        onSelectionChanged: (picked) => onSelected(picked.first),
      ),
    );
  }
}
