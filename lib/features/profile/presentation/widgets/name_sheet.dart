import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/app_text_field.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/profile/domain/learner_name.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The sheet behind the `Name` row: the onboarding step's field, asked again.
///
/// The design draws the two as *"the identical input"* — the name is asked
/// once and editable forever — so this is [AppTextField] under
/// [LearnerName]'s words, with the design's one rule kept: Save is dead while
/// the field is blank. A blank sheet is not a request to be greeted by nobody;
/// closing it leaves the name as it was.
///
/// The design's `marginTop: 18` under the copy and `marginTop: 22` over the
/// button are off the spacing scale; the nearest stops stand in, as they do on
/// the reminder sheet beside this one.
class NameSheet extends StatefulWidget {
  /// Creates the sheet, opening on [initialName].
  const NameSheet({required this.initialName, super.key});

  /// The stored name, or null where there is none yet.
  final String? initialName;

  /// Shows the sheet and resolves to the saved name, or null if dismissed.
  static Future<String?> show(BuildContext context, {String? current}) =>
      showAppSheet<String>(
        context: context,
        title: LearnerName.sheetTitle,
        builder: (_) => NameSheet(initialName: current),
      );

  @override
  State<NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<NameSheet> {
  late String? _name = widget.initialName;

  void _type(String value) => setState(() {
    _name = LearnerName.normalize(value);
  });

  void _save() {
    final name = _name;
    if (name == null) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          LearnerName.sheetBody,
          style: AppText.body(mood: mood, color: mood.inkMute),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          // Focused on open, as the design's field is: the learner tapped a
          // row called Name to get here, so the question has been read.
          autofocus: true,
          initialValue: widget.initialName,
          maxLength: LearnerName.maxLength,
          placeholder: LearnerName.placeholder,
          semanticsLabel: LearnerName.sheetTitle,
          onChanged: _type,
          onSubmitted: _save,
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: LearnerName.sheetAction,
          onPressed: _name == null ? null : _save,
        ),
      ],
    );
  }
}
