import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_signature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What About signs off with: the version over the build, then its aside.
///
/// Two lines where Settings has one, which is how the design writes each —
/// the build number is for whoever is reading a crash report. The block they
/// are drawn in is [SettingsSignature], shared with Settings.
class AboutSignature extends ConsumerWidget {
  /// Creates the closing block.
  const AboutSignature({super.key});

  /// Shown while `package_info` is still answering.
  static const _pending = '—';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parts = ref.watch(appVersionPartsProvider).asData?.value;

    return SettingsSignature(
      line:
          'Version ${parts?.version ?? _pending} · '
          'build ${parts?.build ?? _pending}',
      aside: SettingsCopy.aboutSignature,
    );
  }
}
