import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'package:coffee_quest/core/widgets/link_button.dart';
import 'package:coffee_quest/core/widgets/primary_button.dart';
import 'package:coffee_quest/core/widgets/smallcaps_label.dart';
import 'package:coffee_quest/features/onboarding/presentation/onboarding_providers.dart';
import 'package:coffee_quest/features/onboarding/presentation/widgets/coffee_persona.dart';
import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty.dart';
import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty_state.dart';
import 'package:coffee_quest/shared/theme/app_colors.dart';
import 'package:coffee_quest/shared/theme/app_spacing.dart';
import 'package:coffee_quest/shared/theme/app_typography.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = ref.watch(welcomeHeroVariantControllerProvider);
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _HeroFrame(variant: variant),
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
              if (kDebugMode) ...[
                const SizedBox(height: AppSpacing.md),
                _VariantSwitcher(
                  active: variant,
                  onChange: (v) {
                    ref
                        .read(welcomeHeroVariantControllerProvider.notifier)
                        .set(v);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroFrame extends StatelessWidget {
  const _HeroFrame({required this.variant});

  final WelcomeHeroVariant variant;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case WelcomeHeroVariant.roastyOnly:
        return const Center(child: Roasty(state: RoastyState.idle, size: 220));
      case WelcomeHeroVariant.videoSeedToTree:
        return const _VideoHero();
      case WelcomeHeroVariant.treeStageCycle:
        return const Stack(
          alignment: Alignment.center,
          children: [
            CoffeePersona(size: 240),
            Positioned(
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
}

class _VideoHero extends StatefulWidget {
  const _VideoHero();

  @override
  State<_VideoHero> createState() => _VideoHeroState();
}

class _VideoHeroState extends State<_VideoHero> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/video/Flowerpot_seed_to.mp4')
          ..setLooping(true)
          ..setVolume(0)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
              _controller.play();
            }
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
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

class _VariantSwitcher extends StatelessWidget {
  const _VariantSwitcher({required this.active, required this.onChange});

  final WelcomeHeroVariant active;
  final ValueChanged<WelcomeHeroVariant> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final v in WelcomeHeroVariant.values) ...[
          Expanded(
            child: _segment(
              label: switch (v) {
                WelcomeHeroVariant.roastyOnly => 'A · Roasty',
                WelcomeHeroVariant.videoSeedToTree => 'B · Video',
                WelcomeHeroVariant.treeStageCycle => 'C · Stages',
              },
              selected: v == active,
              onTap: () => onChange(v),
            ),
          ),
          if (v != WelcomeHeroVariant.values.last) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _segment({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.darkRoastAccent : Colors.transparent,
          border: Border.all(
            color: selected
                ? AppColors.darkRoastAccent
                : AppColors.darkRoastRule,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.smallcaps(
              color: selected
                  ? AppColors.darkRoastAccentInk
                  : AppColors.darkRoastInk,
            ),
          ),
        ),
      ),
    );
  }
}
