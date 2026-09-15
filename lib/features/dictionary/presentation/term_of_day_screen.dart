import 'dart:async';

import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/float_topbar.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/scroll_flag_scope.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/dictionary/domain/term_of_day_providers.dart';
import 'package:brew_path/features/dictionary/presentation/speak_button.dart';
import 'package:brew_path/features/dictionary/presentation/term_of_day_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The design's `Roasty size={120}` over the word.
const double _companionSize = 120;

/// Where the design opens this page, measured from the top of the screen —
/// `padding-top: 84`, shorter because it opens on a kicker rather than a run.
const double _designScrollPad = 84;

/// The design's `width: 28` rule either side of the dateline.
const double _datelineRuleWidth = 28;

/// The design's `44px` above Roasty and `34px` below, which is what makes the
/// mascot read as its own beat rather than a badge on the heading.
const double _companionSpaceAbove = 44;
const double _companionSpaceBelow = 34;

/// Today's term, on a page of its own.
///
/// Reached from the dictionary's banner. The screen holds no state: the term
/// is a function of the day and the tier, so leaving and coming back on the
/// same day lands on the same word.
class TermOfDayScreen extends ConsumerWidget {
  /// Creates a [TermOfDayScreen].
  const TermOfDayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(termOfDayViewProvider);

    return ScrollFlagScope(
      builder: (context, {required isScrolled}) => FloatBarScaffold(
        bar: FloatTopbar(
          icon: AppIcon.close,
          label: AppLabels.close,
          onPressed: context.pop,
          isScrolled: isScrolled,
          trailing: switch (view.asData?.value) {
            final resolved? => SavedBookmarkButton(
              savedKey: formatSavedKey(SavedKind.term, resolved.term.id),
              label: resolved.term.term,
              ringed: true,
            ),
            null => null,
          },
        ),
        child: view.when(
          loading: () => Semantics(
            label: "Loading today's term",
            child: const LoadingIndicator(),
          ),
          error: (error, _) => Semantics(
            label: "Today's term could not be loaded",
            child: ErrorView(message: '$error'),
          ),
          // Nothing to offer: the pool is empty, which the banner that leads
          // here would already have hidden itself for. Reachable only by a
          // deep link, so it says so rather than showing an empty page.
          data: (resolved) => resolved == null
              ? const ErrorView(message: 'There is no term for today.')
              : _TermOfDay(view: resolved),
        ),
      ),
    );
  }
}

class _TermOfDay extends StatelessWidget {
  const _TermOfDay({required this.view});

  final TermOfDayView view;

  /// Where *Read the full entry* goes.
  ///
  /// **The label promises the full entry**, so a learner without the course
  /// gets the gate rather than the entry: delivering the short explanation
  /// they are already reading would make the button a lie, and the design says
  /// so in its own comment.
  Future<void> _readFullEntry(BuildContext context) => view.hasCourse
      ? context.pushDictionaryTerm(view.term.id)
      : showPlusGate(context, LockedFullEntry(term: view.term.term));

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final term = view.term;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: FloatTopbar.scrollPadding(
              context,
              designScrollPad: _designScrollPad,
              inset: AppSpacing.gutter,
            ),
            child: Column(
              children: [
                SmallcapsLabel(TermOfDayCopy.title, color: mood.accent),
                const SizedBox(height: AppSpacing.xs),
                _Dateline(date: view.date),
                const SizedBox(height: _companionSpaceAbove),
                const Roasty(state: RoastyState.correct, size: _companionSize),
                const SizedBox(height: _companionSpaceBelow),
                Text(
                  term.term,
                  textAlign: TextAlign.center,
                  style: AppText.display(mood: mood),
                ),
                if (term.pronunciation != null) ...[
                  const SizedBox(height: AppSpacing.base),
                  SpeakButton(word: term.term, respelling: term.pronunciation!),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(
                  term.shortExplanation,
                  textAlign: TextAlign.center,
                  style: AppText.lead(mood: mood),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            0,
            AppSpacing.gutter,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              PrimaryButton(
                label: TermOfDayCopy.readFullEntry,
                onPressed: () => unawaited(_readFullEntry(context)),
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: context.pop,
                  child: const Text(TermOfDayCopy.back),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The date, framed by the app's own hairline turned sideways.
///
/// It gives the composition a top edge without adding a new treatment: the
/// rule is the separator every other screen already uses, at a different angle.
class _Dateline extends StatelessWidget {
  const _Dateline({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final rule = SizedBox(
      width: _datelineRuleWidth,
      child: Divider(height: 1, thickness: 1, color: context.mood.rule),
    );

    // The rules are the design's fixed 28; the date is what gives when a long
    // weekday and month meet a narrow screen.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        rule,
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: SmallcapsLabel(longDate(date))),
        const SizedBox(width: AppSpacing.sm),
        rule,
      ],
    );
  }
}
