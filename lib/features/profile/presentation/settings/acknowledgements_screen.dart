import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/features/profile/domain/acknowledgements_provider.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_sub_screen.dart';
import 'package:brew_path/services/links/link_provider.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Every work the dictionary's entries cite, credited once.
///
/// Nothing is authored for this page: it is the term bank's own sources,
/// deduplicated, so a source added to a term is credited here by that edit
/// alone (#532).
class AcknowledgementsScreen extends ConsumerWidget {
  /// Creates the acknowledgements screen.
  const AcknowledgementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(acknowledgementsProvider);

    return SettingsSubScreen(
      title: SettingsCopy.acknowledgementsTitle,
      children: [
        const _Blurb(),
        SettingsSection(
          label: SettingsCopy.sourcesSection,
          children: _rows(ref, sources),
        ),
      ],
    );
  }

  List<Widget> _rows(
    WidgetRef ref,
    AsyncValue<List<DictionarySource>> sources,
  ) {
    final works = sources.asData?.value;
    if (works != null && works.isNotEmpty) {
      final open = ref.read(linkOpenerProvider).open;
      return [
        for (final source in works)
          SettingsNavRow(
            label: source.label,
            isExternal: source.url != null,
            onTap: source.url == null
                ? null
                : () => open(Uri.parse(source.url!)),
          ),
      ];
    }

    // `hasError`, not an `AsyncError` pattern: a failed provider keeps the
    // loading flag while Riverpod retries, so matching the state would leave
    // a bank that cannot be read gathering for ever.
    if (sources.hasError) {
      return const [
        SettingsPlaceholder(SettingsCopy.acknowledgementsUnavailable),
      ];
    }
    return const [_Gathering()];
  }
}

/// What the page opens on: what the list below it is.
class _Blurb extends StatelessWidget {
  const _Blurb();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
    child: Text(
      SettingsCopy.acknowledgementsBlurb,
      style: AppText.body(mood: context.mood, color: context.mood.inkMute),
    ),
  );
}

/// The line the list shows while the bank is being read.
///
/// A line rather than a spinner, as Help's counted answer is: the bundle
/// answers in a frame, and nothing that brief should be drawn as motion.
class _Gathering extends StatelessWidget {
  const _Gathering();

  @override
  Widget build(BuildContext context) => Semantics(
    label: SettingsCopy.acknowledgementsLoadingLabel,
    excludeSemantics: true,
    child: const SettingsPlaceholder(SettingsCopy.acknowledgementsGathering),
  );
}
