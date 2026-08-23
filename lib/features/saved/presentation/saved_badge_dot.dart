import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The mark on the Saved button saying the shelf holds something.
///
/// A presence indicator, not a counter: the design shows *that* something is
/// saved and leaves the how-many to the shelf. The number still reaches a
/// screen reader through the button's label, so nothing depends on seeing this.
class SavedBadgeDot extends StatelessWidget {
  /// Creates a [SavedBadgeDot].
  const SavedBadgeDot({super.key});

  /// The dot's diameter.
  static const double size = 9;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.mood.accent,
        shape: BoxShape.circle,
      ),
    );
  }
}
