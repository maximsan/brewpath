/// Settings → `ACCOUNT` → Purchases.
library;

import 'package:brew_path/features/monetization/presentation/purchases_panel.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:flutter/material.dart';

/// What the learner owns, and how to get it back on a new phone.
///
/// The frame only: everything that changes with the arm is [PurchasesPanel]'s,
/// in the paywall's own layer.
class PurchasesScreen extends StatelessWidget {
  /// Creates the purchases screen.
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) => const SettingsSubScreen(
    title: SettingsCopy.purchasesTitle,
    children: [
      SettingsSection(
        label: SettingsCopy.purchasesTitle,
        children: [PurchasesPanel()],
      ),
    ],
  );
}
