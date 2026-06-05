import 'package:coffee_quest/core/widgets/pick_card.dart';
import 'package:coffee_quest/core/widgets/primary_button.dart';
import 'package:coffee_quest/core/widgets/smallcaps_label.dart';
import 'package:coffee_quest/features/onboarding/presentation/onboarding_providers.dart';
import 'package:coffee_quest/shared/theme/app_colors.dart';
import 'package:coffee_quest/shared/theme/app_spacing.dart';
import 'package:coffee_quest/shared/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _GoalOption {
  const _GoalOption(this.key, this.title, this.description);
  final String key;
  final String title;
  final String description;
}

const _options = <_GoalOption>[
  _GoalOption(
    'brew_better',
    'Brew better at home',
    'Hands-on guidance for V60, AeroPress, and friends.',
  ),
  _GoalOption(
    'understand_tasting',
    'Understand what I’m tasting',
    'Build a vocabulary for the cup in front of you.',
  ),
  _GoalOption(
    'just_curious',
    'Just curious about coffee',
    'A quiet field guide. No pressure.',
  ),
];

class GoalScreen extends ConsumerStatefulWidget {
  const GoalScreen({super.key});

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  int? _picked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkRoastBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            80,
            AppSpacing.lg,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SmallcapsLabel('ONBOARDING · 1 OF 2'),
              const SizedBox(height: AppSpacing.base),
              Text('What brings you here?', style: AppTypography.displayMD()),
              const SizedBox(height: AppSpacing.lg + 4),
              Expanded(
                child: ListView.separated(
                  itemCount: _options.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final opt = _options[i];
                    return PickCard(
                      title: opt.title,
                      description: opt.description,
                      selected: _picked == i,
                      onTap: () => setState(() => _picked = i),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Continue',
                onPressed: _picked == null
                    ? null
                    : () {
                        ref
                            .read(onboardingDraftProvider.notifier)
                            .setGoal(_options[_picked!].key);
                        context.go('/onboarding/brewer');
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
