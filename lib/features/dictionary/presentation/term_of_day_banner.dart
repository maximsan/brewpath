import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/domain/term_of_day_providers.dart';
import 'package:brew_path/features/dictionary/presentation/term_of_day_copy.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The design's `CatGlyph size={22}` in the banner's top corner.
const double _glyphSize = 22;

/// The design's 14×10 arrow after *Open entry*.
const double _arrowSize = 14;

/// The banner's own radius — `borderRadius: 16`, inside the 12–20 slack the
/// design system allows a component that needs one of its own.
const double _bannerRadius = 16;

/// How much accent the border carries over the rule — the design's
/// `color-mix(in oklab, var(--accent) 24%, var(--rule))`.
const double _borderAccent = 0.24;

/// Where the wash has finished giving way to the surface — the design's
/// second gradient stop at `62%`.
const double _washEnd = 0.62;

/// The design's `linear-gradient(158deg, …)`, as the two ends of that line.
/// 158° from north is a fall that is mostly downward and leans right.
const Alignment _washFrom = Alignment(-0.375, -0.927);
const Alignment _washTo = Alignment(0.375, 0.927);

/// Today's term, offered on the dictionary's index.
///
/// **Silent when there is nothing to offer.** An empty pool is not an error
/// state and gets no apology: the shelf below it is the screen's actual
/// content, and a banner explaining its own absence would be the loudest thing
/// on the page. `TermOfDayBanner` returns nothing, exactly as the design's own
/// `if (!term) return null` does.
class TermOfDayBanner extends ConsumerWidget {
  /// Creates a [TermOfDayBanner].
  const TermOfDayBanner({required this.onOpen, super.key});

  /// Opens the term's own screen.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(termOfDayViewProvider).asData?.value;
    return view == null
        ? const SizedBox.shrink()
        : _Banner(term: view.term, onOpen: onOpen);
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.term, required this.onOpen});

  final DictionaryTerm term;
  final VoidCallback onOpen;

  /// One announcement, in the order the card reads: what it is, the word, and
  /// what the word means. The *Open entry* footer is left out — the label
  /// below already says this is a button, and reading the affordance twice is
  /// how a card starts sounding like a form.
  String get _announcement =>
      '${TermOfDayCopy.title}. ${term.term}. ${term.shortExplanation}';

  /// The card's own frame: the accent-tinted rule, the wash falling to the
  /// surface, and the lift that sets it above the rows below.
  BoxDecoration _frame(MoodColors mood) => BoxDecoration(
    borderRadius: BorderRadius.circular(_bannerRadius),
    border: Border.all(
      color: Color.alphaBlend(
        mood.accent.withValues(alpha: _borderAccent),
        mood.rule,
      ),
    ),
    gradient: LinearGradient(
      begin: _washFrom,
      end: _washTo,
      colors: [mood.accentWash, mood.surface],
      stops: const [0, _washEnd],
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x2E000000),
        blurRadius: 34,
        offset: Offset(0, 14),
      ),
    ],
  );

  /// What this is, and which corner of the shelf it came from.
  Widget _kicker(Color accent) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(child: SmallcapsLabel(TermOfDayCopy.title, color: accent)),
      IconMark(moduleMark(term.categoryId), size: _glyphSize, color: accent),
    ],
  );

  /// The word and how to say it.
  Widget _word(MoodColors mood) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(term.term, style: AppText.display(mood: mood)),
      if (term.pronunciation != null) ...[
        const SizedBox(height: AppSpacing.xs),
        Text(
          term.pronunciation!,
          style: AppText.label(color: mood.inkMute, face: AppFace.mono),
        ),
      ],
    ],
  );

  /// What a tap does, said in the design's own words.
  Widget _footer(Color accent) => Row(
    children: [
      SmallcapsLabel(TermOfDayCopy.openEntry, color: accent),
      const SizedBox(width: AppSpacing.xs),
      IconMark(AppIcon.arrow, size: _arrowSize, color: accent),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      label: _announcement,
      // **The action, not just the flag.** `excludeSemantics` drops the
      // InkWell's own semantics along with the text's, and a node that says
      // "button" without carrying a tap leaves a screen reader announcing
      // something it cannot then press. Measured: the shared `BorderedTapRow`
      // builds such a node today (see #487).
      onTap: onOpen,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: _frame(mood),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(_bannerRadius),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                OffTokens.termOfDayBannerPadding.value,
                OffTokens.termOfDayBannerPadding.value,
                OffTokens.termOfDayBannerPadding.value,
                OffTokens.termOfDayBannerFootPadding.value,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kicker(mood.accent),
                  const SizedBox(height: AppSpacing.base),
                  _word(mood),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    term.shortExplanation,
                    style: AppText.body(color: mood.inkMute),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _footer(mood.accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
