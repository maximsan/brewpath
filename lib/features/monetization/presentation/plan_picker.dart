import 'package:brew_path/features/monetization/domain/paywall_view.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The rows an arm selling more than one plan asks the learner to choose from.
///
/// Drawn only when there is a choice: a one-plan arm keeps its facts in the
/// slots that own them — the eyebrow names the model, the action carries the
/// price, the footer reassures.
class PlanPicker extends StatelessWidget {
  /// Creates a [PlanPicker].
  const PlanPicker({
    required this.plans,
    required this.selected,
    required this.onPick,
    super.key,
  });

  /// The design's radio dot, and the ring it thickens to when picked.
  static const double _dotSize = 16;
  static const double _pickedRing = 5;
  static const double _restingRing = 1.5;

  /// The design's `13px 16px` row padding.
  static const EdgeInsets _rowPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm + 1,
  );

  /// The rows, in the order the arm names them.
  final List<PaywallPlanView> plans;

  /// Which row is picked.
  final PlusTerm selected;

  /// Called with the row the learner picked.
  final ValueChanged<PlusTerm> onPick;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final plan in plans) ...[
        _PlanRow(
          plan: plan,
          isPicked: plan.term == selected,
          onPick: () => onPick(plan.term),
        ),
        if (plan != plans.last) const SizedBox(height: AppSpacing.xs),
      ],
    ],
  );
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.plan,
    required this.isPicked,
    required this.onPick,
  });

  final PaywallPlanView plan;
  final bool isPicked;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: isPicked,
      label: _spokenLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: plan.isBuyable ? onPick : null,
        child: Container(
          padding: PlanPicker._rowPadding,
          decoration: BoxDecoration(
            color: isPicked ? mood.accentWash : mood.surface,
            border: Border.all(color: isPicked ? mood.accent : mood.rule),
            borderRadius: BorderRadius.circular(AppRadii.chrome),
          ),
          child: Row(
            children: [
              _Dot(isPicked: isPicked, mood: mood),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _NameAndLine(plan: plan, mood: mood),
              ),
              const SizedBox(width: AppSpacing.sm),
              _Price(plan: plan, mood: mood),
            ],
          ),
        ),
      ),
    );
  }

  /// One sentence rather than four fragments, so the row is heard as a choice.
  String get _spokenLabel {
    final price = plan.price == null
        ? 'price unavailable'
        : '${plan.price}${plan.per ?? ''}';

    return '${plan.name}, $price. ${plan.line}.'
        '${plan.badge == null ? '' : ' ${plan.badge}.'}';
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.isPicked, required this.mood});

  final bool isPicked;
  final MoodColors mood;

  @override
  Widget build(BuildContext context) => Container(
    width: PlanPicker._dotSize,
    height: PlanPicker._dotSize,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: isPicked ? mood.accent : mood.inkMute,
        width: isPicked ? PlanPicker._pickedRing : PlanPicker._restingRing,
      ),
    ),
  );
}

class _NameAndLine extends StatelessWidget {
  const _NameAndLine({required this.plan, required this.mood});

  final PaywallPlanView plan;
  final MoodColors mood;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Flexible(
            child: Text(
              plan.name,
              style: AppText.body(mood: mood, face: AppFace.control),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (plan.badge case final badge?) ...[
            const SizedBox(width: AppSpacing.xs),
            _Badge(text: badge, mood: mood),
          ],
        ],
      ),
      const SizedBox(height: AppSpacing.xxs),
      Text(
        plan.line,
        style: AppText.support(mood: mood, color: mood.inkMute),
      ),
    ],
  );
}

/// The worked-out saving, drawn as the design's outlined pill.
class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.mood});

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xxs + 2,
    vertical: 1,
  );

  final String text;
  final MoodColors mood;

  @override
  Widget build(BuildContext context) => Container(
    padding: _padding,
    decoration: BoxDecoration(
      border: Border.all(color: mood.rule),
      borderRadius: BorderRadius.circular(AppRadii.pill),
    ),
    child: Text(
      text.toUpperCase(),
      style: AppText.micro(
        color: mood.accent,
        face: AppFace.mono,
        tracking: AppTracking.tag,
      ),
    ),
  );
}

/// The price, or the fact that the store has not given one.
class _Price extends StatelessWidget {
  const _Price({required this.plan, required this.mood});

  final PaywallPlanView plan;
  final MoodColors mood;

  @override
  Widget build(BuildContext context) {
    if (plan.price case final price?) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: price),
            if (plan.per case final per?)
              TextSpan(
                text: per,
                style: AppText.support(mood: mood, color: mood.inkMute),
              ),
          ],
        ),
        style: AppText.body(mood: mood, face: AppFace.mono),
      );
    }

    return Text(
      '—',
      style: AppText.body(mood: mood, color: mood.inkMute),
    );
  }
}
