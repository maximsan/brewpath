import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The chrome the four screens behind Settings share.
///
/// The design gives each of them the same frame — a back bar carrying the
/// title, then the title again as a display heading over the sections
/// (`prototype/settings.jsx:292`). One scaffold rather than four, for the same
/// reason the rows are one component: four copies are four chances to drift.
class SettingsSubScreen extends StatelessWidget {
  /// Creates a sub-screen titled [title] over [children].
  const SettingsSubScreen({
    required this.title,
    required this.children,
    super.key,
  });

  /// The screen's name, in the bar and as its heading.
  final String title;

  /// The sections, in the design's order.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const IconMark(AppIcon.back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.sm,
              AppSpacing.gutter,
              AppSpacing.md,
            ),
            child: Semantics(
              header: true,
              child: Text(title, style: AppText.display(mood: mood)),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// A section of a settings screen: its smallcaps label, then its rows.
class SettingsSection extends StatelessWidget {
  /// Creates a labelled section.
  const SettingsSection({
    required this.label,
    required this.children,
    super.key,
  });

  /// The design's smallcaps heading for the group.
  final String label;

  /// The rows under it.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.md,
          AppSpacing.gutter,
          AppSpacing.xxs,
        ),
        child: SmallcapsLabel(label, isHeader: true),
      ),
      ...children,
    ],
  );
}

/// What a section will hold once it is built.
///
/// Every one of these screens is reached from a row the design draws, so the
/// row is not dead — but the screen behind it is a frame with its sections
/// named and most of them empty. This is that emptiness, said out loud rather
/// than left as a blank stretch the learner reads as a bug.
class SettingsPlaceholder extends StatelessWidget {
  /// Creates a placeholder describing what is coming.
  const SettingsPlaceholder(this.text, {super.key});

  /// The one line describing what belongs here.
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.gutter,
      vertical: AppSpacing.sm,
    ),
    child: Text(text, style: AppText.support(mood: context.mood)),
  );
}
