import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The sheet behind the `Daily reminder` row: eight slots, pick one, set it.
///
/// A grid of times rather than a platform time picker, because the design
/// offers a shortlist and its copy promises *"one quiet reminder a day"* —
/// choosing 06:47 is not a thing the feature does
/// (`prototype/settings.jsx:104`).
///
/// It opens through `showAppSheet`, so it wears the app's one sheet dressing
/// and the design's own title is the sheet's name.
class DailyReminderSheet extends StatefulWidget {
  /// Creates the sheet, opening on [initialTime].
  const DailyReminderSheet({required this.initialTime, super.key});

  /// The slot to start on — the stored one, or the design's default.
  final String initialTime;

  /// Shows the sheet and resolves to the chosen slot, or null if dismissed.
  static Future<String?> show(BuildContext context, {String? current}) =>
      showAppSheet<String>(
        context: context,
        title: DailyReminder.sheetTitle,
        builder: (_) => DailyReminderSheet(
          initialTime: current ?? DailyReminder.defaultTime,
        ),
      );

  @override
  State<DailyReminderSheet> createState() => _DailyReminderSheetState();
}

class _DailyReminderSheetState extends State<DailyReminderSheet> {
  /// Two per row, as the design lays them out.
  static const _columns = 2;

  /// Wide and short: a time is a short string, and the slot is a tap target.
  static const _slotAspectRatio = 3.2;

  late String _selected = widget.initialTime;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(DailyReminder.sheetBody, style: AppText.body(mood: mood)),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: _columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.xs,
          crossAxisSpacing: AppSpacing.xs,
          childAspectRatio: _slotAspectRatio,
          children: [
            for (final time in DailyReminder.times)
              _Slot(
                time: time,
                isSelected: time == _selected,
                onPick: () => setState(() => _selected = time),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: Text(
            DailyReminder.sheetAction,
            style: AppText.label(color: mood.accentInk),
          ),
        ),
      ],
    );
  }
}

/// One time to tap. Editorial radius, because the design draws these as tiles
/// rather than as chrome.
class _Slot extends StatelessWidget {
  const _Slot({
    required this.time,
    required this.isSelected,
    required this.onPick,
  });

  final String time;
  final bool isSelected;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? mood.accent : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.editorial),
          side: BorderSide(color: isSelected ? mood.accent : mood.rule),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPick,
          child: Center(
            child: Text(
              time,
              style: AppText.support(
                color: isSelected ? mood.accentInk : mood.ink,
                face: AppFace.mono,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
