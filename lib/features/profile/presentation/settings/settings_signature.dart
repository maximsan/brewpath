import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The centred mono block a settings page closes on.
///
/// One line, or two where the design gives the page an aside under it — the
/// aside is the same line drawn fainter, not a second kind of thing. Settings
/// closes on the line alone; About adds the aside.
class SettingsSignature extends StatelessWidget {
  /// Creates the block: [line], and [aside] under it where there is one.
  const SettingsSignature({required this.line, this.aside, super.key});

  /// The design's `opacity: 0.7` on the second line.
  static const double _asideOpacity = 0.7;

  /// What the page signs off with.
  final String line;

  /// The fainter line under it, or null for a page that closes on one.
  final String? aside;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Column(
        children: [
          _SignatureLine(line, mood: mood),
          if (aside case final under?) ...[
            const SizedBox(height: AppSpacing.xxs),
            Opacity(
              opacity: _asideOpacity,
              child: _SignatureLine(under, mood: mood),
            ),
          ],
        ],
      ),
    );
  }
}

/// One line of the block, read out as written rather than shouted.
class _SignatureLine extends StatelessWidget {
  const _SignatureLine(this.text, {required this.mood});

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
