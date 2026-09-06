import 'package:brew_path/core/widgets/scrolled_progress.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The one bar chrome a screen-level top bar wears.
///
/// **Invisible at rest.** The design's header draws nothing until the page
/// under it has moved: no fill, no hairline, no blur, and — because a
/// `BackdropFilter` costs a `saveLayer` whatever its sigma — no filter in the
/// tree at all. What the learner sees at the top of a tab is the tab's own
/// large title, and the bar is only the entries floating over it.
///
/// **Scrolled, it blends in.** The page pulled over itself at
/// `color-mix(in oklab, var(--bg) 94%, transparent)`, blurred 16px and lifted
/// back to its own warmth, with a hairline along the bottom and a short
/// gradient fading below it so type scrolling out from under the bar is never
/// seen crossing an invisible edge.
///
/// It is a primitive rather than one screen's chrome because the design has
/// one of these and composes it twice — the tab header here, and the back bar
/// a pushed page wears (#513). Height is the caller's, so a bar and whatever
/// is laid out against it cannot drift apart.
///
/// **The painted half is laid beside the content rather than around it**, and
/// ignores the pointer. A `DecoratedBox` claims every hit inside its
/// decoration's shape, so a bar built as one box wrapping its own contents
/// would swallow the drag that is meant to scroll the page underneath it —
/// which is exactly the gesture the design's `pointer-events: none` lets
/// through.
class HeaderChrome extends StatelessWidget {
  /// Creates a [HeaderChrome] of [height], filled when [isScrolled].
  const HeaderChrome({
    required this.height,
    required this.isScrolled,
    required this.child,
    super.key,
  });

  /// The status bar the design measures every bar height over. On a device it
  /// is the top inset instead, so every height here is the design's own number
  /// with this taken off — through [belowDesignStatusBar], the one place the
  /// subtraction lives.
  static const double _designStatusBarHeight = 54;

  /// [designHeight] — a number the design measures from the top of the screen
  /// — as the height below the status bar that a device actually has room for.
  static double belowDesignStatusBar(double designHeight) =>
      designHeight - _designStatusBarHeight;

  /// The design's tab header, measured from the top of the screen.
  static const double _tabHeightWithStatusBar = 116;

  /// How tall the tab header stands below the status bar.
  static const double tabHeight =
      _tabHeightWithStatusBar - _designStatusBarHeight;

  /// The gradient that fades below the bar.
  static const double fadeHeight = 22;

  /// How tall the bar stands below the status bar.
  final double height;

  /// Whether the page under the bar has scrolled far enough to need it.
  final bool isScrolled;

  /// What the bar carries, laid along its bottom edge the way the design
  /// aligns it.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    // The bar reaches up under the status bar, because what passes beneath it
    // has to be blurred all the way to the top of the screen.
    final barHeight = MediaQuery.paddingOf(context).top + height;

    return ScrolledProgress(
      isScrolled: isScrolled,
      duration: scrolledFade,
      child: SizedBox(
        height: barHeight,
        child: Align(alignment: Alignment.bottomLeft, child: child),
      ),
      builder: (context, progress, content) => SizedBox(
        height: barHeight + fadeHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: _PaintedBar(
                  mood: mood,
                  progress: progress,
                  barHeight: barHeight,
                ),
              ),
            ),
            Positioned(top: 0, left: 0, right: 0, child: content!),
          ],
        ),
      ),
    );
  }
}

/// The bar's painted half at [progress] of the way from invisible to filled.
class _PaintedBar extends StatelessWidget {
  const _PaintedBar({
    required this.mood,
    required this.progress,
    required this.barHeight,
  });

  final MoodColors mood;
  final double progress;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    // The whole token, scaled: the tint, the blur and the saturation it is
    // written with arrive together and fade in together — and at rest there is
    // no filter at all, which is what keeps an invisible bar from paying for a
    // `saveLayer`.
    final headerFill = mood.headerFill.at(progress);
    final bar = SizedBox(
      height: barHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: headerFill.color,
          border: Border(
            bottom: BorderSide(color: mood.rule.withValues(alpha: progress)),
          ),
        ),
      ),
    );
    final filter = headerFill.backdropFilter;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (filter == null)
          bar
        else
          ClipRect(
            child: BackdropFilter(filter: filter, child: bar),
          ),
        _EdgeFade(mood: mood, progress: progress),
      ],
    );
  }
}

/// The short gradient below the bar, so type leaving from under it is never
/// seen crossing an invisible edge.
class _EdgeFade extends StatelessWidget {
  const _EdgeFade({required this.mood, required this.progress});

  final MoodColors mood;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final fade = mood.headerFade;

    return SizedBox(
      height: HeaderChrome.fadeHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              fade.withValues(alpha: fade.a * progress),
              fade.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
