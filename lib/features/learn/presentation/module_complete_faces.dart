import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/core/widgets/sticky_action_bar.dart';
import 'package:brew_path/features/cards/presentation/reward_card.dart';
import 'package:brew_path/features/challenges/presentation/module_challenge_offer.dart';
import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_rail.dart';
import 'package:brew_path/features/progress/presentation/growing_tree.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The accent wash behind a celebration face — the design's
/// `radial-gradient(circle at 50% 40%, …accent 14%…, transparent 60%)`.
///
/// Two faces, two washes: the reward side sits higher and stronger
/// (`ellipse at 50% 30%`, 18%), because the card it lights is higher up the
/// screen than the tree is.
class CelebrationGlow extends StatelessWidget {
  /// Creates a [CelebrationGlow].
  const CelebrationGlow({
    required this.strength,
    required this.centre,
    required this.edge,
    super.key,
  });

  /// The wash behind the module's own celebration.
  static const CelebrationGlow celebration = CelebrationGlow(
    strength: 0.14,
    centre: Alignment(0, -0.2),
    edge: 0.6,
  );

  /// The wash behind the reward card.
  static const CelebrationGlow reward = CelebrationGlow(
    strength: 0.18,
    centre: Alignment(0, -0.4),
    edge: 0.55,
  );

  /// How much accent the wash carries at its centre.
  final double strength;

  /// Where the wash is brightest.
  final Alignment centre;

  /// Where the wash has faded out entirely — `transparent 60%` on the
  /// celebration, `55%` behind the card.
  final double edge;

  @override
  Widget build(BuildContext context) {
    final accent = context.mood.accent;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: centre,
            colors: [
              accent.withValues(alpha: strength),
              accent.withValues(alpha: 0),
            ],
            stops: [0, edge],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// The celebration face: what the module was, and the tree it grew.
///
/// The hierarchy is the design's way up — `MODULE COMPLETE` is the kicker and
/// the **module's own title** is the headline. The app had these inverted,
/// with `'Module complete!'` as the headline and the module's name demoted to
/// a muted subtitle (Audit E, finding 56).
class ModuleCompleteFront extends StatelessWidget {
  /// Creates a [ModuleCompleteFront].
  const ModuleCompleteFront({
    required this.summary,
    required this.run,
    required this.freezeEarned,
    required this.fromStage,
    required this.toStage,
    required this.onClose,
    required this.onTurnOver,
    super.key,
  });

  /// The finished module and what it earned.
  final ModuleSummary summary;

  /// What the lesson that closed the module paid — its points, and the
  /// collectible it handed over.
  ///
  /// **Reported here because nothing else will.** The design branches on a
  /// module's last lesson, so that lesson's own ending never plays (#458).
  final ModuleEndingRun run;

  /// Whether that run is the one that earned the streak freeze. Carried for
  /// the same reason, and it is the only one of these that cannot be
  /// re-derived afterwards.
  final bool freezeEarned;

  /// Where the coffee tree stood before the run, and after it. Passed in
  /// rather than joined into [ModuleSummary]: that is a content read, and the
  /// tree is progress.
  final int fromStage;

  /// See [fromStage].
  final int toStage;

  /// Leaves the moment.
  final VoidCallback onClose;

  /// Turns the screen over to the reward.
  final VoidCallback onTurnOver;

  /// The design's `AnimatedTree size={250}` on this screen.
  static const double _treeSize = 250;

  /// Whether this ending has a run to report at all.
  ///
  /// **The module's own reward is not on this list**, and must not be: it
  /// lives on the other face, and a rail that drew it here would show the same
  /// card twice in one turn.
  bool get _paidSomething =>
      run.pointsEarned > 0 || freezeEarned || run.lessonCard != null;

  // ⚠️ The design's *Turn it over* also carries a flip glyph after its label
  // (`rewards.jsx:341-344`). `StickyActionBar` takes a label and a callback,
  // so a mark beside it would mean changing the shared footer (#412) for one
  // caller. Left as words, recorded here rather than dropped quietly.

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Stack(
      children: [
        CelebrationGlow.celebration,
        StickyActionBar(
          label: AppLabels.turnItOver,
          onPressed: onTurnOver,
          preface: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              AppLabels.rewardWaiting,
              textAlign: TextAlign.center,
              style: AppText.support(mood: mood),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SmallcapsLabel(
                AppLabels.moduleCompleteKicker,
                color: mood.accent,
              ),
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  summary.module.title,
                  textAlign: TextAlign.center,
                  style: AppText.display(mood: mood),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Growing, because this *is* the ending of the lesson that grew
              // it — the design branches rather than chaining, so no earlier
              // screen has played it (#458).
              Semantics(
                label: toStage > fromStage
                    ? AppLabels.treeGrewTo(toStage)
                    : AppLabels.treeAtStage(toStage),
                excludeSemantics: true,
                child: GrowingTree(
                  fromStage: fromStage,
                  toStage: toStage,
                  size: _treeSize,
                ),
              ),
              // What the closing lesson paid. Absent entirely when the ending
              // was opened outside the flow, where there is no run to report.
              if (_paidSomething) ...[
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                  ),
                  child: LessonCompletionRail(
                    pointsEarned: run.pointsEarned,
                    freezeEarned: freezeEarned,
                    lessonCard: run.lessonCard,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Chrome, not content: the bar centres what it scrolls, and a control
        // pinned to the top of the screen must not travel with it.
        _FaceTopBar(
          icon: AppIcon.close,
          label: AppLabels.close,
          onTap: onClose,
        ),
      ],
    );
  }
}

/// The reward face: the collectible the module paid out.
///
/// It is a `RewardCard` — the module's own field guide, with its spec rows and
/// its keepsake line. The app drew a 72-pt icon badge with the title under it
/// (Audit E, finding 54), which is a caption where the design has a card.
class ModuleCompleteBack extends StatelessWidget {
  /// Creates a [ModuleCompleteBack].
  const ModuleCompleteBack({
    required this.summary,
    required this.onFlipBack,
    required this.onContinue,
    super.key,
  });

  /// The finished module and what it earned.
  final ModuleSummary summary;

  /// Turns the screen back to the celebration.
  final VoidCallback onFlipBack;

  /// Leaves for the next module, or the Path.
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final reward = summary.moduleReward;

    return Stack(
      children: [
        CelebrationGlow.reward,
        StickyActionBar(
          label: summary.hasNextModule
              ? AppLabels.beginNextModule
              : AppLabels.backToPath,
          onPressed: onContinue,
          // The module's own Coffee Challenge, offered here and nowhere else
          // in this flow: the design puts it above the exit CTA on this face,
          // *"no separate step"* (#464). Continuing past it is the not-now —
          // the challenge waits on the Path either way.
          //
          // ⚠️ The design lets the offer scroll with the content and floats
          // only the CTA. `StickyActionBar` pins its preface, so here the two
          // travel together. Order and spacing match; on a face this short
          // nothing scrolls anyway, and prising the offer out of the shared
          // footer (#412) for one caller would cost more than it buys.
          preface: ModuleChallengeOffer(moduleId: summary.module.id),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SmallcapsLabel(AppLabels.rewardUnlocked, color: mood.accent),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppLabels.newCollectibleCard,
                textAlign: TextAlign.center,
                style: AppText.title(mood: mood),
              ),
              const SizedBox(height: AppSpacing.lg),
              // A module with no collected reward keeps the face rather than
              // the card: the flip is the screen's shape, and an empty back
              // would strand the learner mid-turn.
              if (reward != null) RewardCard(card: reward),
            ],
          ),
        ),
        _FaceTopBar(
          icon: AppIcon.back,
          label: AppLabels.flipBack,
          onTap: onFlipBack,
        ),
      ],
    );
  }
}

/// A face's one control, in the design's `.lesson-topbar` slot: no rule, no
/// fill, just the mark.
class _FaceTopBar extends StatelessWidget {
  const _FaceTopBar({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final AppIcon icon;
  final String label;
  final VoidCallback onTap;

  /// The design's 44×44 header control, fixed during its own QA.
  static const double _hitSize = 44;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        onPressed: onTap,
        tooltip: label,
        constraints: const BoxConstraints.tightFor(
          width: _hitSize,
          height: _hitSize,
        ),
        icon: IconMark(icon, color: context.mood.ink, semanticLabel: label),
      ),
    );
  }
}
