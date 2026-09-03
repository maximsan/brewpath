/// The two questions the destructive block asks before it acts.
///
/// They live beside each other rather than on the screen that shows the rows,
/// because what they have in common is the shape — ask, then throw something
/// away — and because their copy is the interesting part: it is the last thing
/// a learner reads before losing work, and it belongs next to the wording it
/// warns about rather than in the copy register with the row labels.
library;

import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/overlay_barrier.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// How long the "progress reset" banner stays before dismissing itself.
const _bannerLinger = Duration(seconds: 2);

/// Asks before wiping progress, then wipes it and says so.
Future<void> confirmResetProgress(BuildContext context, WidgetRef ref) async {
  final confirmed = await showOverlayDialog<bool>(
    context: context,
    overlay: OverlayColors.dimModal,
    builder: (ctx) => AlertDialog(
      title: const Text('Reset all progress?'),
      content: const Text(
        'This will remove your completed lessons, points, streak, '
        'unlocked cards, and all local progress. '
        'This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: ctx.mood.berry),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Reset'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final mood = context.mood;
  await resetProgress(ref);

  messenger
    ..hideCurrentMaterialBanner()
    ..showMaterialBanner(
      MaterialBanner(
        content: const Text('Progress reset.'),
        leading: IconMark(AppIcon.check, color: mood.accent),
        backgroundColor: mood.surface,
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  Timer(_bannerLinger, messenger.hideCurrentMaterialBanner);
}

/// Clears the onboarding gate and returns to Welcome.
///
/// Points, streak and collected cards are untouched — that is
/// [confirmResetProgress]'s job, and the copy says so, because two rows that
/// both "start again" have to be told apart before either is tapped.
Future<void> confirmRestartOnboarding(
  BuildContext context,
  WidgetRef ref,
) async {
  final confirmed = await showOverlayDialog<bool>(
    context: context,
    overlay: OverlayColors.dimModal,
    builder: (ctx) => AlertDialog(
      title: const Text('Restart onboarding?'),
      content: const Text(
        "You'll go back through the Welcome screen and can set your name "
        'again. Your points, streak, and collected cards stay as they are.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Restart'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;
  if (!context.mounted) return;

  await ref.read(onboardingRepositoryProvider).resetOnboarding();
  ref.invalidate(onboardingCompletedProvider);
  if (!context.mounted) return;

  context.goNamed(AppRoutes.welcome.name);
}
