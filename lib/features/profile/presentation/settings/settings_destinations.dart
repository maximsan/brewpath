/// Three of the four screens the design's `ACCOUNT` and `SUPPORT` rows lead
/// to; Help is its own file.
///
/// **They are frames, not features.** Behind each row is the screen's real
/// sections, with what the app has not built named rather than left blank; the
/// payments service is a no-op and Firebase is gated off.
library;

import 'package:brew_path/core/config/app_links_provider.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:brew_path/services/links/link_provider.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      // The page is about the app, so it opens on the app — not on the menu
      // row that reached it. `About` stays in the bar, as on every other page
      // behind Settings.
      opening: const _BrandBlock(),
      children: [
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          // Centred with the block above it, which is how the design sets the
          // whole opening — the fine print below returns to the left.
          child: Text(
            SettingsCopy.aboutBlurb,
            textAlign: TextAlign.center,
            style: AppText.body(mood: mood, color: mood.inkMute),
          ),
        ),
        const SettingsSection(
          label: SettingsCopy.finePrintSection,
          children: [_FinePrintRows()],
        ),
        const SizedBox(height: AppSpacing.lg),
        SettingsVersionLine(version: version.asData?.value),
      ],
    );
  }
}

/// Terms and Privacy, each drawn only once its page exists (#448).
///
/// Acknowledgements and the open-source licenses are #532's, so the
/// placeholder stays for as long as either of those is unbuilt.
class _FinePrintRows extends ConsumerWidget {
  const _FinePrintRows();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.read(linkOpenerProvider).open;
    final terms = ref.watch(termsPageProvider);
    final privacy = ref.watch(privacyPageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (terms case final url?)
          SettingsNavRow(
            label: SettingsCopy.termsRow,
            onTap: () => open(url),
          ),
        if (privacy case final url?)
          SettingsNavRow(
            label: SettingsCopy.privacyRow,
            onTap: () => open(url),
          ),
        // Names only what is still missing, so the line does not promise a
        // row sitting right above it.
        SettingsPlaceholder(
          terms != null && privacy != null
              ? SettingsCopy.aboutComingWithLegal
              : SettingsCopy.aboutComing,
        ),
      ],
    );
  }
}

/// What About opens on: the mascot, the app's name, and what it is.
///
/// Centred as one block — the one place in Settings that departs from the
/// left-aligned heading its four screens share.
class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  /// The design's `Roasty size={132}`.
  static const double _companionSize = 132;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Column(
        children: [
          // Named by the app's name below it; the drawing says nothing a
          // reader can act on.
          const ExcludeSemantics(
            child: Roasty(state: RoastyState.idle, size: _companionSize),
          ),
          const SizedBox(height: AppSpacing.base),
          Semantics(
            header: true,
            child: Text(
              AppLabels.appName,
              textAlign: TextAlign.center,
              style: AppText.display(mood: mood),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const SmallcapsLabel(SettingsCopy.aboutTagline),
        ],
      ),
    );
  }
}
