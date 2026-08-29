import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_confirmations.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:brew_path/features/profile/presentation/widgets/appearance_selector.dart';
import 'package:brew_path/features/profile/presentation/widgets/daily_reminder_sheet.dart';
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
/// Two deliberate divergences, both because the app is not the prototype:
///
/// - **`Delete account` is absent.** The design lists it beside Reset
///   progress; there are no accounts to delete — Firebase is gated off and the
///   app stores everything on the device.
/// - **`Restart onboarding` is present**, and the design has no such row. It
///   is the app's own, it works, and removing a working control is not what a
///   parity pass is for. It sits in the same unlabelled block, being the other
///   thing on this screen that throws state away.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final version = ref.watch(appVersionShortProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(SettingsCopy.title),
        leading: IconButton(
          icon: const IconMark(AppIcon.back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          // The design draws the name twice: once in the bar, once as the
          // display heading the sections hang under
          // (`prototype/screens.jsx:523`). The four screens behind this one do
          // the same, through `SettingsSubScreen`.
          const SettingsScreenHeading(title: SettingsCopy.title),
          const SettingsSection(
            label: SettingsCopy.appearanceSection,
            children: [AppearanceSelector()],
          ),
          SettingsSection(
            label: SettingsCopy.practiceSection,
            children: [_PracticeRows(settings: settings)],
          ),
          const SettingsSection(
            label: SettingsCopy.accountSection,
            children: [_AccountRows()],
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

/// `ACCOUNT`: where the learner's identity and purchases will live.
class _AccountRows extends StatelessWidget {
  const _AccountRows();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
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
    ],
  );
}
