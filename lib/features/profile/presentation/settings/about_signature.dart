import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What closes About: the version over the build, then the signature.
///
/// Two lines, where Settings closes on one — the design writes About's as
/// `Version 0.1 · build 240618` over a fainter second line, because the build
/// number is for whoever is reading a crash report.
class AboutSignature extends ConsumerWidget {
  /// Creates the closing block.
  const AboutSignature({super.key});

  /// The design's `opacity: 0.7` on the second line.
  static const double _signatureOpacity = 0.7;

  /// Shown while `package_info` is still answering.
  static const _pending = '—';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final parts = ref.watch(appVersionPartsProvider).asData?.value;
    final version =
        'Version ${parts?.version ?? _pending} · '
        'build ${parts?.build ?? _pending}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Column(
        children: [
          _Line(version, mood: mood),
          const SizedBox(height: AppSpacing.xxs),
          Opacity(
            opacity: _signatureOpacity,
            child: _Line(SettingsCopy.aboutSignature, mood: mood),
          ),
        ],
      ),
    );
  }
}

/// One centred mono line, read out as it was written rather than shouted.
class _Line extends StatelessWidget {
  const _Line(this.text, {required this.mood});

  final String text;
  final MoodColors mood;

  @override
  Widget build(BuildContext context) => Semantics(
    label: text,
    excludeSemantics: true,
    child: Text(
      text.toUpperCase(),
      textAlign: TextAlign.center,
      style: AppText.micro(mood: mood, color: mood.inkMute),
    ),
  );
}
