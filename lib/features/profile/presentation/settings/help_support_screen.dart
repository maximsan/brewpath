import 'package:brew_path/core/config/support_contact_provider.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/features/profile/domain/help_faq_provider.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/domain/support_links.dart';
import 'package:brew_path/features/profile/presentation/settings/help_faq_row.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:brew_path/features/tour/domain/app_guide_copy.dart';
import 'package:brew_path/services/links/link_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Help and support — the written App Guide, the FAQ, and the way to write in.
///
/// The design's closing *"We reply within a day"* is not drawn: one developer
/// cannot promise a reply time, and nothing replaces it (#531).
class HelpSupportScreen extends ConsumerStatefulWidget {
  /// Creates the help screen.
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  /// Which answer is showing, or null with all four closed — one at a time,
  /// as the design opens them.
  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    // The questions never wait: only the Foundations answer is counted from
    // the banks, and it says so in its own row rather than holding the list.
    final faq = ref.watch(helpQuestionsProvider);

    return SettingsSubScreen(
      title: SettingsCopy.helpTitle,
      children: [
        SettingsSection(
          label: SettingsCopy.learnTheAppSection,
          children: [
            SettingsNavRow(
              label: AppGuideCopy.title,
              sub: AppGuideCopy.settingsRowBody,
              onTap: () => context.pushNamed(AppRoutes.appGuide.name),
            ),
          ],
        ),
        SettingsSection(
          label: SettingsCopy.commonQuestionsSection,
          children: [
            for (final (index, entry) in faq.indexed)
              HelpFaqRow(
                entry: entry,
                isOpen: index == _openIndex,
                onToggle: () => _open(index),
              ),
          ],
        ),
        const _GetInTouch(),
      ],
    );
  }

  void _open(int index) =>
      setState(() => _openIndex = _openIndex == index ? null : index);
}

/// The two contact rows, absent while there is no mailbox to open.
///
/// A row that looks live and does nothing is the failure the paywall's
/// disabled links already record, so this draws nothing at all (#531).
class _GetInTouch extends ConsumerWidget {
  const _GetInTouch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mailbox = ref.watch(supportMailboxProvider);
    if (mailbox == null) return const SizedBox.shrink();

    final version = ref.watch(appVersionProvider).asData?.value;
    final open = ref.read(linkOpenerProvider).open;

    return SettingsSection(
      label: SettingsCopy.getInTouchSection,
      children: [
        SettingsNavRow(
          label: SettingsCopy.emailSupportRow,
          value: mailbox,
          onTap: () => open(supportMailto(mailbox)),
        ),
        SettingsNavRow(
          label: SettingsCopy.reportProblemRow,
          onTap: () => open(problemReportMailto(mailbox, version)),
        ),
      ],
    );
  }
}
