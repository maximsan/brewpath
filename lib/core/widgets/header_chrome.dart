import 'package:brew_path/core/widgets/scrolled_progress.dart';
import 'package:brew_path/shared/theme/app_overlay.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The one bar chrome a screen-level top bar wears: nothing at rest, and
/// scrolled, the page pulled over itself under a hairline and a short fade.
///
/// A primitive, because the design has one of these and composes it three
/// times — the tab header, a pushed page's back bar (#513) and the floating
/// bar (#583). Height is the caller's.
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
            // Laid beside the content rather than around it, and taking no
            // pointer: a bar built as one box wrapping its own contents would
            // swallow the drag meant to scroll the page underneath — the
            // gesture the design's `pointer-events: none` lets through.
            Positioned.fill(
              child: IgnorePointer(
                child: HeaderChromePaint(
                  barHeight: barHeight,
                  progress: progress,
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

/// A bar's painted half — fill, hairline and the fade below it — [progress] of
/// the way in from nothing.
///
/// Public because the floating bar lays its own controls over this instead of
/// along the bottom edge [HeaderChrome] aligns to, and the design gives the
/// two bars one fade rather than one each.
class HeaderChromePaint extends StatelessWidget {
  /// Creates the painted half, [barHeight] tall above its fade.
  const HeaderChromePaint({
    required this.barHeight,
    required this.progress,
    this.fill,
    this.child,
    super.key,
  });

  /// How tall the filled band stands, the status-bar inset included.
  final double barHeight;

  /// How far in the chrome is: 0 draws nothing, 1 draws all of it. The fill,
  /// the hairline and the fade all ride it.
  final double progress;

  /// What fills the band, for a bar sealed with the page's own colour rather
  /// than the header's translucent pull. Defaults to [MoodColors.headerFill].
  final AppOverlay? fill;

  /// What sits inside the band. The fade below it never takes the pointer.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    // The whole token, scaled: the tint, the blur and the saturation it is
    // written with arrive together and fade in together — and at rest there is
    // no filter at all, which is what keeps an invisible bar from paying for a
    // `saveLayer`.
    final headerFill = (fill ?? mood.headerFill).at(progress);
    final bar = SizedBox(
      height: barHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: headerFill.color,
          border: Border(
            bottom: BorderSide(color: mood.rule.withValues(alpha: progress)),
          ),
        ),
        child: child,
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
        IgnorePointer(
          child: _EdgeFade(mood: mood, progress: progress),
        ),
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
