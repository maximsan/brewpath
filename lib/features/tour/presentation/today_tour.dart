import 'package:brew_path/core/widgets/fade_up.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_geometry.dart';
import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:brew_path/features/tour/presentation/tour_anchor.dart';
import 'package:brew_path/features/tour/presentation/tour_card.dart';
import 'package:brew_path/features/tour/presentation/tour_frame.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The Tour: a frame that travels between four targets, and a card that says
/// what each one is for.
///
/// **An ordinary child of the shell, not an overlay entry.** The defect the
/// rebuild exists to make unrepresentable is a callout surviving onto another
/// tab, and the fix is structural rather than a listener: whoever builds this
/// gates it on the Learn branch, so a different tab simply does not build it.
/// There is no entry to leak and no `dismiss()` to remember.
///
/// It measures its targets itself, through [TourAnchor], because the four are
/// drawn by three different owners and none of them can see the others.
class TodayTour extends StatefulWidget {
  /// Runs the Tour, calling [onFinish] when Skip or Done ends it.
  const TodayTour({required this.onFinish, super.key});

  /// Called once, when the learner leaves the Tour by either door.
  final VoidCallback onFinish;

  @override
  State<TodayTour> createState() => _TodayTourState();
}

class _TodayTourState extends State<TodayTour> {
  /// How many frames a measurement may wait for its target to appear.
  ///
  /// The feed builds its children lazily, so a stop below the fold has no
  /// render object until the scroll that reaches it has been laid out. A few
  /// frames covers that; past it, the target genuinely is not there and the
  /// layer falls back to a whole dim and a resting card.
  static const int _measureAttempts = 8;

  /// The stop on screen.
  TourStep _step = TourStep.values.first;

  /// Where the frame is, in this layer's coordinates, or null while nothing
  /// has been measured.
  Rect? _target;

  /// The height the last measurement was taken against, so a rotation re-reads
  /// rather than framing where the target used to be.
  double? _area;

  /// Brings [step]'s target into view and measures it.
  ///
  /// Both halves wait for a frame: nothing is measurable until the tree has
  /// been laid out, and the scroll changes the layout the measurement is of.
  void _arriveAt(TourStep step) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || step != _step) return;
      _scrollTo(step);
      _measure(step, attemptsLeft: _measureAttempts);
    });
  }

  /// Puts the feed where [step] needs it.
  ///
  /// A jump rather than a glide, as the design has it: the frame's own move is
  /// the motion the learner is meant to follow, and a page sliding under it at
  /// the same time reads as two things happening at once.
  void _scrollTo(TourStep step) {
    final feed = _feed;
    final position = feed?.position;
    if (position == null || !position.hasContentDimensions) return;

    if (step.returnsFeedToTop) {
      position.jumpTo(position.minScrollExtent);
      return;
    }

    final target = _rectOf(TourAnchor.contextFor(step), within: feed?.context);
    if (target == null) return;
    final delta = tourScrollDelta(
      topGap: target.top,
      bottomOverflow: tourBottomOverflow(
        target: target,
        viewportHeight: position.viewportDimension,
      ),
    );
    if (delta == 0) return;
    position.jumpTo(
      (position.pixels + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
  }

  /// Reads [step]'s target into this layer's own coordinates, waiting a frame
  /// at a time while the feed still has it unmounted.
  void _measure(TourStep step, {required int attemptsLeft}) {
    if (!mounted || step != _step) return;
    final measured = _rectOf(TourAnchor.contextFor(step), within: context);
    if (measured == null && attemptsLeft > 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _measure(step, attemptsLeft: attemptsLeft - 1),
      );
      return;
    }
    if (measured == _target) return;
    setState(() => _target = measured);
  }

  /// The Learn feed, found through the first stop's anchor because that stop is
  /// always inside it. Null on a screen with no feed, which is every screen a
  /// test pumps on its own.
  ScrollableState? get _feed {
    final anchor = TourAnchor.contextFor(TourStep.today);
    return anchor == null ? null : Scrollable.maybeOf(anchor);
  }

  /// [anchor]'s rect in [within]'s coordinates, or null while either is absent
  /// or unlaid.
  static Rect? _rectOf(BuildContext? anchor, {required BuildContext? within}) {
    final target = anchor?.findRenderObject();
    final frame = within?.findRenderObject();
    if (target is! RenderBox || frame is! RenderBox) return null;
    if (!target.hasSize || !frame.hasSize || !target.attached) return null;
    return target.localToGlobal(Offset.zero, ancestor: frame) & target.size;
  }

  void _advance() {
    final next = _step.next;
    if (next == null) {
      widget.onFinish();
      return;
    }
    // The frame is left where it is until the new target is measured, so it
    // travels from the old one rather than reappearing at the new.
    setState(() => _step = next);
    _arriveAt(next);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      _remeasureIfResized(constraints.maxHeight);
      return Semantics(
        container: true,
        explicitChildNodes: true,
        label: TourCopy.layerSemanticLabel,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The shield and the dim are one widget: everything under the Tour
            // is frozen while it runs, including the framed target, which is
            // being explained rather than offered.
            Positioned.fill(
              child: AbsorbPointer(
                child: TourFrame(
                  frame: switch (_target) {
                    final Rect target => tourFrameRect(target),
                    null => null,
                  },
                ),
              ),
            ),
            _cardSlot(constraints.maxHeight),
          ],
        ),
      );
    },
  );

  /// Re-reads the target when the layer changes size — a rotation, or a
  /// keyboard the learner opened before the Tour did.
  void _remeasureIfResized(double areaHeight) {
    if (_area == areaHeight) return;
    _area = areaHeight;
    _arriveAt(_step);
  }

  /// Where the card sits: under the target where there is room for it, over it
  /// where there is not, and at rest near the foot until anything is measured.
  Widget _cardSlot(double areaHeight) {
    final target = _target;
    final gap = OffTokens.tourCardInset.value;
    final below =
        target == null ||
        tourCardSitsBelow(target: target, areaHeight: areaHeight);

    return Positioned(
      left: gap,
      right: gap,
      top: target != null && below ? target.bottom + gap : null,
      bottom: switch (target) {
        null => tourCardRestingBottom,
        final Rect measured when !below => areaHeight - measured.top + gap,
        _ => null,
      },
      child: FadeUp(
        // Keyed by the stop, so each card fades up as it arrives rather than
        // the words changing inside one that is already there.
        key: ValueKey(_step),
        child: TourCard(
          step: _step,
          onSkip: widget.onFinish,
          onAdvance: _advance,
        ),
      ),
    );
  }
}
