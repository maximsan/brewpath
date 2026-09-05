import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/core/widgets/sub_screen_scaffold.dart';
import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:brew_path/features/profile/domain/learner_name.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_confirmations.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:brew_path/features/profile/presentation/widgets/appearance_selector.dart';
import 'package:brew_path/features/profile/presentation/widgets/daily_reminder_sheet.dart';
import 'package:brew_path/features/profile/presentation/widgets/name_sheet.dart';
import 'package:brew_path/shared/storage/settings_record.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings, in the design's four sections.
///
/// The order and the grouping are the design's, not the app's
/// (`prototype/screens.jsx:526-562`): `APPEARANCE` leads, the preference
/// toggles are filed under `PRACTICE` beside the reminder they belong with,
/// `ACCOUNT` and `SUPPORT` are pure navigation, and the destructive block at
/// the foot carries **no label** — a heading over it would announce it before
/// the learner has any reason to look there.
///
/// The destructive block carries three rows, which is one more than the design
/// and one more than works. Both are the owner's rulings on #395, not this
/// file's:
///
/// - **`Delete account` is drawn and inert.** The design lists it, and there
///   is nothing to delete — Firebase is gated off and the app keeps everything
///   on the device. Shown rather than omitted so the block is the design's
///   shape from the start; dimmed and unpressable so it cannot promise
///   anything, which is the trade the ruling accepted.
/// - **`Restart onboarding` is kept**, and the design has no such row. It is
///   the app's own, it works, and it is the only way back through the intro
///   #383 built.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final version = ref.watch(appVersionShortProvider);

    return SubScreenScaffold(
      title: SettingsCopy.title,
      onBack: () => context.pop(),
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

/// The four preference rows the design files under `PRACTICE`.
class _PracticeRows extends ConsumerWidget {
  const _PracticeRows({required this.settings});

  final AsyncValue<UserSettingsRecord> settings;

  Future<void> _pickReminder(
    BuildContext context,
    WidgetRef ref,
    UserSettingsRecord current,
  ) async {
    final picked = await DailyReminderSheet.show(
      context,
      current: current.dailyReminderTime,
    );
    if (picked == null) return;

    await ref.read(settingsControllerProvider.notifier).setReminderTime(picked);
  }

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
            label: SettingsCopy.notificationsRow,
            toggleValue: state.notificationsEnabled,
            onToggle: (_) => controller.toggleNotifications(),
          ),
          SettingsNavRow(
            label: SettingsCopy.reminderRow,
            value: DailyReminder.rowValue(
              enabled: state.notificationsEnabled,
              time: state.dailyReminderTime,
            ),
            isDimmed: !state.notificationsEnabled,
            onTap: () => _pickReminder(context, ref, state),
          ),
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
