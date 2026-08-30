import 'package:brew_path/core/widgets/dashed_rounded_border.dart';
import 'package:brew_path/features/lessons/presentation/cards/bagpick_bean_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_tints.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// How each process reads to a learner. The bank stores the key.
const Map<String, String> _processLabels = {
  'washed': 'Washed',
  'honey': 'Honey',
  'natural': 'Natural',
};

/// An unlabelled bag, a sample of three seeds, and three things to inspect.
///
/// The only kind here that is not a picker with decoration. Its mechanic is
/// **investigate, then call it**, and three details carry that:
///
/// * the bag's process is *withheld* until the learner commits, because a card
///   showing the answer while asking the question is not asking anything;
/// * each cue is hidden until tapped, and tapping is optional — someone who is
///   sure may call it from the beans alone, and confidence is worth rewarding;
/// * the feedback names **which cue was the real tell**, which is the round's
///   whole teaching payload. A version that graded the pick and skipped the
///   tell would satisfy every other rule here and teach nothing: the lesson is
///   "this is what you should have looked at", not "you were wrong".
///
/// Option identity is the **process key**, never the position — the seeded
/// order moves what is on screen and nothing keys off an index.
class BagpickCardView extends StatefulWidget {
  /// Creates a [BagpickCardView].
  const BagpickCardView({
    required this.card,
    required this.options,
    required this.onSolved,
    required this.onContinue,
    super.key,
  });

  /// The round.
  final BagpickCard card;

  /// The process keys, already in display order.
  final List<String> options;

  /// Fired once, only if the committed call was correct.
  final CardSolved onSolved;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  State<BagpickCardView> createState() => _BagpickCardViewState();
}

class _BagpickCardViewState extends State<BagpickCardView> {
  /// Three seeds is a sample: enough to read a tendency rather than one bean.
  static const _sampleSize = 3;
  static const _beanSize = 62.0;
  static const _tallBeanSize = 70.0;
  static const _beanTurns = [-0.06, 0.02, -0.017];

  final Set<String> _inspected = {};
  String? _called;

  bool get _latched => _called != null;

  bool get _wasCorrect => _called == widget.card.answer;

  /// What the call came to. Named once, because it is both drawn and spoken
  /// and the two must not be able to drift into saying different things.
  String _verdict(BagpickCard card) => _wasCorrect
      ? 'Called it.'
      : '${_processLabels[card.answer] ?? card.answer}, actually.';

  /// Whether [cueId] is showing its text. Committing reveals them all, so the
  /// explanation can point at a cue the learner never opened.
  bool _isRevealed(String cueId) => _latched || _inspected.contains(cueId);

  void _inspect(String cueId) {
    if (_latched) return;
    setState(() => _inspected.add(cueId));
  }

  void _call(String process) {
    if (_latched) return;
    // Latch before the callback: the host may rebuild synchronously on the
    // success signal, and a card that had not yet latched would take a second
    // call.
    setState(() => _called = process);
    if (process == widget.card.answer) widget.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return CardShell(
      latched: _latched,
      onContinue: widget.onContinue,
      children: [
        _BagPanel(
          bag: card.bag,
          origin: card.origin,
          bean: card.bean,
          revealed: _latched ? _processLabels[card.answer] : null,
          sampleSize: _sampleSize,
          beanSize: _beanSize,
          tallBeanSize: _tallBeanSize,
          beanTurns: _beanTurns,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          card.prompt,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final cue in card.cues) ...[
          _CueRow(
            cue: cue,
            revealed: _isRevealed(cue.id),
            isTell: _latched && card.tell == cue.id,
            onTap: _latched ? null : () => _inspect(cue.id),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.xs),
        ChoiceList(
          options: [
            for (final process in widget.options)
              ChoiceOption(
                text: _processLabels[process] ?? process,
                isCorrect: process == card.answer,
              ),
          ],
          selectedIndex: _latched ? widget.options.indexOf(_called!) : null,
          onSelect: (index) => _call(widget.options[index]),
          revealAnswer: true,
        ),
        if (_latched) ...[
          const SizedBox(height: AppSpacing.xs),
          // Coloured by outcome, as the design's feedback block is. Right and
          // wrong reading the same weight of type differ only in their
          // wording, which a learner scanning back over a run will not catch.
          //
          // And announced as its own region, because colour is precisely what
          // a screen reader cannot report. The option list marks the call, but
          // only this line names the outcome, and it arrives with no focus
          // change to bring a reader to it — the same rule the match board and
          // the multi card's verdicts follow.
          Semantics(
            liveRegion: true,
            label: _verdict(card),
            excludeSemantics: true,
            child: Text(
              _verdict(card),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: _wasCorrect ? context.mood.sage : context.mood.warn,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(card.explanation, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }
}

/// The bag itself: what it says about the lot, and what it withholds.
class _BagPanel extends StatelessWidget {
  const _BagPanel({
    required this.bag,
    required this.origin,
    required this.bean,
    required this.revealed,
    required this.sampleSize,
    required this.beanSize,
    required this.tallBeanSize,
    required this.beanTurns,
  });

  final String bag;
  final String origin;
  final BagpickBean bean;
  final String? revealed;
  final int sampleSize;
  final double beanSize;
  final double tallBeanSize;
  final List<double> beanTurns;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final text = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: mood.surface,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        border: Border.all(color: mood.rule),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bag,
                    style: text.labelSmall?.copyWith(color: mood.inkMute),
                  ),
                ),
                _ProcessPill(revealed: revealed),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(origin, style: text.bodyMedium?.copyWith(color: mood.ink)),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              label: 'A sample of $sampleSize green beans from this bag.',
              excludeSemantics: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var index = 0; index < sampleSize; index++) ...[
                    if (index > 0) const SizedBox(width: AppSpacing.xs),
                    BagpickBeanView(
                      bean: bean,
                      seed: index,
                      size: index == 1 ? tallBeanSize : beanSize,
                      turns: beanTurns[index % beanTurns.length],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Withheld, then named. The concealment is the game, so it is its own widget
/// rather than a conditional buried in the panel.
class _ProcessPill extends StatelessWidget {
  const _ProcessPill({required this.revealed});

  static const _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xs,
    vertical: AppSpacing.xxs,
  );

  final String? revealed;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final hidden = revealed == null;
    // An accent-bordered pill labelled in the reading accent — the design's
    // own pairing for this shape (`brew-challenge.jsx:338`).
    final borderColour = hidden ? mood.accent : mood.sage;
    final labelColour = hidden ? mood.accentText : mood.sage;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: borderColour),
      ),
      child: Padding(
        padding: _padding,
        child: Text(
          revealed ?? 'Process hidden',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: labelColour),
        ),
      ),
    );
  }
}

/// One thing about the sample the learner may look at.
class _CueRow extends StatelessWidget {
  const _CueRow({
    required this.cue,
    required this.revealed,
    required this.isTell,
    required this.onTap,
  });

  static const _labelWidth = 96.0;

  final BagpickCue cue;
  final bool revealed;
  final bool isTell;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final text = Theme.of(context).textTheme;
    final body = revealed ? cue.text : 'Tap to inspect';

    return Semantics(
      button: onTap != null,
      label: isTell
          ? '${cue.label}. $body. This was the tell.'
          : '${cue.label}. $body',
      excludeSemantics: true,
      child: Material(
        // A closed cue has to *look* closed, before its words are read: the
        // design draws it dashed over nothing and fills it in once inspected.
        // A row whose only difference is its text makes the learner read every
        // row to find the unread ones — on the one card where looking *is*
        // the interaction.
        color: switch ((isTell, revealed)) {
          (true, _) => mood.accent.withValues(alpha: CardTints.wash),
          (false, true) => mood.surface,
          (false, false) => Colors.transparent,
        },
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          child: Container(
            decoration: ShapeDecoration(
              shape: revealed
                  ? RoundedRectangleBorder(
                      side: BorderSide(
                        color: isTell ? mood.accent : mood.rule,
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.chrome),
                    )
                  : DashedRoundedBorder(
                      radius: AppRadii.chrome,
                      side: BorderSide(
                        color: isTell ? mood.accent : mood.rule,
                      ),
                    ),
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _labelWidth,
                  child: Text(
                    cue.label,
                    style: text.labelSmall?.copyWith(
                      color: isTell ? mood.accentText : mood.inkMute,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    body,
                    style: text.bodyMedium?.copyWith(
                      color: revealed ? mood.ink : mood.inkMute,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
