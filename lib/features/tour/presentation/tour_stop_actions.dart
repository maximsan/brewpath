import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

/// The two buttons every Tour card carries, and how they sit on it.
///
/// A card with no buttons is a Tour with no way out, which is the defect this
/// answers. `showcaseview` builds them from data rather than from widgets, so
/// this is a description the card hands over — buildable and assertable
/// without pumping a spotlight.
///
/// Skip left, Next right, and *Done* rather than Next on the last stop, where
/// advancing is finishing. Both endings run through the engine's own
/// callbacks: `skip` calls `dismiss()` and the last `next` runs off the end of
/// the list into `onFinish`, so the host closes the Tour once, in one place.

/// Padding around the left-hand Skip, which is text on the card rather than a
/// filled button — the vertical stop keeps it a comfortable tap target.
const _skipPadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.xxs,
  vertical: AppSpacing.sm,
);

/// Padding inside the right-hand pill.
const _advancePadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.md,
  vertical: AppSpacing.sm,
);

/// How the pair sits under the card's copy: pushed to the two edges, inside
/// the card rather than floating below it.
const tourStopActionConfig = TooltipActionConfig(
  gapBetweenContentAndAction: AppSpacing.sm,
  crossAxisAlignment: CrossAxisAlignment.center,
);

/// The buttons for a stop, given the [mood] they are drawn in and whether the
/// stop is [isLast] in the Tour.
List<TooltipActionButton> tourStopActions({
  required MoodColors mood,
  required bool isLast,
}) => [
  TooltipActionButton(
    type: TooltipDefaultActionType.skip,
    name: TourCopy.stopSkip,
    backgroundColor: Colors.transparent,
    padding: _skipPadding,
    borderRadius: BorderRadius.zero,
    textStyle: AppText.support(color: mood.inkMute, face: AppFace.control),
  ),
  TooltipActionButton(
    type: TooltipDefaultActionType.next,
    name: isLast ? TourCopy.stopDone : TourCopy.stopNext,
    backgroundColor: mood.accent,
    padding: _advancePadding,
    borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
    textStyle: AppText.support(color: mood.accentInk, face: AppFace.control),
  ),
];
