import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The design's page inset for the intro screens — `paddingTop: 64` above.
const double _topInset = 64;

/// And below, 56: the page's own `paddingBottom: 40` plus the
/// `paddingBottom: 16` every one of these screens sets on the block that
/// reaches the foot. Both halves are the design's, and the foot only clears
/// the edge correctly with both — the shell used to carry the outer one
/// alone.
const double _bottomInset = 40 + 16;

/// The room the page keeps clear above a [IntroPage.foot]: the cue's own line
/// and the design's `paddingTop: 32` over it.
const double _footReserve = AppSpacing.xl + AppSpacing.md;

/// One intro beat: a column that fills the viewport, and scrolls once it
/// cannot.
///
/// The design pins each of these screens' last element to the foot — the tap
/// cue, the CTA (`marginTop: 'auto'`). A plain [Column] does that with a
/// [Spacer], but overflows the moment the content is taller than the screen; a
/// [SingleChildScrollView] alone gives its child unbounded height, which is
/// exactly what a [Spacer] cannot expand into.
///
/// So the viewport's height becomes a **minimum**, not a maximum. Short
/// content is stretched to it and a trailing flexible pins the foot; tall
/// content — a 2x text scale, a landscape phone — grows past it and scrolls,
/// which is the case that used to clip the CTA off the bottom of the first
/// screen a learner ever sees.
///
/// **One flexible child per column.** [IntrinsicHeight] sizes the column by
/// its tallest flexible child times the number of flexible children, so a
/// shrinking film *and* a [Spacer] made the column twice the film tall and
/// pushed Welcome's tap cue below the fold. A screen whose last element must
/// stay on screen hands it to [foot] instead, which is pinned over the page
/// and not part of the column at all.
class IntroPage extends StatelessWidget {
  /// Creates an [IntroPage].
  const IntroPage({required this.children, this.foot, super.key});

  /// The page's content, laid out from the top and reaching the foot.
  final List<Widget> children;

  /// What sits at the foot of the screen regardless of the content's height —
  /// Welcome's tap cue. The column keeps [_footReserve] clear above it.
  final Widget? foot;

  @override
  Widget build(BuildContext context) {
    final foot = this.foot;
    final bottomInset = foot == null
        ? _bottomInset
        : _bottomInset + _footReserve;

    return Scaffold(
      backgroundColor: context.mood.bg,
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, viewport) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewport.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        _topInset,
                        AppSpacing.lg,
                        bottomInset,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (foot != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: _bottomInset,
                child: Center(child: foot),
              ),
          ],
        ),
      ),
    );
  }
}

/// The widest the intro's copy sets before it wraps — the design's
/// `maxWidth: 330` on each intro support line.
///
/// On [IntroPage] rather than on each screen: both set the same measure, and
/// two names for one number is how they drift.
const double introCopyMaxWidth = 330;
