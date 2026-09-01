import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_option_tile.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_tints.dart';
import 'package:brew_path/features/lessons/presentation/cards/sequence_order.dart';
import 'package:brew_path/features/lessons/presentation/cards/sequence_step_number.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The cue above a sequence card's prompt.
const String _cue = 'PUT IN ORDER · TAP IN SEQUENCE';

/// The commit affordance, before the run has been submitted.
const String _submitLabel = 'Submit';

/// Clears the run while it is still open.
const String _resetLabel = 'Reset';

/// Verdicts, which name the all-or-nothing rule rather than a count of steps.
const String _inOrder = 'In order';

const String _nailedIt = 'Nailed the sequence.';
const String _wrongOrder = 'Not the right order this time.';

/// Heading over the reveal.
const String _correctOrder = 'CORRECT ORDER';

/// How the reveal joins the steps.
const String _arrow = '  →  ';

/// Put the steps in order: tap them into place, then commit the whole run.
///
/// Two things separate it from the picking kinds. Tapping **assigns a
/// position** rather than answering — tapping an assigned step takes it back
/// out and the rest renumber — and the card is not answered until the learner
/// says so, which is the shell's swapping button rather than a second action
/// drawn here. It is graded all-or-nothing: the run is the authored order or it
/// is not. See `card_boundary.dart`.
///
/// It takes its steps **already in display order**, like every other card whose
/// order is seeded, so one place owns the seed and a replay moves every card
/// the same way. That matters more here than anywhere else — see
/// [sequenceDisplayOrder] for why a sequence card's shuffle is the one that can
/// hand the learner the answer.
class SequenceCardView extends StatefulWidget {
  /// Creates a [SequenceCardView].
  const SequenceCardView({
    required this.prompt,
    required this.items,
    required this.onSolved,
    required this.onContinue,
    super.key,
  });

  /// What the round asks.
  final String prompt;

  /// The steps, already in display order.
  final List<SequenceItem> items;

  /// Fired once, only when the committed run is the authored order.
  final CardSolved onSolved;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  State<SequenceCardView> createState() => _SequenceCardViewState();
}

class _SequenceCardViewState extends State<SequenceCardView> {
  /// Display indices, in the order they were tapped.
  final List<int> _run = [];
  bool _submitted = false;

  bool get _allPlaced => _run.length == widget.items.length;

  List<SequenceItem> get _tapped => [
    for (final index in _run) widget.items[index],
  ];

  bool get _wasCorrect =>
      sequenceIsCorrect(tapped: _tapped, total: widget.items.length);

  void _tap(int index) {
    if (_submitted) return;
    // A toggle rather than a select: taking a step back out is how a learner
    // corrects a misplacement, and the steps after it simply renumber.
    setState(() {
      if (!_run.remove(index)) _run.add(index);
    });
  }

  void _reset() {
    if (_submitted) return;
    setState(_run.clear);
  }

  void _submit() {
    if (_submitted || !_allPlaced) return;
    // Latched before the callback, for the reason `graded_picker` records.
    final correct = _wasCorrect;
    setState(() => _submitted = true);
    if (correct) widget.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return CardShell(
      latched: _submitted,
      onContinue: widget.onContinue,
      label: _cue,
      commit: CardCommit(
        label: _submitLabel,
        onCommit: _allPlaced ? _submit : null,
      ),
      children: [
        Text(widget.prompt, style: AppText.title(mood: mood)),
        const SizedBox(height: AppSpacing.md),
        for (var index = 0; index < widget.items.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _step(mood, index),
          ),
        if (_allPlaced && !_submitted)
          Align(
            alignment: Alignment.centerRight,
            child: LinkButton(label: _resetLabel, onPressed: _reset),
          ),
        if (_submitted) ..._verdict(mood),
      ],
    );
  }

  /// One step, in the shared option frame.
  ///
  /// Its mark says three different things across the card's life: which
  /// position the learner gave it, whether that position was right, and — when
  /// it was not — where the step actually belonged. The last is the only place
  /// a wrong run says anything per-step, which is the card's reaction to a
  /// wrong answer happening inside it.
  Widget _step(MoodColors mood, int index) {
    final item = widget.items[index];
    final position = _run.indexOf(index);
    final mark = sequenceStepMark(
      item: item,
      position: position,
      submitted: _submitted,
    );

    return CardOptionTile(
      onTap: _submitted ? null : () => _tap(index),
      // Only a committed step marks its tile. A step merely *placed* carries
      // its position on the badge and nothing else, as the design source has
      // it — `.seq-item.assigned` tints the number, never the row.
      borderColor: switch (mark) {
        SequenceStepMark.right => mood.sage,
        SequenceStepMark.wrong => mood.berry,
        SequenceStepMark.unplaced || SequenceStepMark.placed => null,
      },
      fillColor: switch (mark) {
        SequenceStepMark.right => mood.sage.withValues(alpha: CardTints.wash),
        SequenceStepMark.wrong => mood.berry.withValues(
          alpha: CardTints.wrongWash,
        ),
        SequenceStepMark.unplaced || SequenceStepMark.placed => null,
      },
      semanticsLabel: [
        item.label,
        if (mark.isPlaced) 'position ${position + 1}',
        if (mark == SequenceStepMark.right) 'correct',
        if (mark == SequenceStepMark.wrong) 'belongs at ${item.order}',
      ].join(', '),
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          SequenceStepNumber(
            position: mark.isPlaced ? position + 1 : null,
            mark: mark,
          ),
          Expanded(
            child: Text(
              item.label,
              style: AppText.support(mood: mood, color: mood.ink),
            ),
          ),
          // Muted rather than berry: the row is already marked, and a second
          // red thing on it would read as a second fault.
          if (mark == SequenceStepMark.wrong)
            Text(
              'GOES #${item.order}',
              style: AppText.micro(mood: mood, tracking: AppTracking.hint),
            ),
        ],
      ),
    );
  }

  /// What the run came to. The step marks say where each one sat; only this
  /// says whether the round was passed.
  ///
  /// The reveal follows either way, as the design source has it: a learner who
  /// got it right still leaves the round with the order written out.
  List<Widget> _verdict(MoodColors mood) => [
    AnswerFeedback(
      verdict: _wasCorrect ? _inOrder : notQuiteVerdict,
      outcome: _wasCorrect ? Verdict.right : Verdict.wrong,
      explanation: _wasCorrect ? _nailedIt : _wrongOrder,
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Text(
            _correctOrder,
            style: AppText.label(mood: mood, color: mood.sage),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            [
              for (final item in sequenceSolution(widget.items)) item.label,
            ].join(_arrow),
            style: AppText.support(mood: mood, color: mood.ink),
          ),
        ],
      ),
    ),
  ];
}
