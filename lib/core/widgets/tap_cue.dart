import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// Tracking on the cue. Off the ladder's rung on purpose — the register
/// entry holds why.
final double _cueTracking = OffTokens.tapCueTracking.value;

/// The design's `.tap-cue` line (`index.html:1111`).
///
/// The one mono label the design sets at weight 400 rather than 500, with
/// tracking half again as wide as any other, centred and muted — so it reads
/// as an instruction to the reader rather than a heading over the content.
///
/// Shared because two screens carry it: the Loading screen's foot, where it
/// alternates with the brand mark, and Welcome, where it is the only way
/// forward. Drawn twice, the two drifted on weight and tracking.
class TapCue extends StatelessWidget {
  /// Creates a [TapCue].
  const TapCue(this.text, {super.key});

  /// The cue's words. Rendered as given — the design writes them upper-case.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppText.label(mood: context.mood, face: AppFace.mono).copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: _cueTracking,
      ),
    );
  }
}
