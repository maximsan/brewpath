import 'package:brew_path/core/widgets/celebration_glow.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The one beat after a purchase: what was bought, and the door it just opened.
///
/// It carries no way back to the offer, because there is nothing left to
/// decide — both actions go forward. What was bought is [plan]'s to say: a
/// subscriber and an owner read different lines under the same heading.
class PurchaseWelcomeScreen extends StatelessWidget {
  /// Creates the celebration for [plan].
  const PurchaseWelcomeScreen({
    required this.plan,
    required this.onOpenStudio,
    required this.onContinue,
    super.key,
  });

  /// How large the mascot is drawn — the design's `size={176}`, the largest he
  /// is drawn anywhere, because this screen has nothing else to say.
  static const double _heroSize = 176;

  /// The plan that was bought, whose welcome line and note this draws.
  final PaywallPlan plan;

  /// Opens the Studio, the thing the purchase just unlocked.
  final VoidCallback onOpenStudio;

  /// Leaves the celebration for wherever the learner came from.
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: PaywallCopy.welcomeSemanticLabel,
      child: Scaffold(
        backgroundColor: mood.bg,
        body: Stack(
          children: [
            CelebrationGlow.purchase,
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    Expanded(child: _Celebration(body: plan.welcome)),
                    PrimaryButton(
                      label: PaywallCopy.welcomeOpenStudio,
                      onPressed: onOpenStudio,
                    ),
                    SizedBox(height: OffTokens.ghostUnderPrimaryGap.value),
                    GhostButton(
                      label: PaywallCopy.welcomeBackToLearning,
                      onPressed: onContinue,
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Text(
                      plan.welcomeNote.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppText.micro(
                        mood: mood,
                        face: AppFace.mono,
                        tracking: AppTracking.meta,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The mascot and the two lines under him, centred in whatever room is left.
class _Celebration extends StatelessWidget {
  const _Celebration({required this.body});

  /// How wide the body line is allowed to run — the design's `maxWidth: 300`,
  /// which is what keeps it to the three lines it was written as.
  static const double _bodyWidth = 300;

  final String body;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ExcludeSemantics(
            child: Roasty(
              state: RoastyState.module,
              size: PurchaseWelcomeScreen._heroSize,
            ),
          ),
          Text(
            PaywallCopy.welcomeTitle,
            textAlign: TextAlign.center,
            style: AppText.display(mood: mood),
          ),
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _bodyWidth),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: AppText.body(mood: mood, color: mood.inkMute),
            ),
          ),
        ],
      ),
    );
  }
}
