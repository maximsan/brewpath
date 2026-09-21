import 'package:brew_path/core/widgets/confirm_sheet.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:brew_path/features/profile/domain/reminder_actions.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/widgets/daily_reminder_sheet.dart';
import 'package:brew_path/services/reminders/reminder_provider.dart';
import 'package:brew_path/services/reminders/reminder_scheduler.dart';
import 'package:brew_path/shared/storage/settings_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the app says when the OS will not deliver the reminder the learner
/// just asked for.
abstract final class ReminderRefusedCopy {
  /// The sheet's title.
  static const title = 'Notifications are off';

  /// Why nothing happened, and where the answer lives.
  ///
  /// It names iOS Settings because that is the only place the refusal can be
  /// undone — the app is never asked a second time once it has been told no.
  static const body =
      'Your phone isn’t letting BrewPath send anything, so a reminder '
      'wouldn’t arrive. You can turn notifications back on for BrewPath in '
      'iOS Settings.';

  /// The way back.
  static const confirm = 'Open Settings';

  /// The way out.
  static const cancel = 'Not now';
}

/// The design's two reminder rows: the switch, and the time it arrives.
///
/// Two controls for one reminder, as the design draws them — and the time row
/// is dim while the switch is off, still pressable, because choosing a time is
/// how the reminder gets turned on.
class ReminderRows extends ConsumerWidget {
  /// Creates the rows over [settings].
  const ReminderRows({required this.settings, super.key});

  /// The settings row as stored.
  final UserSettingsRecord settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SettingsNavRow(
        label: SettingsCopy.notificationsRow,
        toggleValue: settings.notificationsEnabled,
        onToggle: (wanted) => wanted ? _ask(context, ref) : dropReminder(ref),
      ),
      SettingsNavRow(
        label: SettingsCopy.reminderRow,
        value: DailyReminder.rowValue(
          enabled: settings.notificationsEnabled,
          time: settings.dailyReminderTime,
        ),
        isDimmed: !settings.notificationsEnabled,
        onTap: () => _pickTime(context, ref),
      ),
    ],
  );

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final picked = await DailyReminderSheet.show(
      context,
      current: settings.dailyReminderTime,
    );
    if (picked == null || !context.mounted) return;

    await _ask(context, ref, time: picked);
  }

  /// Asks for the reminder, and offers the way back if the OS says no.
  Future<void> _ask(BuildContext context, WidgetRef ref, {String? time}) async {
    final permission = await askForReminder(ref, time: time);
    if (permission != ReminderPermission.denied || !context.mounted) return;

    final open = await showConfirmSheet(
      context: context,
      title: ReminderRefusedCopy.title,
      body: ReminderRefusedCopy.body,
      actions: const ConfirmActions(
        confirm: ReminderRefusedCopy.confirm,
        cancel: ReminderRefusedCopy.cancel,
      ),
    );
    if (!open) return;

    await ref.read(reminderSchedulerProvider).openSystemSettings();
  }
}
