import 'package:brew_path/core/config/support_contact_provider.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/services/links/link_provider.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Terms and Privacy, which the App Store requires of a purchase surface.
///
/// **Drawn even while unhosted**, unlike every other link to these pages: on a
/// buying surface their absence is a store-review failure, so an inert link is
/// the lesser of the two (#448). They go live the moment the URLs are set.
class LegalLinks extends ConsumerWidget {
  /// Creates the pair, after [leading] where a surface has its own link first.
  const LegalLinks({
    required this.termsLabel,
    required this.privacyLabel,
    this.leading,
    super.key,
  });

  /// What Terms is called here — the sheet and the screen name it differently.
  final String termsLabel;

  /// What Privacy is called here.
  final String privacyLabel;

  /// A link this surface puts before the pair, such as Restore.
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.read(linkOpenerProvider).open;
    final terms = ref.watch(termsPageProvider);
    final privacy = ref.watch(privacyPageProvider);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xxs,
      children: [
        ?leading,
        LinkButton(
          label: termsLabel,
          onPressed: terms == null ? null : () => open(terms),
        ),
        LinkButton(
          label: privacyLabel,
          onPressed: privacy == null ? null : () => open(privacy),
        ),
      ],
    );
  }
}
