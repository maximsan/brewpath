import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A value the design deliberately sets outside the token system, carrying
/// the design's own declaration as its [reason]. Reading one names it at the
/// call site (`OffTokens.pickTilePadding.value`), so it is never mistaken for
/// a magic literal and never "fixed" onto a token.
@immutable
final class OffToken<T extends Object> {
  /// Records [value] as off-token, for the stated [reason].
  const OffToken(this.value, {required this.reason});

  /// The longest a [reason] may run: one line naming the design declaration.
  static const int maxReasonLength = 120;

  /// The off-token value itself.
  final T value;

  /// The design declaration that sets this value, quoted in backticks so a
  /// test can find it in the prototype.
  final String reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OffToken<T> && other.value == value && other.reason == reason;

  @override
  int get hashCode => Object.hash(value, reason);

  @override
  String toString() => 'OffToken($value, reason: $reason)';
}

/// The sanctioned off-token values, in one place so an exception is reviewed
/// rather than discovered. New entries go here, never in feature code.
abstract final class OffTokens {
  /// The rewarded-ad canvas, near-black in both moods: an ad is a foreign
  /// surface, not a page of the app.
  static const OffToken<Color> rewardedAdCanvas = OffToken(
    Color(0xFF0B0908),
    reason: "the ad screen is `background: '#0b0908'` in both moods",
  );

  /// The countdown ring keeps the Dark Roast accent in both moods, because
  /// the canvas under it is fixed near-black.
  static const OffToken<Color> rewardedAdProgressRing = OffToken(
    Color(0xFFE07A4F),
    reason: "the ring is fixed at `AD_RING = '#E07A4F'`, not the mood accent",
  );

  /// The fruit staining on a naturally processed seed. The design draws it and
  /// never names it, so no `--art-*` token holds it.
  static const OffToken<Color> seedStain = OffToken(
    Color(0xFF6B4A22),
    reason: 'the seed is mottled with `fill="#6B4A22"`',
  );

  /// The cream highlight down a drawn bean's crease, the same in both moods:
  /// a highlight on an object, not a surface of the app.
  static const OffToken<Color> beanCrease = OffToken(
    Color(0xFFFBF7EE),
    reason: 'the crease is stroked `stroke="#FBF7EE"`',
  );

  /// The vertical room inside a `predict` card's guess tile.
  static const OffToken<double> pickTilePadding = OffToken(
    26,
    reason: '`.pick-tile` sets `padding: 26px 14px`',
  );

  /// The vertical room inside a flashcard's face.
  static const OffToken<double> flashcardFacePadding = OffToken(
    26,
    reason: "the card face sets `padding: '26px 24px'`",
  );

  /// The inset on Term of the Day's banner.
  static const OffToken<double> termOfDayBannerPadding = OffToken(
    20,
    reason: "the banner sets `padding: '20px 20px 18px'`",
  );

  /// The banner's shorter bottom inset.
  static const OffToken<double> termOfDayBannerFootPadding = OffToken(
    18,
    reason: "the banner sets `padding: '20px 20px 18px'`",
  );

  /// The padding inside the tried seal, tighter on the mark's side.
  static const OffToken<EdgeInsets> triedSealPadding = OffToken(
    EdgeInsets.fromLTRB(7, 5, 10, 5),
    reason: "the seal sets `padding: '5px 10px 5px 7px'`",
  );

  /// The room Today's lead block keeps above its eyebrow, and under it.
  static const OffToken<double> todayLeadGap = OffToken(
    28,
    reason:
        'the lead block opens at `paddingTop: 28` and its eyebrow sets '
        '`marginBottom: 28`',
  );

  /// The gap above the CTA on Today's card, in every state it has.
  static const OffToken<double> todayCtaGap = OffToken(
    18,
    reason: "the card's button sets `marginTop: 18`",
  );

  /// The gap inside a practice row's inline pairs.
  static const OffToken<double> practiceInlineGap = OffToken(
    10,
    reason: 'the practice shelf pairs a label with its count at `gap: 10`',
  );

  /// The room under an open practice group's last row.
  static const OffToken<double> practiceGroupFoot = OffToken(
    6,
    reason: 'an open practice group closes with `paddingBottom: 6`',
  );

  /// The padding inside the Cards tab's "more to collect" block.
  static const OffToken<EdgeInsets> cardsFooterPadding = OffToken(
    EdgeInsets.symmetric(vertical: 20, horizontal: 18),
    reason: "the block sets `padding: '20px 18px'`",
  );

  /// The gap between the block's count and the line under it.
  static const OffToken<double> cardsFooterLineGap = OffToken(
    2,
    reason: 'the line under the count sets `marginTop: 2`',
  );

  /// How far below the status bar the Path, Learn and Profile titles open,
  /// clear of the header's entries; Cards keeps the design's 24.
  static const OffToken<double> tabTitleClearOfEntries = OffToken(
    64,
    reason: 'the Path tab opens its scroll at `paddingTop: 64`',
  );

  /// The gap the intro screens set between a block and the next one.
  static const OffToken<double> introBlockGap = OffToken(
    28,
    reason: 'the intro sets `marginBottom: 28` under the hero and the lead',
  );

  /// The gap the intro screens set between a question and the line under it.
  static const OffToken<double> introSupportGap = OffToken(
    18,
    reason: "the intro's support line sets `marginTop: 18`",
  );

  /// The gap between a primary CTA and the ghost beneath it.
  static const OffToken<double> ghostUnderPrimaryGap = OffToken(
    10,
    reason: 'a ghost button under a primary sets `marginTop: 10`',
  );

  /// The text field's vertical padding, which is what sets its height.
  static const OffToken<double> textFieldVerticalPadding = OffToken(
    13,
    reason: "the field sets `padding: '13px 16px'`",
  );

  /// The tap cue's letter-spacing in logical pixels at the 11px label step:
  /// the one component set this wide, so it is not a rung of `AppTracking`.
  static const OffToken<double> tapCueTracking = OffToken(
    2.64,
    reason: '`.tap-cue` sets `letter-spacing: 0.24em`',
  );

  /// The gap between a micro-tip's eyebrow and its title.
  static const OffToken<double> microTipEyebrowGap = OffToken(
    5,
    reason: 'the tip title sets `marginTop: 5`',
  );

  /// The gap between a micro-tip's title and its body.
  static const OffToken<double> microTipTitleGap = OffToken(
    3,
    reason: 'the tip body sets `marginTop: 3`',
  );

  /// The letter spacing of a micro-tip's body: prose at the label step, which
  /// otherwise letters at the smallcaps rule.
  static const OffToken<double> microTipBodyTracking = OffToken(
    0,
    reason:
        "the tip body is set at `fontSize: 'var(--t-label)'` with no "
        'letter-spacing',
  );

  /// The leading of a micro-tip's body copy.
  static const OffToken<double> microTipBodyLeading = OffToken(
    1.5,
    reason: 'the tip body sets `lineHeight: 1.5`',
  );

  /// The Tour card's margin — from the screen edges, and from the frame.
  static const OffToken<double> tourCardInset = OffToken(
    20,
    reason:
        'the design sets the Tour card to `left: 20, right: 20`, and the same '
        '20 between it and the frame it explains',
  );

  /// The room inside the Tour card.
  static const OffToken<EdgeInsets> tourCardPadding = OffToken(
    EdgeInsets.fromLTRB(18, 18, 18, AppSpacing.base),
    reason: "the design sets the card to `padding: '18px 18px 14px'`",
  );

  /// The gap between the Tour card's three lines.
  static const OffToken<double> tourCardLineGap = OffToken(
    7,
    reason:
        "the design sets `marginTop: 7` under the card's counter and again "
        'under its title',
  );

  /// The leading of the Tour card's body copy.
  static const OffToken<double> tourCardBodyLeading = OffToken(
    1.55,
    reason: "the design sets the card's body to `lineHeight: 1.55`",
  );

  /// How far the Tour's frame stands off the widget it surrounds.
  static const OffToken<double> tourFrameInset = OffToken(
    6,
    reason:
        'the design insets the frame by 6 a side (`left: rect.x - 6`, '
        '`width: rect.w + 12`)',
  );

  /// The room the tab bar keeps above its tabs, which the Tour's frame leaves
  /// out.
  static const OffToken<double> tabBarTopPad = OffToken(
    8,
    reason: 'the design sets the bar to `padding: 8px 0 28px`',
  );

  /// Where the Tour's card rests until a target has been measured.
  static const OffToken<double> tourCardRestingBottom = OffToken(
    140,
    reason:
        "the design's `bottom: 140` fallback, held until the first target is "
        'measured',
  );

  /// How much room the Tour's card needs under a target before it sits below.
  static const OffToken<double> tourCardHeadroom = OffToken(
    330,
    reason:
        'the design lifts the card above its target at '
        '`(rect.y + rect.h) < (rect.areaH - 330)`',
  );

  /// How far below the feed's top edge the Tour brings a target.
  static const OffToken<double> tourScrollTopGap = OffToken(
    140,
    reason: "the design's `if (topGap < 140)` floor under a framed target",
  );

  /// How much room below a target the Tour keeps clear for its card.
  static const OffToken<double> tourScrollCardClearance = OffToken(
    250,
    reason:
        "the design's `+ 250` when it decides a target has run past the room "
        'the card needs',
  );

  /// The size of one dot in the Tour card's step row.
  static const OffToken<double> tourStepDotSize = OffToken(
    5,
    reason: 'the design draws `width: 5, height: 5` dots set `gap: 5` apart',
  );

  /// The room inside the Tour card's advance pill.
  static const OffToken<EdgeInsets> tourAdvancePadding = OffToken(
    EdgeInsets.symmetric(horizontal: 20, vertical: 11),
    reason: "the design sets Next/Done to `padding: '11px 20px'`",
  );

  /// The room around the Tour card's Skip.
  static const OffToken<EdgeInsets> tourSkipPadding = OffToken(
    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    reason: "the design sets Skip to `padding: '10px 20px'`",
  );

  /// How wide a fill slot stays whatever word lands in it, so a sentence does
  /// not reflow around the answer.
  static const OffToken<double> fillSlotMinWidth = OffToken(
    74,
    reason: 'the blank sets `min-width: 74px`',
  );

  /// The room inside a fill slot, between its word and its rule.
  static const OffToken<EdgeInsets> fillSlotPadding = OffToken(
    EdgeInsets.only(left: 6, right: 6, bottom: 1),
    reason: 'the blank sets `padding: 0 6px 1px`',
  );

  /// The room inside a tastefix symptom chip.
  static const OffToken<EdgeInsets> tastefixChipPadding = OffToken(
    EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    reason: "a symptom chip sets `padding: '3px 9px'`",
  );

  /// The gap between one symptom chip and the next.
  static const OffToken<double> tastefixChipGap = OffToken(
    6,
    reason: 'the chip row sets `gap: 6`',
  );

  /// The corner on the cup panel a tastefix round reacts inside.
  static const OffToken<double> tastefixPanelRadius = OffToken(
    18,
    reason: 'the cup panel sets `borderRadius: 18`',
  );

  /// The room inside the cup panel, shorter along its foot.
  static const OffToken<EdgeInsets> tastefixPanelPadding = OffToken(
    EdgeInsets.fromLTRB(18, 16, 18, 15),
    reason: "the cup panel sets `'16px 18px 15px'`",
  );

  /// The gap the cup panel keeps between its own lines, and beside its chips.
  static const OffToken<double> tastefixPanelGap = OffToken(
    10,
    reason: 'the cup panel stacks its lines and its chip row at `gap: 10`',
  );

  /// The room the cup panel leaves before the question under it.
  static const OffToken<double> tastefixPanelToPrompt = OffToken(
    20,
    reason: "the question under the cup sets `margin: '20px 0 0'`",
  );

  /// The gap between two how-to-play steps.
  static const OffToken<double> helpStepGap = OffToken(
    11,
    reason: 'the drawer stacks its steps at `gap: 11`',
  );

  /// The room over the how-to-play steps, under the blurb.
  static const OffToken<double> helpStepsTop = OffToken(
    20,
    reason: 'the step stack opens at `marginTop: 20`',
  );

  /// The well the how-to-play drawer holds the kind's mark in.
  static const OffToken<double> helpWellSize = OffToken(
    44,
    reason: 'the drawer heads with a `44` square',
  );

  /// The well's own corner, rounder than the chrome radius beside it.
  static const OffToken<double> helpWellRadius = OffToken(
    12,
    reason: 'the well sets `borderRadius: 12`',
  );

  /// How big the mark is drawn inside that well.
  static const OffToken<double> helpWellMark = OffToken(
    22,
    reason: 'the well draws its mark at `size={22}`',
  );

  /// The leading a fill slot sets for itself, tighter than the paragraph it
  /// sits in so the rule stays under the word rather than under the line.
  static const OffToken<double> fillSlotLeading = OffToken(
    1.15,
    reason: 'the blank sets `line-height: 1.15`',
  );

  /// The gap between one blank's group of words and the next.
  static const OffToken<double> fillGroupGap = OffToken(
    18,
    reason: 'the groups stack at `gap: 18px`',
  );

  /// The gap between the two words offered for one blank.
  static const OffToken<double> fillOptionGap = OffToken(
    10,
    reason: 'the words sit side by side at `gap: 10px`',
  );

  /// The gutter between a match board's two columns, wide enough for the
  /// connectors drawn across it to read as lines rather than as joins.
  static const OffToken<double> matchColumnGap = OffToken(
    40,
    reason: 'the two columns sit at `gap: 40`',
  );

  /// The gap between two tiles in one match column.
  static const OffToken<double> matchTileGap = OffToken(
    10,
    reason: 'a column stacks its tiles at `gap: 10px`',
  );

  /// A match tile's own padding, taller than it is wide.
  static const OffToken<EdgeInsets> matchTilePadding = OffToken(
    EdgeInsets.symmetric(vertical: 15, horizontal: 18),
    reason: 'a match tile sets `padding: 15px 18px`',
  );

  /// How far a held answer swells under the trait about to land on it.
  static const OffToken<double> matchDropHotScale = OffToken(
    1.03,
    reason: 'the answer under a held trait takes `transform: scale(1.03)`',
  );

  /// What is left of a trait once its clone is the thing being dragged.
  static const OffToken<double> matchDraggingOpacity = OffToken(
    0.4,
    reason: 'the tile left behind takes `opacity: 0.4`',
  );

  /// The room the course ending keeps between its headline and its stats.
  static const OffToken<double> courseStatsTop = OffToken(
    26,
    reason: "the ending's stat block opens at `marginTop: 26`",
  );

  /// How wide the course ending's stat rows run, centred under the headline.
  static const OffToken<double> courseStatsWidth = OffToken(
    320,
    reason: "the ending's stat rows sit in `maxWidth: 320`",
  );

  /// The room inside one of the course ending's stat rows.
  static const OffToken<EdgeInsets> courseStatRowPadding = OffToken(
    EdgeInsets.symmetric(vertical: 13, horizontal: 2),
    reason: "a stat row sets `padding: '13px 2px'`",
  );

  /// The gap the predict card keeps under its title, and above its tiles.
  static const OffToken<double> predictSectionGap = OffToken(
    18,
    reason:
        'the predict body sets `marginTop: 18` and `.pick-tiles` sets '
        '`margin-top: 18px`',
  );

  /// The room the predict card leaves before its guess section.
  static const OffToken<double> predictGuessGap = OffToken(
    30,
    reason: "the guess section opens at `margin: '30px 0 0'`",
  );

  /// The leading of the predict card's reading paragraph.
  static const OffToken<double> predictReadingLeading = OffToken(
    1.55,
    reason: 'the predict body sets `lineHeight: 1.55`',
  );

  /// The leading of the predict card's question.
  static const OffToken<double> predictQuestionLeading = OffToken(
    1.5,
    reason: 'the predict question sets `lineHeight: 1.5`',
  );

  /// The gap between the two guess tiles.
  static const OffToken<double> pickTileGap = OffToken(
    11,
    reason: '`.pick-tiles` sets `gap: 11px`',
  );

  /// Every sanctioned exception, so the register can be tested as a whole.
  static const register = <OffToken<Object>>[
    rewardedAdCanvas,
    rewardedAdProgressRing,
    seedStain,
    beanCrease,
    pickTilePadding,
    flashcardFacePadding,
    termOfDayBannerPadding,
    termOfDayBannerFootPadding,
    triedSealPadding,
    todayLeadGap,
    todayCtaGap,
    practiceInlineGap,
    practiceGroupFoot,
    cardsFooterPadding,
    cardsFooterLineGap,
    tabTitleClearOfEntries,
    introBlockGap,
    introSupportGap,
    ghostUnderPrimaryGap,
    textFieldVerticalPadding,
    tapCueTracking,
    microTipEyebrowGap,
    microTipBodyTracking,
    microTipTitleGap,
    microTipBodyLeading,
    tourCardInset,
    tourCardPadding,
    tourCardLineGap,
    tourCardBodyLeading,
    tourFrameInset,
    tabBarTopPad,
    tourCardRestingBottom,
    tourCardHeadroom,
    tourScrollTopGap,
    tourScrollCardClearance,
    tourStepDotSize,
    tourAdvancePadding,
    tourSkipPadding,
    fillSlotMinWidth,
    fillSlotPadding,
    tastefixChipPadding,
    tastefixChipGap,
    tastefixPanelRadius,
    tastefixPanelPadding,
    tastefixPanelGap,
    tastefixPanelToPrompt,
    helpStepGap,
    helpStepsTop,
    helpWellSize,
    helpWellRadius,
    helpWellMark,
    matchColumnGap,
    matchTileGap,
    matchTilePadding,
    matchDropHotScale,
    matchDraggingOpacity,
    fillSlotLeading,
    fillGroupGap,
    fillOptionGap,
    courseStatsTop,
    courseStatsWidth,
    courseStatRowPadding,
    predictSectionGap,
    predictGuessGap,
    predictReadingLeading,
    predictQuestionLeading,
    pickTileGap,
  ];
}
