import 'dart:async';

import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/shared/theme/app_colors.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

/// Welcome / onboarding intro: hero video, Roasty, and the "plant your seed" CTA.
class WelcomeScreen extends ConsumerWidget {
  /// Creates a [WelcomeScreen].
  /// Creates a [WelcomeScreen].
  const WelcomeScreen({super.key});

  static const double _heroFrameRadius = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkRoastBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            64,
            AppSpacing.lg,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SmallcapsLabel('COFFEE QUEST'),
              const SizedBox(height: AppSpacing.base),
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkRoastSurface,
                    border: Border.all(color: AppColors.darkRoastRule),
                    borderRadius: BorderRadius.circular(_heroFrameRadius),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: const _VideoHero(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SmallcapsLabel(
                'ROASTY · YOUR COMPANION',
                color: AppColors.darkRoastAccent,
              ),
              const SizedBox(height: 10),
              Text(
                'Plant your tree.\nGrow with every cup.',
                style: AppTypography.displayXL(),
              ),
              const SizedBox(height: AppSpacing.md + 2),
              Text(
                'Short lessons, real ideas. Roasty stays beside you — '
                'celebrating small wins as your coffee tree grows.',
                style: AppTypography.body(color: AppColors.darkRoastInkMute),
              ),
              const SizedBox(height: AppSpacing.lg + 4),
              PrimaryButton(
                label: 'Plant your seed',
                onPressed: () => context.go('/onboarding/goal'),
              ),
              Center(
                child: LinkButton(
                  label: 'Already have progress? Restore',
                  onPressed: () {}, // placeholder per plan
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Looping seed-to-tree video with Roasty perched bottom-right. Falls back to
/// a static Roasty if the asset can't initialize (e.g. in unit tests where
/// the video_player platform channel is unavailable).
class _VideoHero extends StatefulWidget {
  const _VideoHero();

  @override
  State<_VideoHero> createState() => _VideoHeroState();
}

class _VideoHeroState extends State<_VideoHero> {
  late final VideoPlayerController _controller;
  bool _initFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/video/Flowerpot_seed_to.mp4',
    );
    unawaited(_controller.setLooping(true));
    unawaited(_controller.setVolume(0));
    unawaited(
      _controller.initialize().then(
        (_) {
          if (mounted) {
            setState(() {});
            unawaited(_controller.play());
          }
        },
        onError: (_) {
          if (mounted) setState(() => _initFailed = true);
        },
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initFailed || !_controller.value.isInitialized) {
      return const Center(child: Roasty(state: RoastyState.idle, size: 220));
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        const Positioned(
          right: 8,
          bottom: 8,
          child: IgnorePointer(
            child: Roasty(state: RoastyState.idle, size: 80),
          ),
        ),
      ],
    );
  }
}
