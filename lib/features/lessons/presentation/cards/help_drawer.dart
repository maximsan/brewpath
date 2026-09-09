import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/shared/models/content/card_kind_help.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The kicker over the drawer's title.
const String howToPlayLabel = 'How to play';

/// What closes the drawer, which is the only thing it offers.
const String _dismissLabel = 'Got it';

/// Opens the drawer explaining how [help]'s format is played.
Future<void> showHelpDrawer(BuildContext context, CardKindHelp help) =>
    showAppSheet<void>(
      context: context,
      eyebrow: howToPlayLabel,
      title: help.title,
      builder: (_) => HelpDrawerBody(help: help),
    );

/// What the drawer says: the format in a sentence, then the three steps.
///
/// The words are the design's, extracted rather than written here, so a format
/// is explained the same way wherever it is met.
class HelpDrawerBody extends StatelessWidget {
  /// Creates a [HelpDrawerBody].
  const HelpDrawerBody({required this.help, super.key});

  /// The entry this drawer is reading.
  final CardKindHelp help;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          help.blurb,
          style: AppText.body(mood: mood, color: mood.inkMute),
        ),
        SizedBox(height: OffTokens.helpStepsTop.value),
        for (final (index, step) in help.steps.indexed) ...[
          if (index > 0) SizedBox(height: OffTokens.helpStepGap.value),
          _Step(ordinal: index + 1, text: step),
        ],
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: _dismissLabel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// One numbered step: its `01` in the accent, then what to do.
class _Step extends StatelessWidget {
  const _Step({required this.ordinal, required this.text});

  final int ordinal;
  final String text;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$ordinal'.padLeft(2, '0'),
          style: AppText.support(
            face: AppFace.mono,
            color: mood.accent,
            tracking: AppTracking.count,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text, style: AppText.support(color: mood.ink)),
        ),
      ],
    );
  }
}
