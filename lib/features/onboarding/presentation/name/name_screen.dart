import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/onboarding/presentation/name/name_controller.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Onboarding step: what the learner would like to be called.
///
/// The last step, and the only optional one — Profile greets by name where
/// there is one and greets plainly where there is not, so skipping costs the
/// learner nothing.
class NameScreen extends ConsumerStatefulWidget {
  /// Creates a [NameScreen].
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  late final NameController _controller;

  /// Longer than any name worth greeting, short enough that the header cannot
  /// be pushed off its own line.
  static const int _maxNameLength = 24;

  @override
  void initState() {
    super.initState();
    _controller = NameController(
      onSubmit: (name) async {
        final draft = ref.read(onboardingDraftProvider.notifier)..setName(name);
        await draft.complete();
      },
      onFinished: () {
        if (mounted) context.goNamed(AppRoutes.learn.name);
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
              const SmallcapsLabel('ONBOARDING · 3 OF 3'),
              const SizedBox(height: AppSpacing.base),
              Text(
                'What should we call you?',
                style: AppText.title(mood: mood),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Only used to say hello. You can skip this.',
                style: AppText.support(mood: mood),
              ),
              const SizedBox(height: AppSpacing.lg + 4),
              TextField(
                autofocus: true,
                maxLength: _maxNameLength,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                enabled: !_controller.submitting,
                style: AppText.body(mood: mood),
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  border: OutlineInputBorder(),
                ),
                onChanged: _controller.type,
                onSubmitted: (_) => _controller.submit(),
              ),
              const Spacer(),
              PrimaryButton(
                label: _controller.submitting
                    ? 'Saving…'
                    : _controller.name == null
                    ? 'Skip'
                    : 'Continue',
                onPressed: _controller.canSubmit ? _controller.submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
