import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:flutter/material.dart';

/// Roasty at the end of a review, pleased and saying nothing.
///
/// The lesson-sized celebration rather than the module-sized one: finishing a
/// deck is a good few minutes' work, not the end of a module. No line either —
/// the results screen's own message is what there is to say, and a bubble over
/// it would be the same sentiment twice.
class FlashcardsMascot extends StatelessWidget {
  /// Creates a [FlashcardsMascot].
  const FlashcardsMascot({super.key});

  /// The design's `size={150}` on a drill's results mascot.
  static const double _size = 150;

  @override
  Widget build(BuildContext context) => const CompanionCelebration(
    reaction: CompanionReaction.lessonComplete,
    size: _size,
    builder: _mascotOnly,
  );
}

/// The mascot without its line.
Widget _mascotOnly(BuildContext context, Widget companion, String? line) =>
    companion;
