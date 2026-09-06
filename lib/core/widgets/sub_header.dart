import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/header_chrome.dart';
import 'package:brew_path/core/widgets/header_compact_title.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The bar a page opened from a tab wears: [HeaderChrome] at the design's
/// sub-screen height, carrying a way back, the page's title in miniature once
/// its large title has scrolled under, and the page's controls on the right.
///
/// The design's `solid` variant — pinned filled and titled for a page with no
/// large title — is not ported: its one host is the Roasty dress-up screen,
/// which this app has not built. The streak and the grove open on a hero and
/// still take the ordinary scrolled flag, as the design passes it (#513).
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

  /// The design's bar, measured from the top of the screen.
  static const double _heightWithStatusBar = 96;

  /// Where a page's content starts, measured from the top of the screen the
  /// way the design measures it, when the page opens on a large title. Stated
  /// beside the bar's height because the two are a pair: content that cleared
  /// a bar of one height under a pad written for another is the drift the
  /// design exports both numbers to prevent.
  static const double designScrollPad = 108;

  /// The design's shorter pad, given to the coffee tree and the streak.
  static const double shortDesignScrollPad = 84;

  /// How tall the bar stands below the status bar.
  static final double height = HeaderChrome.belowDesignStatusBar(
    _heightWithStatusBar,
  );

  /// The bare control is the design's `.close-btn`: an 18px mark with 4px of
  /// padding, whose touch area widens to 44 without moving anything around it.
  static const double _markSize = 18;
  static const double _markPadding = 4;
  static const double _bareControlSize = _markSize + 2 * _markPadding;
  static const double _hitSize = 44;
  static const double _hitOverhang = (_hitSize - _bareControlSize) / 2;

  /// The ringed control is a drawn shape: a 32px hairline circle around a
  /// 15px mark, the design's `size={ringBack ? 15 : 18}`.
  static const double _ringedControlSize = 32;
  static const double _ringedMarkSize = 15;

  /// The design pulls the bare control 4 left, so its mark — not its box —
  /// sits on the bar's inset.
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
  /// so far.
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

  /// Where the title starts: on the inset, or after the control and the gap.
  double get _titleInset {
    if (onBack == null) return _sideInset;
    if (isRinged) return _sideInset + _ringedControlSize + _gap;
    return _sideInset + _bareControlNudge + _bareControlSize + _gap;
  }

  @override
  Widget build(BuildContext context) {
    return HeaderChrome(
      height: height,
      isScrolled: isScrolled,
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            if (onBack != null)
              if (isRinged)
                Positioned(
                  left: _sideInset,
                  bottom: _bottomInset,
                  width: _ringedControlSize,
                  height: _ringedControlSize,
                  child: _BackControl(
                    mark: mark,
                    label: _backLabel,
                    isRinged: true,
                    onPressed: onBack!,
                  ),
                )
              else
                // The touch box is centred on the drawn box, so it overhangs
                // the inset below and the title beside it — which is what the
                // design's pseudo-element does, and why the control sits in
                // the stack rather than in the row it would otherwise stretch.
                Positioned(
                  left: _sideInset + _bareControlNudge - _hitOverhang,
                  bottom: _bottomInset - _hitOverhang,
                  width: _hitSize,
                  height: _hitSize,
                  child: _BackControl(
                    mark: mark,
                    label: _backLabel,
                    isRinged: false,
                    onPressed: onBack!,
                  ),
                ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                _titleInset,
                0,
                _sideInset,
                _bottomInset,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    // The stack may stand proud of the bar's inset, as it does
                    // in the design: an eyebrow over a title measures 33.35
                    // against the 32 the inset leaves it.
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
          ],
        ),
      ),
    );
  }

  String get _backLabel => mark == AppIcon.close ? 'Close' : 'Back';
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
    final size = isRinged ? SubHeader._ringedControlSize : SubHeader._hitSize;

    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      // The ring is a border on the same control, with its ink muted to sit
      // beside the trailing control rather than compete with it.
      style: isRinged
          ? IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                side: BorderSide(color: mood.rule),
              ),
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          : IconButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
      constraints: BoxConstraints.tightFor(width: size, height: size),
      icon: IconMark(
        mark,
        size: isRinged ? SubHeader._ringedMarkSize : SubHeader._markSize,
        color: isRinged ? mood.inkMute : mood.ink,
        semanticLabel: label,
      ),
    );
  }
}
