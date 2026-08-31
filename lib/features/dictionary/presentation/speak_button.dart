import 'dart:async';

import 'package:brew_path/features/dictionary/presentation/speaker_mark.dart';
import 'package:brew_path/services/speech/speech_providers.dart';
import 'package:brew_path/services/speech/speech_service.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The chip's own metrics, from the design (`dictionary.jsx:33`).
const EdgeInsets _chipPadding = EdgeInsets.fromLTRB(9, 5, 12, 5);
const double _markBox = 16;
const double _markSize = 15;

/// How long the second wave shows after a press (`dictionary.jsx:29`).
const Duration _pulse = Duration(milliseconds: 620);

/// A term's pronunciation: the respelling, and a speaker that says the word.
///
/// Where the platform has no voice for the content's language, the respelling
/// still shows — it is content — but as plain text, with no control wrapped
/// around it. A speaker that cannot speak is worse than no speaker.
class SpeakButton extends ConsumerWidget {
  /// Creates a [SpeakButton].
  const SpeakButton({
    required this.word,
    required this.respelling,
    super.key,
  });

  /// The term to say aloud.
  final String word;

  /// Its phonetic respelling, shown as the chip's label.
  final String respelling;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSpeak =
        ref.watch(canSpeakContentLanguageProvider).asData?.value ?? false;

    if (!canSpeak) {
      return Text(
        respelling,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: context.mood.inkMute),
      );
    }
    return _SpeakChip(word: word, respelling: respelling);
  }
}

class _SpeakChip extends ConsumerStatefulWidget {
  const _SpeakChip({required this.word, required this.respelling});

  final String word;
  final String respelling;

  @override
  ConsumerState<_SpeakChip> createState() => _SpeakChipState();
}

class _SpeakChipState extends ConsumerState<_SpeakChip> {
  Timer? _pulseTimer;
  bool _speaking = false;

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  Future<void> _speak() async {
    unawaited(
      ref
          .read(speechServiceProvider)
          .speak(widget.word, languageTag: contentLanguageTag),
    );
    if (MediaQuery.disableAnimationsOf(context)) return;

    _pulseTimer?.cancel();
    setState(() => _speaking = true);
    _pulseTimer = Timer(_pulse, () {
      if (mounted) setState(() => _speaking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      label: 'Pronounce ${widget.word}',
      excludeSemantics: true,
      child: InkWell(
        onTap: _speak,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: _chipPadding,
          decoration: BoxDecoration(
            border: Border.all(color: mood.rule),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: _markBox,
                child: Center(
                  child: SpeakerMark(
                    size: _markSize,
                    color: mood.accent,
                    speaking: _speaking,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                widget.respelling,
                style: AppText.label(
                  mood: mood,
                  face: AppFace.mono,
                  tracking: AppTracking.figure,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
