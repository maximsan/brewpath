import 'package:brew_path/features/dictionary/presentation/search_mark.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The design's search mark, at its drawn size.
const double _searchMarkSize = 17;

/// The shelf's search field, under the masthead and over the filters.
class DictionarySearchField extends StatelessWidget {
  /// Creates a [DictionarySearchField].
  const DictionarySearchField({required this.onChanged, super.key});

  /// Called with the query as it is typed.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.sm,
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search terms, e.g. crema, bloom…',
          prefixIcon: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: SearchMark(size: _searchMarkSize, color: mood.inkMute),
          ),
          prefixIconConstraints: const BoxConstraints.tightFor(
            width: _searchMarkSize + AppSpacing.md,
            height: _searchMarkSize + AppSpacing.md,
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
