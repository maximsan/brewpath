import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_status_style.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The diameter of the status mark beside a term.
const double _markSize = 10;

/// The width of an unfilled status ring.
const double _markStroke = 1.6;

/// One term in a list: its name, its status mark, and its one-line meaning.
class TermRow extends StatelessWidget {
  /// Creates a [TermRow].
  const TermRow({
    required this.term,
    required this.status,
    required this.onTap,
    super.key,
  });

  /// The term this row stands for.
  final DictionaryTerm term;

  /// [term]'s status for this learner, already derived.
  final DictionaryStatus status;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      // The mark is a shape; the label is what carries the state.
      label: '${term.term}, ${status.label}',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.gutter,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxs),
                  child: _StatusMark(status: status),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        term.term,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: mood.ink),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        term.shortExplanation,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: mood.inkMute),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusMark extends StatelessWidget {
  const _StatusMark({required this.status});

  final DictionaryStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.colorFrom(context.mood);
    return Container(
      width: _markSize,
      height: _markSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: status.isFilled ? color : null,
        border: status.isFilled
            ? null
            : Border.all(color: color, width: _markStroke),
      ),
    );
  }
}
