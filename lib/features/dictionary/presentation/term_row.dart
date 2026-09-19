import 'dart:async';

import 'dart:math' as math;

import 'package:brew_path/core/swipe/horizontal_swipe.dart';
import 'package:brew_path/core/swipe/swipe_hint.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_status_style.dart';
import 'package:brew_path/features/dictionary/presentation/status_mark.dart';
import 'package:brew_path/features/dictionary/presentation/term_save_track.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/features/saved/presentation/saved_toggle.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One term in a list: its status mark, its name and respelling, its meaning,
/// and — only once saved — the bookmark that takes it off the shelf.
///
/// **The whole row is the target, for both the tap and the drag**, but the row
/// itself is not the button: a row that is a button prunes the nested bookmark
/// from the accessibility tree, and that bookmark is the only way to un-save.
class TermRow extends ConsumerWidget {
  /// Creates a [TermRow].
  const TermRow({
    required this.term,
    required this.status,
    required this.onTap,
    this.nudge = 0,
    this.onSaved,
    super.key,
  });

  /// A row commits at 64 and moves at most 120, and **never flies off** — it
  /// is still in the list afterwards, saved.
  static const SwipeMotion _motion = SwipeMotion(
    commitThreshold: 64,
    maxDrag: 120,
  );

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

  /// Where the first-run hint has this row, or 0 for every row it is not
  /// teaching on.
  final double nudge;

  /// Called once a swipe has saved the term, so the hint can retire.
  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedKey = formatSavedKey(SavedKind.term, term.id);
    final isSaved = ref.watch(isKeySavedProvider(savedKey)).value ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: ClipRect(
        child: HorizontalSwipe(
          motion: _motion,
          // Save-only: losing a curated list to a stray 70px drag is exactly
          // the destructive case the direction contract keeps off gestures.
          canAdvance: false,
          canBack: !isSaved,
          onBack: () {
            onSaved?.call();
            unawaited(toggleSavedKey(context, ref, savedKey));
          },
          behind: (context, drag) => TermSaveTrack(
            travel: math.max(drag.travel, nudge),
            isSaved: isSaved,
          ),
          builder: (context, drag) => SwipeNudge(
            offset: nudge,
            child: _row(context, savedKey: savedKey, isSaved: isSaved),
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String savedKey,
    required bool isSaved,
  }) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.mood.bg,
      border: Border(bottom: BorderSide(color: context.mood.rule)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: _rowPad),
      child: Stack(
        children: [
          // Behind the content and stretched over the whole row, so the
          // padding and the gaps answer the tap as well as the drag.
          Positioned.fill(
            child: Semantics(
              button: true,
              // The mark is a shape; the label is what carries the state.
              label: '${term.term}, ${status.label}',
              excludeSemantics: true,
              onTap: onTap,
              child: InkWell(onTap: onTap),
            ),
          ),
          Row(
            children: [
              // Above the tap target in paint order, so it must let the taps
              // it does not want fall through to it.
              ExcludeSemantics(
                child: IgnorePointer(
                  child: Row(
                    children: [
                      SizedBox(
                        width: _markColumn,
                        child: Center(child: StatusMark(status: status)),
                      ),
                      const SizedBox(width: _markGap),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ExcludeSemantics(
                  child: IgnorePointer(child: _Words(term: term)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox.square(
                dimension: _bookmarkSlot,
                child: OverflowBox(
                  maxWidth: _bookmarkTarget,
                  maxHeight: _bookmarkTarget,
                  child: isSaved
                      ? SavedBookmarkButton(
                          savedKey: savedKey,
                          label: term.term,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
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
