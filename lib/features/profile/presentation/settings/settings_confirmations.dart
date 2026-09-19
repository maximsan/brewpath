/// The two questions the destructive block asks before it acts.
///
/// They live beside each other rather than on the screen that shows the rows,
/// because what they have in common is the shape — ask, then throw something
/// away — and because their copy is the last thing a learner reads before
/// losing work, so it belongs next to the wording it warns about.
library;

import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/confirm_sheet.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/features/profile/domain/reset_summary.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// How long the "progress reset" banner stays before dismissing itself.
const _bannerLinger = Duration(seconds: 2);

/// The words Reset asks in.
abstract final class ResetCopy {
  /// The sheet's question.
  static const title = 'Start again from seed?';

  /// What it costs, in the design's own sentence.
  static const body =
      'Your tree returns to a bare seed, every lesson locks back to the '
      'start, and your saved items are cleared. There’s no undo.';

  /// The catch-all under the seven lines, so nothing cleared goes unmentioned
  /// without naming fields a learner would not recognise.
  static const closingLine = 'Everything else you’ve earned goes with them.';

  /// The confirm, on berry.
  static const confirm = 'Reset everything';

  /// What the banner says once it is done.
  static const banner = 'Progress reset.';

  /// How that banner is dismissed by hand.
  static const dismissBanner = 'Dismiss';
}

/// The words Restart onboarding asks in.
///
/// The design draws no confirm for this row, so these are the app's own —
/// unchanged from the dialog this replaced.
abstract final class RestartOnboardingCopy {
  /// The sheet's question.
  static const title = 'Restart onboarding?';

  /// What it does, and what it leaves alone.
  static const body =
      'You’ll go back through the Welcome screen and can set your name '
      'again. Your points, streak, and collected cards stay as they are.';

  /// The confirm. Plain, not berry: nothing is thrown away here.
  static const confirm = 'Restart';

  /// The cancel. Not the sheet's default, which is written for Reset.
  static const cancel = 'Cancel';
}

/// Asks before wiping progress, then wipes it and says so.
///
/// The seven figures resolve before the sheet opens, so it never draws a
/// number it would have to correct — and a read that fails opens nothing,
/// which leaves the progress intact.
Future<void> confirmResetProgress(BuildContext context, WidgetRef ref) async {
  final lines = await ref.read(resetSummaryProvider.future);
  if (!context.mounted) return;

  final confirmed = await showConfirmSheet(
    context: context,
    title: ResetCopy.title,
    body: ResetCopy.body,
    stakes: ConfirmStakes(lines: lines, closingLine: ResetCopy.closingLine),
    actions: const ConfirmActions.destructive(confirm: ResetCopy.confirm),
  );

  if (!confirmed || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final mood = context.mood;
  await resetProgress(ref);

  messenger
    ..hideCurrentMaterialBanner()
    ..showMaterialBanner(
      MaterialBanner(
        content: const Text(ResetCopy.banner),
        leading: IconMark(AppIcon.check, color: mood.accent),
        backgroundColor: mood.surface,
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text(ResetCopy.dismissBanner),
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
/// both "start again" have to be told apart before either is tapped. No lines
/// and no berry: this sheet asks, it does not warn.
Future<void> confirmRestartOnboarding(
  BuildContext context,
  WidgetRef ref,
) async {
  final confirmed = await showConfirmSheet(
    context: context,
    title: RestartOnboardingCopy.title,
    body: RestartOnboardingCopy.body,
    actions: const ConfirmActions(
      confirm: RestartOnboardingCopy.confirm,
      cancel: RestartOnboardingCopy.cancel,
    ),
  );

  if (!confirmed || !context.mounted) return;

  await ref.read(onboardingRepositoryProvider).resetOnboarding();
  ref.invalidate(onboardingCompletedProvider);
  if (!context.mounted) return;

  context.goNamed(AppRoutes.welcome.name);
}
