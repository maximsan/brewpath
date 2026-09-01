import 'dart:math' as math;

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The check's drawn size.
const double _markSize = 13;

/// Half-strength accent: a stamp pressed onto the card, not a control on it.
const double _borderAlpha = 0.5;

/// The design tilts it, so it reads as stamped rather than laid out
/// (`brew-challenge.jsx:173`).
const double _tilt = -3 * math.pi / 180;

/// The mark a brewed challenge leaves on its card.
///
/// A stamp, not a button: it says the learner has been here, and there is
/// nothing to press. The challenge itself lives lower down the sheet, in
/// `CardStampSection`.
class TriedSeal extends StatelessWidget {
  /// Creates a [TriedSeal].
  const TriedSeal({super.key});

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      label: 'Challenge tried',
      excludeSemantics: true,
      child: Transform.rotate(
        angle: _tilt,
        child: Container(
          padding: OffTokens.triedSealPadding.value,
          decoration: BoxDecoration(
            border: Border.all(
              color: mood.accent.withValues(alpha: _borderAlpha),
            ),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconMark(AppIcon.check, size: _markSize, color: mood.accent),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'TRIED',
                style: AppText.micro(mood: mood, color: mood.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
