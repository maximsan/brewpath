import 'dart:async';

import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The full-screen beat a reward route opens on: the companion, an eyebrow, a
/// headline, and a bar that runs down to the content behind it.
///
/// **A beat, not a screen.** It owns no content and no navigation — it holds
/// the frame for [hold], then hands over through [onDone]. Every reward route
/// in the design opens on one (`prototype/rewards.jsx:31-35`, `:224-225`), so
/// it is built shared rather than by whichever route landed first.
///
/// ⚠️ **[onDone] fires exactly once, and fires under reduced motion too.**
/// A tap and the timer race by construction, and a host that sequences its
/// screen behind this callback stalls forever if stillness swallows it — the
/// same discipline the tree's growth is held to (ADR-0011).
class RoastyMoment extends StatefulWidget {
  /// Creates a [RoastyMoment].
  const RoastyMoment({
    required this.reaction,
    required this.eyebrow,
    required this.title,
    required this.onDone,
    super.key,
  });

  /// How long the beat holds before it hands over on its own.
  ///
  /// The design's `autoMs`. One value, not a parameter: the module ending
  /// holds slightly longer, and the caller that needs that can widen this when
  /// it arrives rather than the slot waiting empty for it.
  static const Duration hold = Duration(milliseconds: 2000);

  /// The one-shot the companion plays as the beat opens.
  final CompanionReaction reaction;

  /// Smallcaps kicker over the headline — `LESSON COMPLETE`.
  final String eyebrow;

  /// The headline, which varies with what the run actually did.
  final String title;

  /// Called once, when the beat is over — by the timer or by a tap.
  final VoidCallback onDone;

  /// The companion's rendered size in the beat.
  static const double companionSize = 184;

  @override
  State<RoastyMoment> createState() => _RoastyMomentState();
}

class _RoastyMomentState extends State<RoastyMoment>
    with SingleTickerProviderStateMixin {
  /// Drives the bar only. The hand-over is the [_timer]'s, so stillness cannot
  /// take it away.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: RoastyMoment.hold,
  );

  Timer? _timer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(RoastyMoment.hold, _finish);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Hands over, at most once. The tap and the timer both arrive here and
  /// either may be first.
  void _finish() {
    if (_done) return;
    _done = true;
    _timer?.cancel();
    widget.onDone();
  }

  /// Starts or holds the bar to match the platform's motion preference.
  ///
  /// Read in `build` rather than `initState` because `MediaQuery` is not
  /// available that early, and because the preference can change while the
  /// beat is on screen.
  void _syncBar({required bool animate}) {
    if (animate) {
      if (!_controller.isAnimating && !_controller.isCompleted) {
        unawaited(_controller.forward());
      }
      return;
    }
    if (_controller.isAnimating) _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final animate = !MediaQuery.disableAnimationsOf(context);
    _syncBar(animate: animate);

    return ColoredBox(
      color: mood.bg,
      child: GestureDetector(
        onTap: _finish,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          button: true,
          label: '${widget.eyebrow}. ${widget.title}',
          hint: 'Tap to continue',
          excludeSemantics: true,
          child: Stack(
            children: [
              Positioned.fill(child: _beat(mood)),
              Positioned(
                left: _barInset,
                right: _barInset,
                bottom: _barBottom,
                child: _bar(mood, animate: animate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _beat(MoodColors mood) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CompanionCelebration(
          reaction: widget.reaction,
          size: RoastyMoment.companionSize,
          builder: (context, companion, _) => companion,
        ),
        const SizedBox(height: AppSpacing.xs),
        SmallcapsLabel(widget.eyebrow, color: mood.accentText),
        const SizedBox(height: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _titleWidth),
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: AppText.display(mood: mood),
          ),
        ),
      ],
    ),
  );

  /// The countdown. Held at empty rather than full under reduced motion:
  /// the beat still ends on its own, and a full bar would say it already had.
  Widget _bar(MoodColors mood, {required bool animate}) => ClipRRect(
    borderRadius: BorderRadius.circular(_barHeight),
    child: SizedBox(
      height: _barHeight,
      child: ColoredBox(
        color: mood.surface2,
        child: animate
            ? AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => FractionallySizedBox(
                  // The design's `transform-origin: left`: the fill grows out
                  // of the left edge rather than from the middle.
                  alignment: Alignment.centerLeft,
                  widthFactor: _controller.value,
                  child: child,
                ),
                child: ColoredBox(color: mood.accent),
              )
            : const SizedBox.shrink(),
      ),
    ),
  );

  /// The countdown's gutter — the design's `left: 32; right: 32`.
  static const double _barInset = AppSpacing.xl;

  /// How far the countdown sits off the bottom.
  static const double _barBottom = 40;

  /// The countdown's own thickness.
  static const double _barHeight = 3;

  /// The headline's measure, so a long title wraps rather than running the
  /// full width of a tablet.
  static const double _titleWidth = 320;
}
