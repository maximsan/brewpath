import 'package:brew_path/core/widgets/pick_card.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/onboarding/presentation/goal/goal_controller.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
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

/// Onboarding step: pick your learning goal.
class GoalScreen extends ConsumerStatefulWidget {
  /// Creates a [GoalScreen].
  const GoalScreen({super.key});

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  late final GoalController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GoalController(
      onSubmit: (index) {
        ref.read(onboardingDraftProvider.notifier).setGoal(_options[index].key);
        context.go('/onboarding/brewer');
      },
    )..addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Scaffold(
      backgroundColor: mood.bg,
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
              const SmallcapsLabel('ONBOARDING · 1 OF 3'),
              const SizedBox(height: AppSpacing.base),
              Text(
                'What brings you here?',
                style: AppText.title(mood: mood),
              ),
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
                      selected: _controller.selectedIndex == i,
                      onTap: () => _controller.pick(i),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Continue',
                onPressed: _controller.canSubmit ? _controller.submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
