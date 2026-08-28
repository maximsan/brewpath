import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/dashed_rounded_border.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:flutter/material.dart';

/// The checkbox beside each choice.
const double _boxSize = 22;
const double _boxBorder = 1.5;
const double _boxMark = 15;

/// How one option is drawn, as the design's four states.
///
/// Kept as one value because the row and its box are always drawn from the
/// same state, and splitting them let the two disagree.
@immutable
class MultiOptionSkin {
  /// Creates a [MultiOptionSkin].
  const MultiOptionSkin({
    required this.border,
    required this.boxBorder,
    required this.fill,
    required this.boxFill,
    required this.markColor,
    this.icon,
    this.dashed = false,
  });

  /// The row's outline.
  final Color border;

  /// The checkbox's outline, which the design mutes while nothing is picked
  /// even though the row around it uses the plain rule.
  final Color boxBorder;

  /// The row's fill, or null where the design leaves it on the surface.
  final Color? fill;

  /// The checkbox's fill.
  final Color boxFill;

  /// The colour of the mark inside the checkbox.
  final Color markColor;

  /// The mark inside the checkbox, or null where there is none.
  final AppIcon? icon;

  /// Whether the row and its box are outlined in dashes.
  final bool dashed;
}

/// The checkbox the design puts before every choice — dashed when the answer
/// was missed, exactly as its row is.
class MultiChoiceBox extends StatelessWidget {
  /// Creates a [MultiChoiceBox].
  const MultiChoiceBox({required this.skin, super.key});

  /// The state this box is drawn in.
  final MultiOptionSkin skin;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: skin.boxBorder, width: _boxBorder);

    return Container(
      width: _boxSize,
      height: _boxSize,
      decoration: ShapeDecoration(
        color: skin.boxFill,
        shape: skin.dashed
            ? DashedRoundedBorder(radius: AppRadii.editorial, side: side)
            : RoundedRectangleBorder(
                side: side,
                borderRadius: BorderRadius.circular(AppRadii.editorial),
              ),
      ),
      child: skin.icon == null
          ? null
          : IconMark(skin.icon!, size: _boxMark, color: skin.markColor),
    );
  }
}
