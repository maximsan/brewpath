import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/header_chrome.dart';
import 'package:brew_path/core/widgets/scrolled_progress.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The bar over a full-screen flow, on the design's `32px 1fr 32px` grid.
///
/// It sits above the scroll, so the page passes underneath. Sealed, it hides
/// that page behind the page's own colour; unsealed, it shows nothing until
/// the content has moved, then takes [MoodColors.headerFill].
class FloatTopbar extends StatelessWidget {
  /// Creates a bar that stays out of the way until the page moves under it.
  const FloatTopbar({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isScrolled,
    this.centre,
    this.trailing,
    super.key,
  }) : _isSealed = false;

  /// Creates a bar that is filled from the first frame.
  const FloatTopbar.sealed({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.centre,
    this.trailing,
    super.key,
  }) : _isSealed = true,
       isScrolled = false;

  /// The mark — a close on a screen you leave, a back on one you turn over.
  final AppIcon icon;

  /// What the control is called, for the tooltip and the screen reader.
  final String label;

  /// What pressing it does.
  final VoidCallback onPressed;

  /// Whether the content has scrolled far enough for the bar to take chrome.
  /// Always false on a sealed bar, which is filled either way.
  final bool isScrolled;

  /// Where the learner is inside the run, centred in the bar.
  final Widget? centre;

  /// The bar's one action — a bookmark, a shuffle.
  final Widget? trailing;

  final bool _isSealed;

  /// The design's 44×44 header control.
  static const double hitSize = 44;

  /// The bar's own height, which is the header's.
  static const double height = 56;

  /// Where the design opens a run's content, measured from the top of the
  /// screen: `padding-top: 134` on a lesson, a mini-game and both drills.
  static const double runDesignScrollPad = 134;

  /// The whole padding for a scroll this bar floats over: [inset] on the
  /// sides and the foot, and a top that opens the content where the design
  /// opens it — [designScrollPad], measured from the top of the screen.
  ///
  /// Given whole rather than added to the caller's own insets, because adding
  /// them lands the content a gutter below the design's own mark.
  static EdgeInsets scrollPadding(
    BuildContext context, {
    required double designScrollPad,
    double inset = 0,
  }) => EdgeInsets.fromLTRB(
    inset,
    MediaQuery.paddingOf(context).top +
        HeaderChrome.belowDesignStatusBar(designScrollPad),
    inset,
    inset,
  );

  /// The band the bar itself covers, for a body that brings its own gutter.
  ///
  /// Left outside that body rather than inside its scroll, which is the only
  /// place it can go when the body is shared with screens wearing no bar. It
  /// stops at the hairline, so content still leaves at the bar's own edge
  /// rather than at a line below it.
  static EdgeInsets barRoom(BuildContext context) =>
      EdgeInsets.only(top: MediaQuery.paddingOf(context).top + height);

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    final controls = SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Row(
          children: [
            SizedBox(
              width: hitSize,
              child: IconButton(
                onPressed: onPressed,
                tooltip: label,
                constraints: const BoxConstraints.tightFor(
                  width: hitSize,
                  height: hitSize,
                ),
                icon: IconMark(icon, color: mood.ink, semanticLabel: label),
              ),
            ),
            Expanded(child: Center(child: centre ?? const SizedBox.shrink())),
            // Reserved whether or not it holds anything, so a bar with one
            // side control keeps its centre centred.
            SizedBox(
              width: hitSize,
              child: trailing == null
                  ? null
                  : Align(alignment: Alignment.centerRight, child: trailing),
            ),
          ],
        ),
      ),
    );

    // Filled with the page's own colour, so nothing shows through and no
    // filter is paid for.
    if (_isSealed) {
      return _Band(
        height: height + MediaQuery.paddingOf(context).top,
        color: mood.bg,
        ruleColor: mood.rule,
        child: controls,
      );
    }

    return ScrolledProgress(
      isScrolled: isScrolled,
      duration: scrolledFade,
      child: controls,
      builder: (context, progress, control) {
        final headerFill = mood.headerFill.at(progress);
        final bar = _Band(
          height: height + MediaQuery.paddingOf(context).top,
          color: headerFill.color,
          ruleColor: mood.rule.withValues(alpha: progress),
          child: control,
        );
        final filter = headerFill.backdropFilter;

        // No filter until there is a fill to go with it: an invisible bar must
        // not pay for the `saveLayer` a `BackdropFilter` takes at any sigma.
        if (filter == null) return bar;
        return ClipRect(
          child: BackdropFilter(filter: filter, child: bar),
        );
      },
    );
  }
}

/// The bar's painted band, reaching up under the status bar so what passes
/// beneath is covered all the way to the top of the screen.
class _Band extends StatelessWidget {
  const _Band({
    required this.height,
    required this.color,
    required this.ruleColor,
    required this.child,
  });

  final double height;
  final Color color;
  final Color ruleColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border(bottom: BorderSide(color: ruleColor)),
      ),
      child: child,
    ),
  );
}
