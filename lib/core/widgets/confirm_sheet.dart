import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// One row of a confirm sheet's itemised list: a label against its value.
@immutable
class ConfirmLine {
  /// Creates a [ConfirmLine].
  const ConfirmLine({required this.label, required this.value});

  /// What the row measures.
  final String label;

  /// This learner's own figure for it.
  final String value;
}

/// What an action costs: the itemised list, and the line that closes it.
///
/// One value, so a catch-all cannot be written without the list it closes.
@immutable
class ConfirmStakes {
  /// Creates the stakes. Empty is the sheet that only asks.
  const ConfirmStakes({this.lines = const [], this.closingLine});

  /// Exactly what the action affects, so the stakes are concrete.
  final List<ConfirmLine> lines;

  /// What no row names, said as its own line under the list.
  final String? closingLine;
}

/// The pair of buttons at the foot, and which of them is the dangerous one.
@immutable
class ConfirmActions {
  /// The plain pair — nothing is thrown away.
  const ConfirmActions({
    required this.confirm,
    this.cancel = ConfirmSheetCopy.keepMyProgress,
  }) : isDestructive = false;

  /// The berry pair, for a confirm that cannot be undone.
  const ConfirmActions.destructive({
    required this.confirm,
    this.cancel = ConfirmSheetCopy.keepMyProgress,
  }) : isDestructive = true;

  /// What the confirm reads.
  final String confirm;

  /// What the dismiss reads.
  final String cancel;

  /// Whether the confirm is drawn in berry.
  final bool isDestructive;
}

/// The words a confirm sheet supplies when the caller does not.
abstract final class ConfirmSheetCopy {
  /// The design's own default cancel, kept as the default here so the sheet it
  /// was written for cannot drift from it.
  static const keepMyProgress = 'Keep my progress';
}

/// Asks before an action worth a second thought, and says what it costs.
///
/// Resolves true only when the confirm is tapped — dismissing is a no.
Future<bool> showConfirmSheet({
  required BuildContext context,
  required String title,
  required ConfirmActions actions,
  String? body,
  ConfirmStakes stakes = const ConfirmStakes(),
}) async =>
    await showAppSheet<bool>(
      context: context,
      title: title,
      builder: (context) =>
          _ConfirmBody(body: body, stakes: stakes, actions: actions),
    ) ??
    false;

/// Everything under the sheet's title: the paragraph, the list, and the two
/// ways out.
class _ConfirmBody extends StatelessWidget {
  const _ConfirmBody({
    required this.stakes,
    required this.actions,
    this.body,
  });

  final String? body;
  final ConfirmStakes stakes;
  final ConfirmActions actions;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final support = AppText.support(mood: mood);
    final closingLine = stakes.closingLine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (body != null) Text(body!, style: support),
        // The design's `marginTop: 18` here is off the spacing scale; the
        // nearest stop stands in, as it does on the name and reminder sheets.
        if (stakes.lines.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _LineList(lines: stakes.lines),
        ],
        if (closingLine != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(closingLine, style: support),
        ],
        // The stack's own `marginTop: 22`, rounded the same way.
        const SizedBox(height: AppSpacing.lg),
        if (actions.isDestructive)
          PrimaryButton.destructive(
            label: actions.confirm,
            onPressed: () => Navigator.of(context).pop(true),
          )
        else
          PrimaryButton(
            label: actions.confirm,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        // `.stack.gap-12` between the pair.
        const SizedBox(height: AppSpacing.sm),
        GhostButton(
          label: actions.cancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}

/// The bordered column of rows — `1px solid var(--rule)` over `var(--surface)`,
/// hairlined between one row and the next but never under the last.
class _LineList extends StatelessWidget {
  const _LineList({required this.lines});

  final List<ConfirmLine> lines;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: mood.surface,
        border: Border.all(color: mood.rule),
        borderRadius: BorderRadius.circular(AppRadii.chrome),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, line) in lines.indexed)
            _Line(line: line, ruledBelow: index < lines.length - 1),
        ],
      ),
    );
  }
}

/// One row: the measure, and the learner's figure for it in mono.
class _Line extends StatelessWidget {
  const _Line({required this.line, required this.ruledBelow});

  final ConfirmLine line;
  final bool ruledBelow;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return MergeSemantics(
      child: Container(
        padding: OffTokens.confirmLinePadding.value,
        decoration: ruledBelow
            ? BoxDecoration(
                border: Border(bottom: BorderSide(color: mood.rule)),
              )
            : null,
        child: Row(
          children: [
            Expanded(
              child: Text(line.label, style: AppText.support(color: mood.ink)),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              line.value,
              softWrap: false,
              style: AppText.support(mood: mood, face: AppFace.mono),
            ),
          ],
        ),
      ),
    );
  }
}
