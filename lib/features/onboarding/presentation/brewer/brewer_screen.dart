import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/pick_card.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/onboarding/presentation/brewer/brewer_controller.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
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

/// Onboarding step: pick your usual brewing method.
class BrewerScreen extends ConsumerStatefulWidget {
  /// Creates a [BrewerScreen].
  const BrewerScreen({super.key});

  @override
  ConsumerState<BrewerScreen> createState() => _BrewerScreenState();
}

class _BrewerScreenState extends ConsumerState<BrewerScreen> {
  late final BrewerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BrewerController(
      onSubmit: (index) async {
        ref
            .read(onboardingDraftProvider.notifier)
            .setBrewer(_options[index].key);
      },
      // The flow is completed by the name step, which is the last one — the
      // draft is not persisted until then, so a learner who quits here is
      // still un-onboarded and comes back to the start rather than to a
      // half-written row.
      onFinished: () {
        if (mounted) context.goNamed(AppRoutes.onboardingName.name);
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
              const SmallcapsLabel('ONBOARDING · 2 OF 3'),
              const SizedBox(height: AppSpacing.base),
              Text(
                'What do you brew with?',
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
                label: _controller.submitting ? 'Saving…' : 'Continue',
                onPressed: _controller.canSubmit ? _controller.submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
