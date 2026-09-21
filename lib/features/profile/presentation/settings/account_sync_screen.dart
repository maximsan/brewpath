import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:flutter/material.dart';

/// Signing in, and progress across devices.
///
/// A frame, not a feature: the sections are named and the one the app has not
/// built says so rather than sitting blank.
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
