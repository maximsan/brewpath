import 'package:brew_path/core/widgets/celebration_glow.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The one beat after a purchase: what was bought, and the door it just opened.
///
/// It carries no way back to the offer, because there is nothing left to
/// decide — both actions go forward. The Studio is offered first because it is
/// the part of Plus a learner can use in the next second.
class PurchaseWelcomeScreen extends StatelessWidget {
  /// Creates the celebration.
  const PurchaseWelcomeScreen({
    required this.onOpenStudio,
    required this.onContinue,
    super.key,
  });

  /// How large the mascot is drawn — the design's `size={176}`, the largest he
  /// is drawn anywhere, because this screen has nothing else to say.
  static const double _heroSize = 176;

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
      label: PlusCopy.welcomeSemanticLabel,
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
                    Expanded(child: _Celebration(mood: mood)),
                    PrimaryButton(
                      label: PlusCopy.welcomeOpenStudio,
                      onPressed: onOpenStudio,
                    ),
                    SizedBox(height: OffTokens.ghostUnderPrimaryGap.value),
                    GhostButton(
                      label: PlusCopy.welcomeBackToLearning,
                      onPressed: onContinue,
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Text(
                      PlusCopy.welcomeNote,
                      textAlign: TextAlign.center,
                      style: AppText.micro(mood: mood, face: AppFace.mono),
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
  const _Celebration({required this.mood});

  /// How wide the body line is allowed to run — the design's `maxWidth: 300`,
  /// which is what keeps it to the three lines it was written as.
  static const double _bodyWidth = 300;

  final MoodColors mood;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
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
          PlusCopy.welcomeTitle,
          textAlign: TextAlign.center,
          style: AppText.display(mood: mood),
        ),
        const SizedBox(height: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _bodyWidth),
          child: Text(
            PlusCopy.welcomeBody,
            textAlign: TextAlign.center,
            style: AppText.body(mood: mood, color: mood.inkMute),
          ),
        ),
      ],
    ),
  );
}
