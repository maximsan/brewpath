import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_status_style.dart';
import 'package:brew_path/features/dictionary/presentation/status_mark.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One term in a list: its status mark, its name and respelling, its meaning,
/// and — only once saved — the bookmark that takes it off the shelf.
///
/// The bookmark sits beside the row's tap surface, not inside it: a control
/// inside a control is pruned from the accessibility tree, and this one is the
/// only way to un-save from the list.
class TermRow extends StatelessWidget {
  /// Creates a [TermRow].
  const TermRow({
    required this.term,
    required this.status,
    required this.onTap,
    super.key,
  });

  /// The design's `padding: 13px 0` above and below the row.
  static const double _rowPad = 13;

  /// The design's grid: a `22px` column for the mark, then `gap: 13`.
  static const double _markColumn = 22;
  static const double _markGap = 13;

  /// The design's `marginTop: 3` between the name and its meaning.
  static const double _meaningGap = 3;

  /// The design's `flex: 0 0 18px` slot, reserved whether saved or not so
  /// rows align either way; the control inside overflows it to a 44 target.
  static const double _bookmarkSlot = 18;
  static const double _bookmarkTarget = 44;

  /// The term this row stands for.
  final DictionaryTerm term;

  /// [term]'s status for this learner, already derived.
  final DictionaryStatus status;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: mood.rule)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: _rowPad),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  // The mark is a shape; the label is what carries the state.
                  label: '${term.term}, ${status.label}',
                  excludeSemantics: true,
                  onTap: onTap,
                  child: InkWell(
                    onTap: onTap,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _markColumn,
                          child: Center(child: StatusMark(status: status)),
                        ),
                        const SizedBox(width: _markGap),
                        Expanded(child: _Words(term: term)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox.square(
                dimension: _bookmarkSlot,
                child: OverflowBox(
                  maxWidth: _bookmarkTarget,
                  maxHeight: _bookmarkTarget,
                  child: _SavedMark(term: term),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The name at body weight 500 with its respelling beside it, then the meaning
/// at the support rung, wrapping in full.
class _Words extends StatelessWidget {
  const _Words({required this.term});

  final DictionaryTerm term;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The respelling sits beside the word, not under it — it is how the
        // word sounds, not a second fact about it. It wraps rather than
        // truncating, because half a respelling is worse than none.
        Wrap(
          spacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              term.term,
              style: AppText.body(mood: mood, face: AppFace.control),
            ),
            if (term.pronunciation != null)
              Text(
                term.pronunciation!,
                style: AppText.label(
                  mood: mood,
                  face: AppFace.mono,
                  tracking: AppTracking.reading,
                ),
              ),
          ],
        ),
        const SizedBox(height: TermRow._meaningGap),
        Text(term.shortExplanation, style: AppText.support(mood: mood)),
      ],
    );
  }
}

/// The bookmark, drawn only once the term is saved.
///
/// Ten identical toggles were the heaviest thing on the screen; one filled
/// mark on a saved row is not. It is still a control — the save-only rule
/// belongs to the gesture, not to the button.
class _SavedMark extends ConsumerWidget {
  const _SavedMark({required this.term});

  final DictionaryTerm term;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = formatSavedKey(SavedKind.term, term.id);
    final saved = ref.watch(isKeySavedProvider(key)).asData?.value ?? false;
    if (!saved) return const SizedBox.shrink();
    return SavedBookmarkButton(savedKey: key, label: term.term);
  }
}
