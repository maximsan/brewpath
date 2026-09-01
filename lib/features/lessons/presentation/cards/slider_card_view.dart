import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/grinder_dial_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/slider_dial.dart';
import 'package:brew_path/features/lessons/presentation/cards/slider_track.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The cue above a calibrate card's prompt.
const String _cue = 'CALIBRATE · DIAL TO THE TARGET';

/// The commit affordance, before the setting has been checked.
const String _checkLabel = 'Check answer';

/// Verdicts, which name the band rule rather than a distance.
const String _dialedIn = 'DIALED IN';
const String _notQuite = 'NOT QUITE';

/// What the readout above the track is saying, before and after the commit.
const String _yourSetting = 'Your setting';
const String _target = 'Target';

/// Floor under the readout, so committing an answer never shifts the track out
/// from under the learner's finger.
///
/// A floor rather than a fixed height, as the design source has it: the two
/// readings are one and two lines at the shipped text size, and at a large one
/// they are longer. A fixed height would hold the track still by clipping the
/// answer.
const double _readoutMinHeight = 58;

/// Calibrate: drag to a value, then check it against a target band.
///
/// Graded all-or-nothing — inside the band or not — because the boundary has
/// no way to say "close", and a distance score would have to mean something to
/// mastery. The rules it is judged by are in `slider_dial.dart`, with no widget
/// attached. See `card_boundary.dart`.
///
/// Nothing here knows what is hosting it: the mini-game player and the lesson
/// player both get this renderer unchanged, which is why it sits in the shared
/// card layer.
class SliderCardView extends StatefulWidget {
  /// Creates a [SliderCardView].
  const SliderCardView({
    required this.card,
    required this.onSolved,
    required this.onContinue,
    super.key,
  });

  /// The round: its prompt, its band, and the scale it reads back in.
  final SliderCard card;

  /// Fired once, only when the committed setting landed inside the band.
  final CardSolved onSolved;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  State<SliderCardView> createState() => _SliderCardViewState();
}

class _SliderCardViewState extends State<SliderCardView> {
  double _value = sliderTrackStart;
  bool _touched = false;
  bool _checked = false;

  SliderCard get _card => widget.card;

  bool get _within => sliderWithinTarget(
    value: _value,
    target: _card.target,
    tolerance: _card.tolerance,
  );

  /// The band this round accepts, as a span of the track.
  ({double start, double width}) get _zone =>
      sliderTargetZone(target: _card.target, tolerance: _card.tolerance);

  /// The words this round reads its track back in.
  List<String> get _bands => sliderBands(
    scale: _card.scale,
    leftLabel: _card.leftLabel,
    rightLabel: _card.rightLabel,
  );

  /// What [value] reads as on this round's own scale.
  String _band(double value) {
    final bands = _bands;
    return bands[sliderBandIndex(value: value, bandCount: bands.length)];
  }

  void _drag(double value) => setState(() {
    _value = value;
    _touched = true;
  });

  void _check() {
    if (_checked) return;
    // Latched before the callback, for the reason `graded_picker` records.
    final within = _within;
    setState(() => _checked = true);
    if (within) widget.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return CardShell(
      latched: _checked,
      onContinue: widget.onContinue,
      label: _cue,
      commit: CardCommit(
        label: _checkLabel,
        onCommit: _touched ? _check : null,
      ),
      children: [
        Text(_card.prompt, style: AppText.title(mood: mood)),
        if (sliderIsGrind(
          leftLabel: _card.leftLabel,
          rightLabel: _card.rightLabel,
        )) ...[
          const SizedBox(height: AppSpacing.lg),
          GrinderDialView(value: _value),
        ],
        const SizedBox(height: AppSpacing.lg),
        _readout(mood),
        SliderTrack(
          value: _value,
          onChanged: _checked ? null : _drag,
          zone: _checked ? _zone : null,
          readValue: _band,
        ),
        _endLabels(mood),
        if (_checked) ..._verdict(mood),
      ],
    );
  }

  /// One slot, bottom-aligned, holding both readings the design puts here.
  ///
  /// Before the commit it reads the learner's own band back in accent — a
  /// committed claim. After it, it states the *target's* band beside the band
  /// drawn on the track directly below, so the answer is read where the eye
  /// already is and the range is never stated twice on one screen.
  Widget _readout(MoodColors mood) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: _readoutMinHeight),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          _checked ? _target : _yourSetting,
          style: AppText.label(
            mood: mood,
            color: _checked ? mood.sage : mood.inkMute,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          _band(_checked ? _card.target : _value),
          style: AppText.body(
            mood: mood,
            color: _checked ? mood.ink : mood.accentText,
          ),
        ),
      ],
    ),
  );

  /// Which way the track runs, marked at both ends.
  Widget _endLabels(MoodColors mood) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(child: _endLabel(mood, _card.leftLabel, pointsLeft: true)),
      Flexible(child: _endLabel(mood, _card.rightLabel, pointsLeft: false)),
    ],
  );

  Widget _endLabel(MoodColors mood, String text, {required bool pointsLeft}) {
    final mark = IconMark(AppIcon.arrow, color: mood.ink);
    // Flexible, because the two ends share one row: at a large text size
    // COARSER and FINER would otherwise run into each other rather than wrap.
    final label = Flexible(
      child: Text(
        text,
        style: AppText.label(mood: mood, color: mood.ink),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: pointsLeft
          ? [RotatedBox(quarterTurns: 2, child: mark), label]
          : [label, mark],
    );
  }

  /// What the setting came to. The band on the track says where the answer
  /// sat; only this says whether the round was passed.
  List<Widget> _verdict(MoodColors mood) => [
    const SizedBox(height: AppSpacing.md),
    AnswerFeedback(
      verdict: _within ? _dialedIn : _notQuite,
      outcome: _within ? Verdict.right : Verdict.wrong,
      explanation: _card.feedback,
    ),
  ];
}
