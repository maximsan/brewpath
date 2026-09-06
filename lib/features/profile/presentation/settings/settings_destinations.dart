/// The four screens the design's `ACCOUNT` and `SUPPORT` rows lead to.
///
/// **They are frames, not features.** Each is reached from a row the design
/// draws, so no row on Settings is dead; behind the row is the screen's real
/// title and its real sections, with the parts the app has not built named
/// rather than left blank. Two of them are waiting on seams that are
/// deliberately closed — the payments service is a no-op and Firebase is gated
/// off — and neither is opened here.
///
/// Help is the exception that is already real: the App Guide row lives here,
/// which is where the design files it. It sat on the Settings root only because
/// this screen did not exist yet, which its own comment said at the time.
library;

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:brew_path/features/tour/domain/app_guide_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Signing in, and progress across devices.
class AccountSyncScreen extends StatelessWidget {
  /// Creates the account screen.
  const AccountSyncScreen({super.key});

  @override
  Widget build(BuildContext context) => const SettingsSubScreen(
    title: SettingsCopy.accountSyncTitle,
    children: [
      SettingsSection(
        label: SettingsCopy.cloudSyncSection,
        children: [SettingsPlaceholder(SettingsCopy.cloudSyncComing)],
      ),
    ],
  );
}

/// What the learner owns, and how to get it back on a new phone.
class PurchasesScreen extends StatelessWidget {
  /// Creates the purchases screen.
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) => const SettingsSubScreen(
    title: SettingsCopy.purchasesTitle,
    children: [
      SettingsSection(
        label: SettingsCopy.purchasesTitle,
        children: [SettingsPlaceholder(SettingsCopy.purchasesComing)],
      ),
    ],
  );
}

/// Help and support — and, in it, the written App Guide.
class HelpSupportScreen extends StatelessWidget {
  /// Creates the help screen.
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) => SettingsSubScreen(
    title: SettingsCopy.helpTitle,
    children: [
      SettingsSection(
        label: SettingsCopy.learnTheAppSection,
        children: [
          Builder(
            builder: (context) => SettingsNavRow(
              label: AppGuideCopy.title,
              sub: AppGuideCopy.settingsRowBody,
              onTap: () => context.pushNamed(AppRoutes.appGuide.name),
            ),
          ),
        ],
      ),
      const SettingsSection(
        label: SettingsCopy.commonQuestionsSection,
        children: [SettingsPlaceholder(SettingsCopy.helpComing)],
      ),
    ],
  );
}

/// The app's own page: what it is, and the fine print.
class AboutScreen extends ConsumerWidget {
  /// Creates the about screen.
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final version = ref.watch(appVersionProvider);

    return SettingsSubScreen(
      title: SettingsCopy.aboutTitle,
      children: [
        // The design's brand block: the kicker under the app's name, then what
        // the app is.
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: SmallcapsLabel(SettingsCopy.aboutTagline),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Text(
            SettingsCopy.aboutBlurb,
            style: AppText.body(mood: mood, color: mood.inkMute),
          ),
        ),
        const SettingsSection(
          label: SettingsCopy.finePrintSection,
          children: [SettingsPlaceholder(SettingsCopy.aboutComing)],
        ),
        const SizedBox(height: AppSpacing.lg),
        SettingsVersionLine(version: version.asData?.value),
      ],
    );
  }
}
