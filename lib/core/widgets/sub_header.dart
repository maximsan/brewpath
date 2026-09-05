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
///
/// **The design's `solid` variant is not ported.** It pins the bar filled and
/// titled for a page with no large title to collapse, and its one host is the
/// Roasty dress-up screen, which this app has not built. The two pages here
/// that open on a hero instead of a title — the streak and the grove — are
/// **not** that case: the design passes them the ordinary scrolled flag, so
/// their bar arrives on scroll like every other. See #513.
class SubHeader extends StatelessWidget {
  /// Creates a [SubHeader].
  const SubHeader({
    required this.title,
    required this.isScrolled,
    this.eyebrow,
    this.onBack,
    this.mark = AppIcon.back,
    this.trailing,
    this.isRinged = false,
    super.key,
  });

  /// The design's sub-screen bar and the room it leaves under itself, both
  /// measured from the top of the screen. Stated as a pair because they are
  /// one: content that cleared a bar of one height under a pad written for
  /// another is the drift the design exports both numbers to prevent.
  static const double _heightWithStatusBar = 96;
  static const double _scrollPadWithStatusBar = 108;

  /// How tall the bar stands below the status bar.
  static const double height =
      _heightWithStatusBar - HeaderChrome.designStatusBarHeight;

  /// How far below the status bar a page's own content starts, so it clears
  /// the bar rather than opening under it — the design's 108, the companion of
  /// the 96 above. Unlike a tab root, whose large title deliberately sits
  /// behind an invisible bar, a pushed page has a control up there at every
  /// scroll position and its title must not run into it.
  ///
  /// A page that opens on a hero rather than a title takes less; the design
  /// gives the tree and the streak 84 and the grove 100, and each says so.
  static const double scrollPad =
      _scrollPadWithStatusBar - HeaderChrome.designStatusBarHeight;

  /// The design's 44×44 header control, and the smaller ringed variant, which
  /// it draws as a 32px circle instead.
  static const double _controlSize = 44;
  static const double _ringedControlSize = 32;

  /// How large the mark inside is drawn: the design's `size={ringBack ? 15 :
  /// 18}`. The bare control's box is a hit target rather than a drawing — the
  /// design gives it `padding: 4px` and widens the *touch* area to 44 with a
  /// pseudo-element — so the mark stays small inside a box the thumb can find.
  static const double _markSize = 18;
  static const double _ringedMarkSize = 15;

  /// The design pulls the bare control 4 left, so its mark sits optically on
  /// the bar's own inset rather than 4 inside it. The ringed one is a drawn
  /// shape and stays where it is put.
  static const double _bareControlNudge = -4;

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
                label: _defaultLabel,
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

    final button = IconButton(
      onPressed: onPressed,
      tooltip: label,
      // The ring is a border on the control, not a different control: the
      // design draws the same mark inside a hairline circle so the bar's two
      // ends carry one weight, and mutes its ink to sit beside rather than
      // compete with whatever the circle balances.
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
      icon: IconMark(
        mark,
        size: isRinged ? SubHeader._ringedMarkSize : SubHeader._markSize,
        color: isRinged ? mood.inkMute : mood.ink,
        semanticLabel: label,
      ),
    );

    if (isRinged) return button;
    return Transform.translate(
      offset: const Offset(SubHeader._bareControlNudge, 0),
      child: button,
    );
  }
}
