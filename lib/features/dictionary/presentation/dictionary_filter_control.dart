import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The dictionary's filter: **one segmented control**, not three loose chips.
///
/// One pill divided in three says the three are one choice. The design's
/// `DictFilter`: a `1px var(--rule)` frame at `borderRadius: 12` on the
/// surface, the chosen segment filled accent, the labels uppercase at the
/// label rung. No counts — the index sums them, and a category shows its own.
class DictionaryFilterControl extends StatelessWidget {
  /// Creates a [DictionaryFilterControl].
  const DictionaryFilterControl({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// The design's `borderRadius: 12` and `padding: 9px 4px`.
  static const double _radius = 12;
  static const EdgeInsets _segmentPadding = EdgeInsets.symmetric(
    vertical: 9,
    horizontal: AppSpacing.xxs,
  );

  /// The filter currently applied.
  final DictionaryFilter selected;

  /// Called with the filter the learner picked.
  final ValueChanged<DictionaryFilter> onSelected;

  static String _labelFor(AppLocalizations strings, DictionaryFilter filter) =>
      switch (filter) {
        DictionaryFilter.all => strings.filterAll,
        DictionaryFilter.learned => strings.statusLearned,
        DictionaryFilter.toLearn => strings.statusToLearn,
      };

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: SegmentedButton<DictionaryFilter>(
        // No tick beside the label: the fill already says which is chosen.
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          backgroundColor: mood.surface,
          foregroundColor: mood.inkMute,
          selectedBackgroundColor: mood.accent,
          selectedForegroundColor: mood.accentInk,
          side: BorderSide(color: mood.rule),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          padding: _segmentPadding,
          textStyle: AppText.label(
            mood: mood,
            face: AppFace.control,
            tracking: AppTracking.tag,
          ),
        ),
        segments: [
          for (final filter in DictionaryFilter.values)
            ButtonSegment<DictionaryFilter>(
              value: filter,
              // Uppercase is the type rule, not the name: announced as written.
              label: Semantics(
                label: _labelFor(context.strings, filter),
                excludeSemantics: true,
                child: Text(
                  _labelFor(context.strings, filter).toUpperCase(),
                ),
              ),
            ),
        ],
        selected: {selected},
        onSelectionChanged: (picked) => onSelected(picked.first),
      ),
    );
  }
}
