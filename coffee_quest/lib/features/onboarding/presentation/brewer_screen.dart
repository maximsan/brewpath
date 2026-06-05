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

class _BrewerOption {
  const _BrewerOption(this.key, this.title, this.description);
  final String key;
  final String title;
  final String description;
}

const _options = <_BrewerOption>[
  _BrewerOption('v60', 'V60', 'Pour-over. Clean, light, articulate.'),
  _BrewerOption(
    'aeropress',
    'AeroPress',
    'Forgiving and fast. A good first brewer.',
  ),
  _BrewerOption(
    'not_sure',
    'Not sure yet',
    'We’ll teach what you need, when you need it.',
  ),
];

class BrewerScreen extends ConsumerStatefulWidget {
  const BrewerScreen({super.key});

  @override
  ConsumerState<BrewerScreen> createState() => _BrewerScreenState();
}

class _BrewerScreenState extends ConsumerState<BrewerScreen> {
  int? _picked;
  bool _submitting = false;

  Future<void> _finish() async {
    if (_picked == null) return;
    setState(() => _submitting = true);
    ref
        .read(onboardingDraftProvider.notifier)
        .setBrewer(_options[_picked!].key);
    await ref.read(onboardingDraftProvider.notifier).complete();
    if (!mounted) return;
    context.go('/learn');
  }

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
              const SmallcapsLabel('ONBOARDING · 2 OF 2'),
              const SizedBox(height: AppSpacing.base),
              Text('What do you brew with?', style: AppTypography.displayMD()),
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
                label: _submitting ? 'Saving…' : 'Continue',
                onPressed: (_picked == null || _submitting) ? null : _finish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
