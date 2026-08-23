import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/features/lessons/presentation/cards/green_bean.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// How the three processes are written for a learner.
const Map<String, String> processLabels = {
  'washed': 'Washed',
  'honey': 'Honey',
  'natural': 'Natural',
};

/// Blind bag: an unlabelled lot, a sample of three seeds, and three things
/// worth inspecting. Call the process from the look alone.
///
/// Unlike its graded siblings this is not a picker with decoration. The
/// **inspection is the card**: each cue is uncovered by a tap, and a learner
/// who commits without looking has guessed rather than read. Committing
/// reveals every cue at once and marks the one that was the real tell, so the
/// feedback teaches what should have been noticed rather than only whether the
/// answer was right.
class BagpickCardView extends StatefulWidget {
  /// Creates a [BagpickCardView].
  const BagpickCardView({
    required this.card,
    required this.options,
    required this.onSolved,
    required this.onContinue,
    super.key,
  });

  /// The round being played.
  final BagpickCard card;

  /// The process keys in display order, already seeded.
  final List<String> options;

  /// Fired once, only if the committed call was right.
  final CardSolved onSolved;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  State<BagpickCardView> createState() => _BagpickCardViewState();
}

class _BagpickCardViewState extends State<BagpickCardView> {
  final Set<String> _inspected = {};
  String? _called;

  bool get _latched => _called != null;
  bool get _wasRight => _called == widget.card.answer;

  void _inspect(String cueId) {
    if (_latched) return;
    setState(() => _inspected.add(cueId));
  }

  void _call(int index) {
    // Latch before the callback: the host may rebuild synchronously on the
    // success signal, and a card that had not yet latched would take a second
    // tap. Same rule as `GradedPicker`.
    final choice = widget.options[index];
    setState(() => _called = choice);
    if (choice == widget.card.answer) widget.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final theme = Theme.of(context);

    return CardShell(
      latched: _latched,
      onContinue: widget.onContinue,
      label: 'BLIND BAG · READ THE BEANS',
      children: [
        _Sample(
          card: card,
          revealedProcess: _latched ? card.answer : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          card.prompt,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final cue in card.cues) ...[
          _CueRow(
            cue: cue,
            // Committing opens everything: the learner has earned the whole
            // reading, including the cues they never thought to check.
            revealed: _latched || _inspected.contains(cue.id),
            isTell: _latched && card.tell == cue.id,
            onInspect: _latched ? null : () => _inspect(cue.id),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.xs),
        ChoiceList(
          options: [
            for (final option in widget.options)
              ChoiceOption(
                text: processLabels[option] ?? option,
                isCorrect: option == card.answer,
              ),
          ],
          selectedIndex: _called == null
              ? null
              : widget.options.indexOf(_called!),
          onSelect: _call,
          revealAnswer: true,
        ),
        if (_latched) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _wasRight
                ? 'Called it.'
                : '${processLabels[card.answer] ?? card.answer}, actually.',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(card.explanation, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }
}

/// The bag, its origin line, and the three seeds drawn from it.
class _Sample extends StatelessWidget {
  const _Sample({required this.card, required this.revealedProcess});

  final BagpickCard card;

  /// The process, once called — null while the bag is still unlabelled.
  final String? revealedProcess;

  static const List<double> _turns = [-0.061, 0.019, -0.017];
  static const List<double> _sizes = [62, 70, 62];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final hidden = revealedProcess == null;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        border: Border.all(color: hidden ? mood.accent : mood.rule),
        color: hidden ? null : mood.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.bag,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: mood.inkMute,
                ),
              ),
              _ProcessPill(process: revealedProcess),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(card.origin, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: 'A sample of three green beans from this bag.',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var seed = 0; seed < _turns.length; seed++) ...[
                  if (seed > 0) const SizedBox(width: AppSpacing.xs),
                  GreenBean(
                    bean: card.bean,
                    seed: seed,
                    size: _sizes[seed],
                    turns: _turns[seed],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

/// Reads "Process hidden" until the call is made, then names it.
class _ProcessPill extends StatelessWidget {
  const _ProcessPill({required this.process});

  final String? process;

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xs,
    vertical: AppSpacing.xxs,
  );

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final hidden = process == null;
    final tint = hidden ? mood.accent : mood.sage;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: tint),
      ),
      child: Text(
        hidden ? 'Process hidden' : (processLabels[process] ?? process!),
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: tint),
      ),
    );
  }
}

/// One thing about the sample the learner can look at.
class _CueRow extends StatelessWidget {
  const _CueRow({
    required this.cue,
    required this.revealed,
    required this.isTell,
    required this.onInspect,
  });

  final BagpickCue cue;
  final bool revealed;

  /// Whether this was the cue that gave the answer away.
  final bool isTell;

  /// Null once the card has latched — nothing left to uncover.
  final VoidCallback? onInspect;

  static const double _labelWidth = 92;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Semantics(
      button: onInspect != null,
      label: revealed
          ? '${cue.label}. ${cue.text}${isTell ? ' The tell.' : ''}'
          : '${cue.label}. Not yet inspected.',
      hint: onInspect == null ? null : 'Inspects the sample',
      excludeSemantics: true,
      child: InkWell(
        onTap: onInspect,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.chrome),
            border: Border.all(color: isTell ? mood.accent : mood.rule),
            color: isTell ? mood.surface2 : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _labelWidth,
                child: Text(
                  cue.label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isTell ? mood.accent : mood.inkMute,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  revealed ? cue.text : 'Tap to inspect',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: revealed ? mood.ink : mood.inkMute,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
