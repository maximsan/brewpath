import 'package:brew_path/core/config/app_links_provider.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/domain/support_links.dart';
import 'package:brew_path/features/profile/presentation/settings/about_signature.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:brew_path/services/links/link_provider.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The app's own page: what it is, the fine print, and the way to write in.
///
/// *Rate BrewPath* is not drawn. The design gives it a row, but there is no
/// store listing to rate yet, and a row that looks live and does nothing is
/// the failure #531 already recorded (#532).
class AboutScreen extends ConsumerWidget {
  /// Creates the about screen.
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;

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
        const _SaySomething(),
        const SizedBox(height: AppSpacing.xl),
        const AboutSignature(),
      ],
    );
  }
}

/// The design's four fine-print rows, in its order.
///
/// Terms and Privacy leave the app and are each drawn only once their page
/// exists (#448); the two below them are the app's own pages and always are.
class _FinePrintRows extends ConsumerWidget {
  const _FinePrintRows();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.read(linkOpenerProvider).open;
    final privacy = ref.watch(privacyPageProvider);
    final terms = ref.watch(termsPageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (privacy case final url?)
          SettingsNavRow(
            label: SettingsCopy.privacyRow,
            isExternal: true,
            onTap: () => open(url),
          ),
        if (terms case final url?)
          SettingsNavRow(
            label: SettingsCopy.termsRow,
            isExternal: true,
            onTap: () => open(url),
          ),
        SettingsNavRow(
          label: SettingsCopy.acknowledgementsRow,
          onTap: () =>
              context.pushNamed(AppRoutes.settingsAcknowledgements.name),
        ),
        const _LicensesRow(),
      ],
    );
  }
}

/// Flutter's own license page, which reads `LicenseRegistry`.
///
/// Every dependency registers its own licence there, so the page is generated
/// from what the build actually ships and no list is written by hand.
class _LicensesRow extends ConsumerWidget {
  const _LicensesRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched, not read at the tap: a learner who reaches the row before
    // `package_info` answers would otherwise open a page naming no build.
    final version = ref.watch(appVersionProvider).asData?.value;

    return SettingsNavRow(
      label: SettingsCopy.licensesRow,
      onTap: () => showLicensePage(
        context: context,
        applicationName: AppLabels.appName,
        applicationVersion: version,
      ),
    );
  }
}

/// The design's `SAY SOMETHING` group — each row behind the one thing it
/// needs, and the group absent while neither of them exists.
///
/// *Rate BrewPath* waits on an App Store listing and *Say hello* on the
/// mailbox (#531). Setting either constant draws its row with no other change,
/// so neither is a row the app has to grow later.
class _SaySomething extends ConsumerWidget {
  const _SaySomething();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final review = ref.watch(appStoreReviewProvider);
    final mailbox = ref.watch(supportMailboxProvider);
    if (review == null && mailbox == null) return const SizedBox.shrink();

    final open = ref.read(linkOpenerProvider).open;

    return SettingsSection(
      label: SettingsCopy.saySomethingSection,
      children: [
        if (review case final url?)
          SettingsNavRow(
            label: SettingsCopy.rateRow,
            isExternal: true,
            onTap: () => open(url),
          ),
        if (mailbox case final address?)
          SettingsNavRow(
            label: SettingsCopy.sayHelloRow,
            value: address,
            isExternal: true,
            onTap: () => open(supportMailto(address)),
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
