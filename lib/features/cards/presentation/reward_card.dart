import 'dart:async';
import 'dart:math' as math;

import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A collectible drawn the way the design draws it — the card *is* the guide.
///
/// Badge, title and stamp; the summary; then the keepsake line under its own
/// rule. **Deliberately no points total**: points are paid per lesson and
/// reported by the completion rail, and a card that also carried a number
/// would read as a second payout (`prototype/rewards.jsx:407-486`).
///
/// Shared rather than built for one screen: the lesson ending previews one,
/// and the module ending turns one over.
class RewardCard extends StatefulWidget {
  /// Creates a [RewardCard].
  const RewardCard({required this.card, super.key});

  /// The collectible to draw.
  final CoffeeCardModel card;

  /// The widest the card is drawn, whatever room it is given.
  static const double maxWidth = 320;

  /// The kicker over the keepsake line.
  static const String memorableLabel = 'Memorable';

  @override
  State<RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<RewardCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// The card settles in rather than appearing — the design's 600ms
  /// `cubic-bezier(0.2, 1.2, 0.4, 1.0)`, which overshoots slightly.
  static const Duration _settle = Duration(milliseconds: 600);
  static const Curve _settleCurve = Cubic(0.2, 1.2, 0.4, 1);

  /// Where it settles from: below, slightly small, slightly turned.
  static const double _fromOffset = 16;
  static const double _fromScale = 0.94;
  static const double _fromTurns = -2 / 360;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _settle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    // Reduced motion lands the card at rest on its first frame: the entrance
    // is pure movement, so there is nothing here a cross-fade has to carry.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && !_controller.isCompleted) {
      unawaited(_controller.forward());
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final settled = _settleCurve.transform(_controller.value);
        return Opacity(
          opacity: _controller.value,
          child: Transform.translate(
            offset: Offset(0, _fromOffset * (1 - settled)),
            child: Transform.rotate(
              angle: _fromTurns * (1 - settled) * 2 * math.pi,
              child: Transform.scale(
                scale: _fromScale + (1 - _fromScale) * settled,
                child: child,
              ),
            ),
          ),
        );
      },
      child: _card(mood),
    );
  }

  Widget _card(MoodColors mood) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: RewardCard.maxWidth),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: mood.surface,
        borderRadius: BorderRadius.circular(AppRadii.editorial),
        border: Border.all(
          color: Color.alphaBlend(
            mood.accent.withValues(alpha: _edgeTint),
            mood.rule,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: mood.ink.withValues(alpha: _shadowStrength),
            blurRadius: _shadowBlur,
            offset: const Offset(0, _shadowDrop),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: _content(mood),
      ),
    ),
  );

  Widget _content(MoodColors mood) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      _Heading(card: widget.card),
      const SizedBox(height: AppSpacing.lg),
      Text(widget.card.description, style: AppText.support(mood: mood)),
      const SizedBox(height: AppSpacing.md),
      Divider(height: 1, thickness: 1, color: mood.rule),
      const SizedBox(height: AppSpacing.base),
      const SmallcapsLabel(RewardCard.memorableLabel),
      const SizedBox(height: AppSpacing.xs),
      // The keepsake line, set in the display face: it is the thing a learner
      // is meant to carry away, and the app rendered it nowhere until now.
      Text(widget.card.fact, style: AppText.heading(mood: mood)),
    ],
  );

  /// How much accent the card's edge carries — the design's `accent 22%`.
  static const double _edgeTint = 0.22;

  /// The lift the card sits on.
  static const double _shadowStrength = 0.35;
  static const double _shadowBlur = 40;
  static const double _shadowDrop = 18;
}

/// The badge and title, with the stamp in the corner they leave room for.
class _Heading extends StatelessWidget {
  const _Heading({required this.card});

  final CoffeeCardModel card;

  /// The stamp's own size.
  static const double _stampSize = 68;

  /// How far the stamp is turned — the design's `rotate={-12}`.
  static const double _stampTurns = -12 / 360;

  /// The gutter the title leaves for the stamp: the design's 92, which is the
  /// stamp plus its inset plus breathing room. A hard cap on the title's width
  /// instead let a long name run under the stamp's ring.
  static const double _stampGutter = 92;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: _stampGutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SmallcapsLabel(card.moduleTag),
              const SizedBox(height: AppSpacing.xs),
              Text(card.title, style: AppText.title(mood: mood)),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Transform.rotate(
            angle: _stampTurns * 2 * math.pi,
            child: IconMark(
              moduleMark(card.iconName),
              size: _stampSize,
              color: mood.accent,
            ),
          ),
        ),
      ],
    );
  }
}
