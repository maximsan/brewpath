import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/core/widgets/tap_cue.dart';
import 'package:brew_path/features/onboarding/presentation/intro_page.dart';
import 'package:brew_path/features/onboarding/presentation/welcome/seed_video_hero.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The frame's proportion (`screens.jsx:39`). Not square: a 1:1 frame crops
/// the film's growth and reads as a photo rather than a stage.
const double _heroRatio = 4 / 3;

/// The widest the copy sets before it wraps (`screens.jsx:82`), so the line
/// length stays readable rather than running the full width of a tablet.
const double _copyMaxWidth = 330;

/// Screen 01 of the intro: what the app is, over the seed-to-tree film.
///
/// **Not Meet Roasty.** This screen carried the mascot's eyebrow, heading and
/// body until #383; both screens now exist, in the order the design has them.
/// The design's comment here reads *"No Roasty here."* — the mascot's arrival
/// is the next screen's entire reason to exist.
///
/// The whole screen advances. There is no button: the design gives this beat a
/// `.tap-cue` and nothing to press, because nothing here is a choice.
class WelcomeScreen extends StatelessWidget {
  /// Creates a [WelcomeScreen].
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      label: 'Welcome. Tap anywhere to continue.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.goNamed(AppRoutes.meetRoasty.name),
        child: IntroPage(
          children: [
            // Flexible so a short viewport takes height off the film rather
            // than off the words.
            Flexible(
              child: AspectRatio(
                aspectRatio: _heroRatio,
                child: Container(
                  decoration: BoxDecoration(
                    color: mood.surface,
                    border: Border.all(color: mood.rule),
                    borderRadius: BorderRadius.circular(AppRadii.chrome),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: const SeedVideoHero(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl - 4),
            SmallcapsLabel('BREWPATH', color: mood.accentText),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Learn coffee.\nGrow a tree.',
              style: AppText.display(mood: mood),
            ),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _copyMaxWidth),
              child: Text(
                'Short, hands-on lessons in the craft of coffee. Every one '
                'you finish feeds a living tree, growing from seed to '
                'harvest.',
                style: AppText.body(mood: mood, color: mood.inkMute),
              ),
            ),
            const Spacer(),
            const SizedBox(height: AppSpacing.xl),
            const Center(child: TapCue('TAP ANYWHERE TO CONTINUE')),
          ],
        ),
      ),
    );
  }
}
