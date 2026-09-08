import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/app_theme_mode.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The `APPEARANCE` section's one row: a **Theme** label over three choices.
///
/// The design draws this as a row of its own rather than as a control dropped
/// on the screen: the label sits where every other row's label sits, the three
/// options fill the width beneath it, and the whole thing closes on the same
/// hairline. It was a bare Material `SegmentedButton` — no label, no rule, and
/// the options in the enum's order rather than the design's.
///
/// Reads [ThemeModeController] rather than the settings row, because that
/// controller is the single source of truth for the appearance — the row backs
/// it, but nothing displays from the row.
class AppearanceSelector extends ConsumerWidget {
  /// Creates an [AppearanceSelector].
  const AppearanceSelector({super.key});

  /// The design's order, which is not the enum's: the two ends are the two
  /// explicit choices, and *System* sits between them as the middle ground.
  static const List<AppThemeMode> _order = [
    AppThemeMode.light,
    AppThemeMode.system,
    AppThemeMode.dark,
  ];

  /// The row's label — the one word the design puts above the choices.
  static const _label = 'Theme';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(themeModeControllerProvider);
    final mood = context.mood;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: mood.rule)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.gutter,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_label, style: AppText.body(mood: mood)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (final mode in _order) ...[
                  if (mode != _order.first)
                    const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _ThemeChoice(
                      mode: mode,
                      isSelected: mode == selected,
                      onPick: () => ref
                          .read(themeModeControllerProvider.notifier)
                          .select(mode),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the three theme choices — a tile, in the editorial radius the design
/// gives every pick-one control.
class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.mode,
    required this.isSelected,
    required this.onPick,
  });

  /// Matches the row's own minimum, so a choice is never harder to hit than
  /// the row it sits in.
  static const double _minHeight = SettingsNavRow.minHeight;

  final AppThemeMode mode;
  final bool isSelected;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      selected: isSelected,
      label: mode.label,
      excludeSemantics: true,
      child: Material(
        color: isSelected ? mood.accent : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.editorial),
          side: BorderSide(color: isSelected ? mood.accent : mood.rule),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPick,
          child: Container(
            constraints: const BoxConstraints(minHeight: _minHeight),
            alignment: Alignment.center,
            child: Text(
              mode.label,
              style: AppText.label(
                color: isSelected ? mood.accentInk : mood.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
