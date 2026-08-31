import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_status_style.dart';
import 'package:brew_path/features/dictionary/presentation/status_mark.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// 0.02em at the label rung — the row's respelling is set tighter than the
/// entry's chip, which carries the design's 0.04em.
const double _respellingTracking = 0.22;

/// One term in a list: its name and respelling, its status mark, and its
/// one-line meaning.
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
                  child: StatusMark(status: status),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The respelling sits beside the word, not under it —
                      // it is how the word sounds, not a second fact about it
                      // (`dictionary.jsx:235`). It wraps rather than
                      // truncating, because half a respelling is worse than
                      // none.
                      Wrap(
                        spacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            term.term,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(color: mood.ink),
                          ),
                          if (term.pronunciation != null)
                            Text(
                              term.pronunciation!,
                              style: AppText.label(
                                mood: mood,
                                face: AppFace.mono,
                              ).copyWith(letterSpacing: _respellingTracking),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        term.shortExplanation,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: mood.inkMute),
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
