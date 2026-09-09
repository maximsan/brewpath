import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/core/widgets/sub_screen_scaffold.dart';
import 'package:brew_path/features/profile/domain/learner_name.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_confirmations.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:brew_path/features/profile/presentation/widgets/appearance_selector.dart';
import 'package:brew_path/features/profile/presentation/widgets/name_sheet.dart';
import 'package:brew_path/shared/storage/settings_record.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings, in the design's four sections and their order.
///
/// The foot carries no label, `Delete account` drawn and inert while Firebase
/// is off, and `Restart onboarding`, which the design lacks and #383 needs:
/// the owner's rulings on #395. The design's reminder rows under `PRACTICE`
/// wait for #443.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final version = ref.watch(appVersionShortProvider);

    return SubScreenScaffold(
      title: SettingsCopy.title,
      body: (context, scrollPadding) => ListView(
        padding: scrollPadding.copyWith(bottom: AppSpacing.xl),
        children: [
          // The design draws the name twice: large here, and small in the
          // bar once this has scrolled under it. The four screens behind this
          // one do the same, through `SettingsSubScreen`.
          const SettingsScreenHeading(title: SettingsCopy.title),
          const SettingsSection(
            label: SettingsCopy.appearanceSection,
            children: [AppearanceSelector()],
          ),
          SettingsSection(
            label: SettingsCopy.practiceSection,
            children: [_PracticeRows(settings: settings)],
          ),
          SettingsSection(
            label: SettingsCopy.accountSection,
            children: [_AccountRows(settings: settings)],
          ),
          const SettingsSection(
            label: SettingsCopy.supportSection,
            children: [_SupportRows()],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _DestructiveRows(),
          const SizedBox(height: AppSpacing.xl),
          SettingsVersionLine(version: version.asData?.value),
        ],
      ),
    );
  }
}

/// The `PRACTICE` rows: sound and haptics. The design's two reminder rows are
/// hidden until reminders exist (#443).
class _PracticeRows extends ConsumerWidget {
  const _PracticeRows({required this.settings});

  final AsyncValue<UserSettingsRecord> settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(settingsControllerProvider.notifier);

    return settings.when(
      loading: () => const SettingsPlaceholder('Reading your preferences…'),
      error: (error, _) => SettingsPlaceholder('$error'),
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsNavRow(
            label: SettingsCopy.soundRow,
            toggleValue: state.soundEnabled,
            onToggle: (_) => controller.toggleSound(),
          ),
          SettingsNavRow(
            label: SettingsCopy.hapticsRow,
            toggleValue: state.hapticsEnabled,
            onToggle: (_) => controller.toggleHaptics(),
          ),
        ],
      ),
    );
  }
}

/// `ACCOUNT`: the learner's identity and purchases.
///
/// The name row is the other half of ADR-0010's ruling: the onboarding step
/// stays optional *because* the answer can be changed here afterwards.
class _AccountRows extends ConsumerWidget {
  const _AccountRows({required this.settings});

  final AsyncValue<UserSettingsRecord> settings;

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final picked = await NameSheet.show(context, current: current);
    if (picked == null) return;

    await ref.read(settingsControllerProvider.notifier).setLearnerName(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => settings.when(
    loading: () => const SettingsPlaceholder('Reading your details…'),
    error: (error, _) => SettingsPlaceholder('$error'),
    data: (state) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsNavRow(
          label: SettingsCopy.nameRow,
          value: LearnerName.rowValue(state.learnerName),
          onTap: () => _editName(context, ref, state.learnerName),
        ),
        SettingsNavRow(
          label: SettingsCopy.accountRow,
          onTap: () => context.pushNamed(AppRoutes.settingsAccount.name),
        ),
        SettingsNavRow(
          label: SettingsCopy.purchasesRow,
          // Every learner is on the free tier: the payments service is a no-op
          // stub, so there is no purchase for this to report.
          value: SettingsCopy.freeTier,
          onTap: () => context.pushNamed(AppRoutes.settingsPurchases.name),
        ),
      ],
    ),
  );
}

/// `SUPPORT`: help, and the app's own page.
class _SupportRows extends StatelessWidget {
  const _SupportRows();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SettingsNavRow(
        label: SettingsCopy.helpRow,
        onTap: () => context.pushNamed(AppRoutes.settingsHelp.name),
      ),
      SettingsNavRow(
        label: SettingsCopy.aboutRow,
        onTap: () => context.pushNamed(AppRoutes.settingsAbout.name),
      ),
    ],
  );
}

/// The unlabelled block at the foot: the two rows that throw state away.
class _DestructiveRows extends ConsumerWidget {
  const _DestructiveRows();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SettingsNavRow(
        label: SettingsCopy.resetProgressRow,
        isDestructive: true,
        onTap: () => confirmResetProgress(context, ref),
      ),
      SettingsNavRow(
        label: SettingsCopy.restartOnboardingRow,
        isDestructive: true,
        onTap: () => confirmRestartOnboarding(context, ref),
      ),
      // No `onTap`, so it is not a button and nothing happens: an account has
      // to exist before deleting one can mean anything.
      const SettingsNavRow(
        label: SettingsCopy.deleteAccountRow,
        isDestructive: true,
        isDimmed: true,
      ),
    ],
  );
}
