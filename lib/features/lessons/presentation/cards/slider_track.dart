import 'package:brew_path/features/lessons/presentation/cards/card_tints.dart';
import 'package:brew_path/features/lessons/presentation/cards/slider_dial.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Height of the band drawn behind the track, deep enough to read under
/// the rail without swallowing it.
const double _zoneHeight = 18;

/// The rail a calibrate card is dragged along, with its accepted band behind.
///
/// The band is drawn *behind* the rail rather than on it, and only once the
/// answer is committed: before that there is no band to show, and after it the
/// learner needs to see where they landed against where they should have. Its
/// geometry is the card's own — [sliderTargetZone] decides it — so this widget
/// only places it.
class SliderTrack extends StatelessWidget {
  /// Creates a [SliderTrack].
  const SliderTrack({
    required this.value,
    required this.onChanged,
    required this.zone,
    required this.readValue,
    super.key,
  });

  /// Where the handle sits, on the track's own scale.
  final double value;

  /// Null once the card has latched, which is what freezes the rail.
  final ValueChanged<double>? onChanged;

  /// The accepted band, or null while the answer is still open.
  final ({double start, double width})? zone;

  /// What a screen reader hears in place of the raw number — the band the
  /// setting reads as, which is what the card is actually asking about.
  final String Function(double value) readValue;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (zone != null) Positioned.fill(child: _band(mood)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: mood.accent,
            inactiveTrackColor: mood.rule,
            thumbColor: mood.accent,
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value,
            max: sliderTrackMax,
            // Zero so the rail spans the full width the band is measured
            // against; with Material's default padding the two would
            // disagree by a thumb radius at each end and the band would sit
            // off its mark. The low end is Material's own default, and
            // [sliderTrackMin] is what states it is the same track.
            padding: EdgeInsets.zero,
            onChanged: onChanged,
            semanticFormatterCallback: readValue,
          ),
        ),
      ],
    );
  }

  Widget _band(MoodColors mood) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = constraints.maxWidth / sliderTrackSpan;
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: zone!.start * scale),
          child: Container(
            width: zone!.width * scale,
            height: _zoneHeight,
            decoration: BoxDecoration(
              color: mood.sage.withValues(alpha: CardTints.wash),
              border: Border.all(color: mood.sage),
              borderRadius: BorderRadius.circular(AppRadii.editorial),
            ),
          ),
        ),
      );
    },
  );
}
