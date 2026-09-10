import 'package:brew_path/core/config/support_contact.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/features/profile/domain/help_faq.dart';
import 'package:brew_path/features/profile/domain/help_faq_provider.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/domain/support_links.dart';
import 'package:brew_path/features/profile/presentation/settings/help_faq_row.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:brew_path/features/tour/domain/app_guide_copy.dart';
import 'package:brew_path/services/links/link_provider.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
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
  /// Which answer is showing. One at a time, as the design opens them.
  int _openIndex = -1;

  @override
  Widget build(BuildContext context) {
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
            // The counts come from the banks, so the answers arrive a frame
            // late; the questions are the same either way, and a heading over
            // nothing reads as a bug.
            _Questions(
              faq: faq.asData?.value,
              openIndex: _openIndex,
              onOpen: _open,
            ),
          ],
        ),
        const _GetInTouch(),
      ],
    );
  }

  void _open(int index) =>
      setState(() => _openIndex = _openIndex == index ? -1 : index);
}

class _Questions extends StatelessWidget {
  const _Questions({
    required this.faq,
    required this.openIndex,
    required this.onOpen,
  });

  final List<HelpQuestion>? faq;
  final int openIndex;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    if (faq case final questions?) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, entry) in questions.indexed)
            HelpFaqRow(
              entry: entry,
              isOpen: index == openIndex,
              onToggle: () => onOpen(index),
            ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Semantics(
        label: SettingsCopy.faqLoadingLabel,
        child: const LoadingIndicator(),
      ),
    );
  }
}

/// The two contact rows, absent while there is no mailbox to open.
///
/// A row that looks live and does nothing is the failure the paywall's
/// disabled links already record, so this draws nothing at all (#531).
class _GetInTouch extends ConsumerWidget {
  const _GetInTouch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (supportEmail case final email?) {
      final version = ref.watch(appVersionProvider).asData?.value;
      final open = ref.read(linkOpenerProvider).open;

      return SettingsSection(
        label: SettingsCopy.getInTouchSection,
        children: [
          SettingsNavRow(
            label: SettingsCopy.emailSupportRow,
            value: email,
            onTap: () => open(supportMailto(email)),
          ),
          SettingsNavRow(
            label: SettingsCopy.reportProblemRow,
            onTap: () => open(problemReportMailto(email, version)),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
