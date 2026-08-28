import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/onboarding/presentation/intro_page.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Room above the mascot before he is introduced.
const double _mascotInset = 40;

/// How large the mascot is drawn here (`screens.jsx:103`) — his introduction,
/// so the largest he appears anywhere in the app.
const double _mascotSize = 184;

/// The gap above the CTA. Off the spacing scale on purpose — see the
/// register entry.
final double _blockGap = OffTokens.introBlockGap.value;

/// Screen 01b of the intro: the mascot, and what he is for.
///
/// A screen of its own rather than a section of Welcome. It shipped folded
/// into `/welcome` until #383, which meant the app had the mascot's copy and
/// none of Welcome's; ADR-0010 keeps both screens in the v1 cut.
///
/// The CTA reads **Start learning** — the v1 label. The prototype's other
/// label, *Set up my path*, branches into the goal/brewer question flow that
/// ADR-0010 defers to v2, and the `Skip` link beneath it exists only to escape
/// that branch. Neither ships here.
class MeetRoastyScreen extends StatelessWidget {
  /// Creates a [MeetRoastyScreen].
  const MeetRoastyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return IntroPage(
      children: [
        // The design's `space-between`: the mascot holds the upper half, the
        // copy sits at the foot. Flexible rather than fixed so a short
        // viewport shrinks the drawing instead of clipping the words.
        const Flexible(
          child: Padding(
            padding: EdgeInsets.only(top: _mascotInset),
            child: Center(
              // The drawing carries no information the heading beneath it does
              // not already say, and `Roasty` labels nothing itself — so it is
              // excluded rather than left as an unnamed node, as
              // `roasty_stage.dart` excludes its own artwork.
              child: ExcludeSemantics(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Roasty(state: RoastyState.correct, size: _mascotSize),
                ),
              ),
            ),
          ),
        ),
        SmallcapsLabel('YOUR COMPANION', color: mood.accentText),
        const SizedBox(height: AppSpacing.sm),
        Text('Meet Roasty.', style: AppText.display(mood: mood)),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: introCopyMaxWidth),
          child: Text(
            'Your talisman for the journey. Roasty cheers your wins, '
            'marks every milestone, and keeps you company between cups.',
            style: AppText.body(mood: mood, color: mood.inkMute),
          ),
        ),
        SizedBox(height: _blockGap),
        PrimaryButton(
          label: 'Start learning',
          onPressed: () => context.goNamed(AppRoutes.onboardingGoal.name),
        ),
      ],
    );
  }
}
