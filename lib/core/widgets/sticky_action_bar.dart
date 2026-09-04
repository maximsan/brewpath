import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Where the page background stops being opaque, on the way up.
///
/// The design writes it as
/// `linear-gradient(to top, var(--bg) 74%, transparent)` — solid for the lower
/// three-quarters so the button always has ground under it, then a short fade
/// so scrolling text dissolves rather than being cut off.
const double _backgroundStop = 0.74;

/// Height the bar assumes for its first frame, before it has measured itself.
///
/// A starting guess, not a promise: it omits the safe-area inset a notched
/// device adds, any quiet link, and any text scaling. It exists only so the
/// opening frame reserves roughly the right room instead of none — the real
/// height arrives one frame later. See [_StickyActionBarState].
const double _estimatedBarHeight =
    AppSpacing.md + PrimaryButton.height + AppSpacing.lg;

/// Below this, a re-measure is rounding noise rather than a real change, and
/// acting on it would set state every frame.
const double _measurementNoise = 0.5;

/// The bordered action a bar may carry under its primary.
///
/// **Not a second primary.** It is the design's `btn-ghost` — an outline in the
/// accent, which is how a verdict that deserves more than a link still reads as
/// quieter than the way forward. The lesson ending's *Practice this lesson
/// again* is the case it exists for: the screen's verdict on a weak run, paired
/// with the action that acts on it.
@immutable
class GhostAction {
  /// Creates a [GhostAction] — neutral, which is what a dismiss or a skip is.
  const GhostAction({required this.label, required this.onPressed})
    : isAccent = false;

  /// The inviting variant, for the one ghost the design draws in the accent:
  /// the lesson ending's *Practice this lesson again*.
  const GhostAction.accent({required this.label, required this.onPressed})
    : isAccent = true;

  /// What the button reads.
  final String label;

  /// Pressed. Null shows it disabled rather than hiding it.
  final VoidCallback? onPressed;

  /// Whether the button invites rather than dismisses.
  final bool isAccent;
}

/// The quiet link a bar may carry under its action.
///
/// A value type rather than a `label`/`onTap` pair on [StickyActionBar], so the
/// two cannot be passed half-set — and so the bar's signature says plainly that
/// the slot is a *link*, never a button.
@immutable
class QuietLink {
  /// Creates a [QuietLink].
  const QuietLink({required this.label, required this.onTap});

  /// What the link reads.
  final String label;

  /// Followed on tap. Null disables it.
  final VoidCallback? onTap;
}

/// The footer that carries a screen's single primary action.
///
/// **One primary action.** The signature takes a label and a callback rather
/// than a widget, so a second filled button is not something a caller can
/// pass. The design's rule that *"this and the tab bar are the app's only
/// footers"* is then enforceable by the absence of any other pinned-footer
/// widget.
///
/// Under it the bar carries at most two quieter things, and neither can be
/// mistaken for a second primary: a [ghost] — a bordered button the design
/// gives a verdict that deserves weight, like *Practice this lesson again* —
/// and a [link]. Both are value types for the same reason the primary is a
/// label and a callback: a caller cannot hand either one a filled button.
///
/// **It owns the scroll.** [content] is plain — the bar wraps it, centres it
/// when it fits and scrolls it when it does not, matching the design's
/// `margin: auto 0`. Owning the scroll is what lets the bar reserve its own
/// height below the content, which is the half of this component a caller would
/// otherwise get wrong: with the bar overlaid and nothing reserved, the last
/// line of a long screen sits behind it and no amount of scrolling reveals it.
///
/// **Content passes behind it, rather than stopping above it.** That is what
/// the gradient is for, and it rules out the obvious
/// `Column(children: [Expanded(scrollable), bar])` — that shape ends the scroll
/// above the bar and leaves the fade with nothing to fade over.
class StickyActionBar extends StatefulWidget {
  /// Creates a [StickyActionBar].
  const StickyActionBar({
    required this.content,
    required this.label,
    required this.onPressed,
    this.trailingMark,
    this.ghost,
    this.link,
    this.preface,
    super.key,
  });

  /// The screen's own content. Not a scrollable — the bar scrolls it.
  final Widget content;

  /// What the primary action reads.
  final String label;

  /// The primary action. Null shows it disabled rather than hiding it, so the
  /// learner can see what the screen wants before they have done it.
  final VoidCallback? onPressed;

  /// A mark after the primary's label — see [PrimaryButton.trailingMark].
  final AppIcon? trailingMark;

  /// The optional bordered action under the primary.
  final GhostAction? ghost;

  /// The optional quiet link under the action.
  ///
  /// **No caller in v1.** The design's footer puts *Duel a friend* here on the
  /// lesson ending, and the duel is v2 — so the slot is drawn and tested but
  /// nothing production passes it yet. Kept rather than removed and re-added:
  /// it is a slot the design has, not one the app invented.
  final QuietLink? link;

  /// Optional content pinned **above** the action, inside the bar.
  ///
  /// A sentence the action needs read first — the module ending's *"A reward
  /// card is waiting on the other side."* It belongs to the footer rather than
  /// to the scrolling content: it travels with the action, and the gradient
  /// has to sit behind it.
  ///
  /// The lesson ending's Coffee Challenge offer used to live here. It is a row
  /// of that screen's reward list now, with the freeze and the new card, so
  /// the three read as one list rather than one of them being footer chrome.
  ///
  /// **Still not a second action.** The primary is a label and a callback and
  /// nothing here changes that, so the design's *"one primary action only"*
  /// stays enforced by the signature. A caller that puts a filled button in
  /// here is doing something the rule already forbids in words; what it can
  /// express is an offer or a sentence, which is what the design asks for.
  ///
  /// **It carries its own gap.** The bar adds no spacer above the action,
  /// because a preface that renders nothing must leave nothing behind: the
  /// challenge offer is absent from twenty of the thirty-two lessons, and a
  /// spacer the bar contributed would show as a phantom band on all of them.
  final Widget? preface;

  @override
  State<StickyActionBar> createState() => _StickyActionBarState();
}

class _StickyActionBarState extends State<StickyActionBar> {
  final GlobalKey _barKey = GlobalKey();

  /// How much room to leave under the content so the bar hides none of it.
  ///
  /// Measured rather than computed, because a quiet link and the system text
  /// scale both change the bar's real height, and a screen whose last line is
  /// unreachable is the exact failure this component exists to prevent.
  ///
  /// The alternative — laying a second, invisible copy of the bar into the
  /// scroll to reserve exactly the right space — reserves it in one pass, but
  /// puts a duplicate of the action's label and button in the tree, where
  /// `find.text` and every screen reader meet it twice. Measuring keeps the
  /// tree honest and costs one frame.
  ///
  /// Null until the first measurement lands; [_estimatedBarHeight] stands in
  /// for that one frame.
  double? _measuredBarHeight;

  /// Reads the bar's real height and reserves that much under the content.
  ///
  /// Settles rather than loops: the bar's own height does not depend on the
  /// reservation, so the re-measure that a `setState` provokes agrees with the
  /// value just stored and returns here without setting state again.
  void _measure(Duration _) {
    if (!mounted) return;
    final box = _barKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final measured = box.size.height;
    if (((_measuredBarHeight ?? 0) - measured).abs() < _measurementNoise) {
      return;
    }
    setState(() => _measuredBarHeight = measured);
  }

  @override
  Widget build(BuildContext context) {
    // Depending on the whole MediaQuery is deliberate. The bar's height moves
    // with the system text scale and with the safe-area inset a rotation
    // changes, and neither reaches this widget as a widget update — so without
    // this dependency `build` is never called again, the post-frame measure
    // below never runs, and the reservation stays at whatever the bar happened
    // to be on the first frame. A narrower `paddingOf` would miss the text
    // scale and leave exactly that gap.
    final media = MediaQuery.of(context);
    WidgetsBinding.instance.addPostFrameCallback(_measure);

    // The estimate carries the inset because a notched device adds it to every
    // bar, which is precisely where a short first frame would be seen.
    final reserved =
        _measuredBarHeight ?? _estimatedBarHeight + media.padding.bottom;

    return Stack(
      children: [
        Positioned.fill(child: _scrollingContent(reserved)),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _bar(),
        ),
      ],
    );
  }

  /// The content, centred when it fits and scrolled when it does not.
  ///
  /// The scroll view gives the content an unbounded height, so a tall moment
  /// scrolls instead of overflowing; the minimum height then stretches a short
  /// one to the viewport so [Center] reads as the design's `margin: auto 0`.
  ///
  /// Deliberately **not** `Expanded` in a `Column`, and not
  /// `SliverFillRemaining`: both bound the content to the space left over, so
  /// anything taller is clipped rather than scrolled — which is how the
  /// celebration on the course ending overflowed by 40 pixels.
  ///
  /// The bottom padding, rather than a sibling spacer, is what reserves the
  /// bar's own height, so it applies to the short and the tall case alike.
  Widget _scrollingContent(double reserved) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final room = constraints.maxHeight - reserved;
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: reserved),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: room > 0 ? room : 0),
            child: Center(child: widget.content),
          ),
        );
      },
    );
  }

  Widget _bar() {
    final mood = context.mood;
    final ghost = widget.ghost;
    final link = widget.link;
    final preface = widget.preface;

    return DecoratedBox(
      key: _barKey,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [mood.bg, mood.bg.withValues(alpha: 0)],
          stops: const [_backgroundStop, 1],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.md,
            AppSpacing.gutter,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?preface,
              PrimaryButton(
                label: widget.label,
                onPressed: widget.onPressed,
                trailingMark: widget.trailingMark,
              ),
              if (ghost != null) ...[
                const SizedBox(height: AppSpacing.xs),
                if (ghost.isAccent)
                  GhostButton.accent(
                    label: ghost.label,
                    onPressed: ghost.onPressed,
                  )
                else
                  GhostButton(
                    label: ghost.label,
                    onPressed: ghost.onPressed,
                  ),
              ],
              if (link != null)
                LinkButton(label: link.label, onPressed: link.onTap),
            ],
          ),
        ),
      ),
    );
  }
}
