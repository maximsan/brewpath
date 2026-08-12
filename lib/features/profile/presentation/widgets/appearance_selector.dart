import 'package:brew_path/shared/theme/app_theme_mode.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Settings appearance control: System · Light · Dark.
///
/// Reads [ThemeModeController] rather than the settings row, because that
/// controller is the single source of truth for the appearance — the row backs
/// it, but nothing displays from the row.
class AppearanceSelector extends ConsumerWidget {
  /// Creates an [AppearanceSelector].
  const AppearanceSelector({super.key});

  static const _horizontalPadding = 16.0;
  static const _verticalPadding = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(themeModeControllerProvider);
    final mood = context.mood;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      child: Semantics(
        label: 'Appearance',
        value: selected.label,
        child: SegmentedButton<AppThemeMode>(
          segments: [
            for (final mode in AppThemeMode.values)
              ButtonSegment<AppThemeMode>(
                value: mode,
                label: Text(mode.label),
                // Excluded from semantics because the wrapping Semantics node
                // already announces the control and its current value; without
                // this each segment would be read as a separate unlabelled
                // button.
                tooltip: mode.label,
              ),
          ],
          selected: {selected},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => ref
              .read(themeModeControllerProvider.notifier)
              .select(selection.first),
          style: SegmentedButton.styleFrom(
            foregroundColor: mood.inkMute,
            selectedForegroundColor: mood.accentInk,
            selectedBackgroundColor: mood.accent,
            side: BorderSide(color: mood.rule),
          ),
        ),
      ),
    );
  }
}
