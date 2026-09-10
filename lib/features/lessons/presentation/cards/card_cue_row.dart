import 'package:brew_path/features/lessons/presentation/cards/card_cue.dart';
import 'package:brew_path/features/lessons/presentation/cards/help_drawer.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The mark the help button carries, which is the design's own.
const String _helpMark = '?';

/// The ring the mark sits in, and the target around it.
const double _markRing = 20;
const double _target = 44;

/// A card's kind, named in the accent, with the `?` that explains it.
///
/// The cue is set at the support step rather than the label step the app's
/// other eyebrows use — the design writes `fontSize: 'var(--t-support)'` over
/// its smallcaps rule — which is also why it keeps the accent rather than the
/// darkened mix that covers accent text at the label step.
class CardCueRow extends StatelessWidget {
  /// Creates a [CardCueRow] for [cue].
  const CardCueRow({required this.cue, super.key});

  /// Which format this card is playing.
  final CardCue cue;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Row(
      children: [
        Flexible(
          child: Semantics(
            label: cue.phrase,
            excludeSemantics: true,
            child: Text(
              cue.phrase.toUpperCase(),
              // `lineHeight: 1` — the cue is one line of chrome over the
              // card, not a paragraph, and the rung's 1.4 would pad it.
              style: AppText.support(
                face: AppFace.control,
                color: mood.accent,
                tracking: AppTracking.smallcaps,
              ).copyWith(height: 1),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        _HelpButton(cue: cue),
      ],
    );
  }
}

/// The `?` beside a cue. Draws nothing until the bank hands back the entry it
/// would open, so the affordance and what it opens arrive together.
class _HelpButton extends ConsumerWidget {
  const _HelpButton({required this.cue});

  final CardCue cue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final help = ref.watch(cardKindHelpProvider(cue)).asData?.value;
    if (help == null) return const SizedBox.shrink();

    return Semantics(
      button: true,
      label: howToPlayLabel,
      excludeSemantics: true,
      child: InkResponse(
        onTap: () => showHelpDrawer(context, help),
        radius: _target / 2,
        child: SizedBox(
          width: _target,
          height: _target,
          child: Center(
            child: Container(
              width: _markRing,
              height: _markRing,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: mood.rule),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                _helpMark,
                style: AppText.label(face: AppFace.mono, color: mood.inkMute),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
