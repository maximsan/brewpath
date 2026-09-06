import 'package:brew_path/core/widgets/page_large_title.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/core/widgets/sub_screen_scaffold.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

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
    return SubScreenScaffold(
      title: title,
      body: (context, scrollPadding) => ListView(
        padding: scrollPadding.copyWith(bottom: AppSpacing.xl),
        children: [
          SettingsScreenHeading(title: title),
          ...children,
        ],
      ),
    );
  }
}

/// The screen's name as the display heading the sections hang under.
///
/// The design prints it twice — small in the bar once the page has scrolled,
/// and large here at the top, where it is what titles the page at rest. This
/// is the page's half of that pair, which is `PageLargeTitle`; the padding
/// around it is what a settings screen opens on.
class SettingsScreenHeading extends StatelessWidget {
  /// Creates the heading for [title].
  const SettingsScreenHeading({required this.title, super.key});

  /// The screen's name.
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.gutter,
      AppSpacing.sm,
      AppSpacing.gutter,
      AppSpacing.md,
    ),
    child: PageLargeTitle(title),
  );
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

/// The centred mono line that closes Settings and About.
///
/// The design ends both screens this way rather than with a labelled row: the
/// app's name, its version and [SettingsCopy.versionTagline], separated by
/// middots (`prototype/screens.jsx:559`) — mono smallcaps, centred, in muted
/// ink. The app had it as an `About` section with a stock info glyph on a
/// `ListTile`, which is a row where the design has a signature.
///
/// The line is not spelled out here: the glossary guard reads comments too,
/// and the tagline is the one phrase it allows by name.
class SettingsVersionLine extends StatelessWidget {
  /// Creates the version line for [version].
  const SettingsVersionLine({required this.version, super.key});

  /// The version string, or null while it is still being read.
  final String? version;

  /// Shown while `package_info` is still answering — the line's shape without
  /// a number it does not have yet.
  static const _pendingVersion = '—';

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final line =
        'BrewPath · ${version ?? _pendingVersion} · '
        '${SettingsCopy.versionTagline}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Semantics(
        label: line,
        excludeSemantics: true,
        child: Text(
          line.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppText.micro(mood: mood, color: mood.inkMute),
        ),
      ),
    );
  }
}
