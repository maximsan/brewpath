import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/header_chrome.dart';
import 'package:brew_path/core/widgets/header_compact_title.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The bar a page opened from a tab wears.
///
/// The same chrome the tab header wears — [HeaderChrome], invisible at rest
/// and then tinted, blurred and hairlined — at the shorter height the design
/// gives a sub-screen, carrying a way back, the page's title in miniature, and
/// whatever controls the page puts on the right.
///
/// **The page titles itself at the top; this titles it after that.** A pushed
/// page opens on its own large title, the way a tab root does, and this bar
/// raises a small copy of the same words only once that large one has gone
/// under it. Which is why [title] is the page's title rather than a bar
/// caption: the two are one title seen at two sizes, not two labels.
class SubHeader extends StatelessWidget {
  /// Creates a [SubHeader].
  const SubHeader({
    required this.title,
    required this.isScrolled,
    this.eyebrow,
    this.onBack,
    this.mark = AppIcon.back,
    this.backLabel,
    this.trailing,
    this.isRinged = false,
    super.key,
  });

  /// The design's sub-screen bar, measured from the top of the screen.
  static const double _heightWithStatusBar = 96;

  /// The room the design leaves under it in the scroll, measured the same way.
  /// The pair is stated together because it is a pair: content that cleared a
  /// bar of one height under a pad written for another is the drift the design
  /// exports both constants to prevent.
  static const double _scrollPadWithStatusBar = 108;

  /// The design's 54px status bar, which on a device is the top inset instead.
  static const double _designStatusBarHeight = 54;

  /// How tall the bar stands **below** the status bar.
  static const double height = _heightWithStatusBar - _designStatusBarHeight;

  /// How far below the status bar the page's own content starts, so it clears
  /// the bar rather than opening under it. Unlike a tab root — whose large
  /// title deliberately sits behind an invisible bar — a pushed page has a
  /// control up there at every scroll position, and its title must not run
  /// into it.
  static const double scrollPad =
      _scrollPadWithStatusBar - _designStatusBarHeight;

  /// The design's 44×44 header control, and the smaller ringed variant.
  static const double _controlSize = 44;
  static const double _ringedControlSize = 32;

  /// The gap between the control, the title and the trailing controls.
  static const double _gap = 10;

  /// The bar's own inset: the design's `padding: 0 20px 10px`.
  static const double _sideInset = 20;
  static const double _bottomInset = 10;

  /// What the page is called. Shown here only once the page's large title has
  /// scrolled away.
  final String title;

  /// Whether the page beneath has scrolled far enough to need the bar.
  final bool isScrolled;

  /// The smallcaps line above the title — a term's category, and nothing else
  /// so far. Absent on most pages, which title themselves in one line.
  final String? eyebrow;

  /// What leaving the page does. A bar with no way back draws no control.
  final VoidCallback? onBack;

  /// The mark on that control — [AppIcon.back] on a page you came into,
  /// [AppIcon.close] on one you dismiss.
  final AppIcon mark;

  /// What the control is called, for the tooltip and the screen reader.
  /// Defaults to the mark's own word.
  final String? backLabel;

  /// Controls on the right — the bookmark on a term, and nothing else so far.
  final Widget? trailing;

  /// Whether the way back is circled. The design rings it on a page that
  /// carries a trailing control, so both ends of the bar read at one weight.
  final bool isRinged;

  @override
  Widget build(BuildContext context) {
    return HeaderChrome(
      height: height,
      isScrolled: isScrolled,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          _sideInset,
          0,
          _sideInset,
          _bottomInset,
        ),
        child: Row(
          children: [
            if (onBack != null) ...[
              _BackControl(
                mark: mark,
                label: backLabel ?? _defaultLabel,
                isRinged: isRinged,
                onPressed: onBack!,
              ),
              const SizedBox(width: _gap),
            ],
            Expanded(
              // The stack is allowed to stand proud of the bar's inset, which
              // is what the design does: an eyebrow over a title measures
              // 33.35 against the 32 the bar's `padding: 0 20px 10px` leaves
              // it, and CSS lets the 1.35 spill upward rather than clipping
              // or asserting. Without this Flutter throws an overflow on the
              // one page that carries an eyebrow.
              //
              // The 2px of that which is ours: the design sets the compact
              // eyebrow at `line-height: 1` and the ladder's micro rung is
              // 1.2. Rounded onto the rung rather than given a height axis of
              // its own, because one call site is not a vocabulary.
              child: OverflowBox(
                alignment: Alignment.bottomLeft,
                maxHeight: double.infinity,
                child: HeaderCompactTitle(
                  eyebrow: eyebrow,
                  title: title,
                  isVisible: isScrolled,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: _gap),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  /// What the mark is called when the page does not say.
  String get _defaultLabel => mark == AppIcon.close ? 'Close' : 'Back';
}

/// The way back, ringed or bare.
class _BackControl extends StatelessWidget {
  const _BackControl({
    required this.mark,
    required this.label,
    required this.isRinged,
    required this.onPressed,
  });

  final AppIcon mark;
  final String label;
  final bool isRinged;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final size = isRinged
        ? SubHeader._ringedControlSize
        : SubHeader._controlSize;

    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      // The ring is a border on the control, not a different control: the
      // design draws the same mark inside a hairline circle so the bar's two
      // ends carry one weight.
      style: isRinged
          ? IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                side: BorderSide(color: mood.rule),
              ),
              padding: EdgeInsets.zero,
            )
          : null,
      constraints: BoxConstraints.tightFor(width: size, height: size),
      icon: IconMark(mark, color: mood.ink, semanticLabel: label),
    );
  }
}
