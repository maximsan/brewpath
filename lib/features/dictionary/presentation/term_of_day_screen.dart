import 'dart:async';
import 'dart:math' as math;

import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/float_topbar.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/scroll_flag_scope.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/dictionary/domain/term_of_day_providers.dart';
import 'package:brew_path/features/dictionary/presentation/speak_button.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The design's `Roasty size={120}` over the word.
const double _companionSize = 120;

/// Where the design opens this page, measured from the top of the screen —
/// `padding-top: 84`, shorter because nothing runs under the bar.
const double _designScrollPad = 84;

/// The design's `width: 28` rule either side of the dateline.
const double _datelineRuleWidth = 28;

/// The design's `44px` above Roasty and `34px` below, which is what makes the
/// mascot read as its own beat rather than a badge on the heading.
const double _companionSpaceAbove = 44;
const double _companionSpaceBelow = 34;

/// The design's `paddingTop: 20` before the definition.
const double _definitionGap = 20;

/// The design's `marginTop: 10` between the two footer buttons.
const double _footerGap = 10;

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
      // The page runs full-bleed to the top, so a long term passes under the
      // close control, the bookmark and the clock well before the default.
      threshold: OffTokens.floatBarScrollFlag.value,
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
            label: context.strings.termOfDayLoading,
            child: const LoadingIndicator(),
          ),
          error: (error, _) => Semantics(
            label: context.strings.termOfDayLoadFailed,
            child: ErrorView(message: '$error'),
          ),
          // Nothing to offer: the pool is empty, which the banner that leads
          // here would already have hidden itself for. Reachable only by a
          // deep link, so it says so rather than showing an empty page.
          data: (resolved) => resolved == null
              ? ErrorView(message: context.strings.termOfDayNone)
              : _TermOfDay(view: resolved),
        ),
      ),
    );
  }
}

/// The term, and nothing about the term: dateline, Roasty, word, how to say
/// it, what it means — centred between the bar and the footer.
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
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final padding = FloatTopbar.scrollPadding(
                context,
                designScrollPad: _designScrollPad,
                inset: AppSpacing.gutter,
              );
              // Centred while it fits, scrolling once it does not: the
              // design's matched flex spacers collapse first when the content
              // is tall enough to need the room.
              return SingleChildScrollView(
                padding: padding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0, box.maxHeight - padding.vertical),
                  ),
                  child: _Composition(view: view),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.md,
            AppSpacing.gutter,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              PrimaryButton(
                label: context.strings.termReadFullEntry,
                onPressed: () => unawaited(_readFullEntry(context)),
              ),
              const SizedBox(height: _footerGap),
              // A dismiss under a primary is a ghost, never a bare link.
              GhostButton(
                label: context.strings.termOfDayBack,
                onPressed: context.pop,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Composition extends StatelessWidget {
  const _Composition({required this.view});

  final TermOfDayView view;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final term = view.term;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
        const SizedBox(height: _definitionGap),
        Text(
          term.shortExplanation,
          textAlign: TextAlign.center,
          style: AppText.lead(mood: mood),
        ),
        const SizedBox(height: AppSpacing.lg),
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
    final mood = context.mood;
    final rule = SizedBox(
      width: _datelineRuleWidth,
      child: Divider(height: 1, thickness: 1, color: mood.rule),
    );

    // The rules are the design's fixed 28; the date is what gives when a long
    // weekday and month meet a narrow screen. Mono at `letterSpacing: 0.1em`,
    // uppercase by rule and announced as written.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        rule,
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Semantics(
            label: longDate(date),
            excludeSemantics: true,
            child: Text(
              longDate(date).toUpperCase(),
              style: AppText.label(
                mood: mood,
                face: AppFace.mono,
                tracking: AppTracking.tag,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        rule,
      ],
    );
  }
}
